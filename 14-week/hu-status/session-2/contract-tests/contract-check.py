"""Cross-service contract check: every recorded consumer interaction must match the
provider's OpenAPI contract in telemed-ia-docs (path and method exist, required headers are
sent, the request body and the response status and body follow the declared schemas).

Usage: python contract-check.py <openapi-dir> <interactions-dir> [--only <contract.yaml> ...]
Exit code 1 when any interaction breaks its contract.
"""
import json, os, re, sys
import yaml
from jsonschema import Draft4Validator, FormatChecker

openapi_dir, interactions_dir = sys.argv[1], sys.argv[2]
only = set(sys.argv[sys.argv.index("--only") + 1:]) if "--only" in sys.argv else None
_cache = {}

def load(path):
    path = os.path.normpath(path)
    if path not in _cache:
        _cache[path] = yaml.safe_load(open(path, encoding="utf-8"))
    return _cache[path]

def resolve(node, base, seen=()):
    """Inline $ref (also across files) and turn OpenAPI 3.0 `nullable` into JSON Schema."""
    if isinstance(node, list):
        return [resolve(n, base, seen) for n in node]
    if not isinstance(node, dict):
        return node
    if "$ref" in node:
        ref = node["$ref"]; file, _, pointer = ref.partition("#")
        target = os.path.join(os.path.dirname(base), file) if file else base
        if (target, pointer) in seen:
            return {}
        doc = load(target)
        for part in [p for p in pointer.split("/") if p]:
            doc = doc[part.replace("~1", "/").replace("~0", "~")]
        return resolve(doc, target, seen + ((target, pointer),))
    out = {k: resolve(v, base, seen) for k, v in node.items()}
    if out.pop("nullable", False) and "type" in out:
        out["type"] = [out["type"], "null"]
        if "enum" in out:
            out["enum"] = list(out["enum"]) + [None]
    return out

def operation(spec_path, method, path):
    spec = load(spec_path)
    for template, item in spec["paths"].items():
        regex = "^" + re.sub(r"\{[^/]+\}", "[^/]+", template) + "$"
        if re.match(regex, path) and method.lower() in item:
            op = resolve(item[method.lower()], spec_path)
            params = resolve(item.get("parameters", []), spec_path) + op.get("parameters", [])
            return template, op, params
    return None, None, None

def validate(schema, value):
    return [f"{'/'.join(map(str, e.path)) or '(root)'}: {e.message}"
            for e in Draft4Validator(schema, format_checker=FormatChecker()).iter_errors(value)]

failures = 0
for name in sorted(os.listdir(interactions_dir)):
    if not name.endswith(".json"):
        continue
    for it in json.load(open(os.path.join(interactions_dir, name), encoding="utf-8")):
        if only and it["contract"] not in only:
            continue
        spec_path = os.path.join(openapi_dir, it["contract"])
        label = f"{it['consumer']} -> {it['provider']}: {it['method']} {it['path']} ({it['response']['status']})"
        template, op, params = operation(spec_path, it["method"], it["path"])
        problems = []
        if op is None:
            problems.append("path and method are not in the contract")
        else:
            sent = {h.lower() for h in it.get("request", {}).get("headers", {})}
            for p in params:
                if p.get("in") == "header" and p.get("required") and p["name"].lower() not in sent:
                    problems.append(f"required header {p['name']} not sent")
            body = it.get("request", {}).get("body")
            if body is not None:
                schema = op.get("requestBody", {}).get("content", {}).get("application/json", {}).get("schema")
                problems += [f"request {m}" for m in validate(schema, body)] if schema else ["request body not declared"]
            status = str(it["response"]["status"])
            declared = op.get("responses", {})
            response = declared.get(status) or declared.get("default")
            if response is None:
                problems.append(f"status {status} not declared (declared: {', '.join(declared)})")
            elif it["response"].get("body") is not None:
                content = response.get("content", {})
                schema = (content.get("application/json") or next(iter(content.values()), {})).get("schema")
                if schema:
                    problems += [f"response {m}" for m in validate(schema, it["response"]["body"])]
        failures += bool(problems)
        print(("PASS  " if not problems else "FAIL  ") + label + (f"  [{template}]" if template else ""))
        for p in problems:
            print("        - " + p)
print(f"{'contract broken' if failures else 'all interactions follow their contracts'} ({failures} failing)")
sys.exit(1 if failures else 0)
