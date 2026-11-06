"""Records real consumer interactions against running services, as the consumers make them
(same method, path and headers), and writes them for contract-check.py. Tokens are never
written. Usage: python capture.py <out-dir> <document-api-url> <professional-api-url>
Tokens come from the environment: SERVICE_TOKEN (sub worker), PATIENT_TOKEN, ADMIN_TOKEN.
"""
import json, os, sys, uuid, urllib.request, urllib.error

out, doc, prof = sys.argv[1], sys.argv[2].rstrip("/"), sys.argv[3].rstrip("/")
TOKENS = {k: os.environ[k] for k in ("SERVICE_TOKEN", "PATIENT_TOKEN", "ADMIN_TOKEN")}

def call(base, prefix, method, path, token, body=None, headers=None):
    h = {"Authorization": "Bearer " + TOKENS[token], "X-Correlation-Id": "contract-" + uuid.uuid4().hex[:8]}
    h.update(headers or {})
    data = None
    if body is not None:
        data = json.dumps(body).encode(); h["Content-Type"] = "application/json"
    # The contract root "/" is the collection itself: the portals call it without a trailing slash.
    url = base + prefix + ("" if path == "/" else path)
    req = urllib.request.Request(url, data=data, method=method, headers=h)
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            status, raw = r.status, r.read()
    except urllib.error.HTTPError as e:
        status, raw = e.code, e.read()
    shown = {k: ("Bearer <redacted>" if k == "Authorization" else v) for k, v in h.items()}
    resp = json.loads(raw) if raw else None
    return {"method": method, "path": path, "request": {"headers": shown, "body": body},
            "response": {"status": status, "body": resp}}

def save(name, consumer, provider, contract, items):
    for i in items:
        i.update({"consumer": consumer, "provider": provider, "contract": contract})
    json.dump(items, open(os.path.join(out, name), "w", encoding="utf-8"), indent=2, ensure_ascii=False)
    for i in items:
        print(f"{consumer} -> {provider} {i['method']} {i['path']} -> {i['response']['status']}")

# telemed-ia-worker -> document-service: the call made for PostConsultationSummaryGenerated.
event_id = str(uuid.uuid4()); summary = str(uuid.uuid4()); patient = "b0000000-0000-4000-8000-000000000001"
gen = {"summaryId": summary, "patientId": patient}
first = call(doc, "/api/documents", "POST", "/generate", "SERVICE_TOKEN", gen, {"Idempotency-Key": event_id})
again = call(doc, "/api/documents", "POST", "/generate", "SERVICE_TOKEN", gen, {"Idempotency-Key": event_id})
save("worker-to-document-service.json", "telemed-ia-worker", "document-service", "document-service.yaml", [first, again])

# document-generation-portal -> document-service: list, detail and download of the patient.
doc_id = first["response"]["body"]["id"]
save("document-portal-to-document-service.json", "telemed-ia-document-generation-portal", "document-service",
     "document-service.yaml", [
         call(doc, "/api/documents", "GET", "/", "PATIENT_TOKEN"),
         call(doc, "/api/documents", "GET", f"/{doc_id}", "PATIENT_TOKEN"),
         call(doc, "/api/documents", "GET", f"/{doc_id}/download", "PATIENT_TOKEN"),
     ])

# professional-management-portal -> professional-service: list, unknown detail, status change
# of an unknown profile, and a registration while identity is not reachable.
missing = str(uuid.uuid4())
reg = {"fullName": "Contract Check", "email": f"contract{uuid.uuid4().hex[:6]}@example.test",
       "identityDocument": "9" + uuid.uuid4().hex[:8].translate(str.maketrans("abcdef", "123456")),
       "password": "Contract-Check-2026", "licenseNumber": "CC-" + uuid.uuid4().hex[:6], "yearsExperience": 3}
save("professional-portal-to-professional-service.json", "telemed-ia-professional-management-portal",
     "professional-service", "professional-service.yaml", [
         call(prof, "/api/professionals", "GET", "/", "ADMIN_TOKEN"),
         call(prof, "/api/professionals", "GET", f"/{missing}", "ADMIN_TOKEN"),
         call(prof, "/api/professionals", "PATCH", f"/{missing}/status", "ADMIN_TOKEN", {"status": "INACTIVE"}),
         call(prof, "/api/professionals", "POST", "/admin/register", "ADMIN_TOKEN", reg,
              {"Idempotency-Key": "contract-" + uuid.uuid4().hex}),
     ])
