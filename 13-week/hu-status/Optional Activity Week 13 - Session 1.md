# OPTIONAL ACTIVITY — Week 13 · Session 1

## Security in distributed systems — authn, authz and zero trust

> **Task of the week:** secure your system: authenticate at the edge, validate tokens and
> authorize in each service, secure service-to-service calls, hash secrets, and validate inputs.

This activity documents how the two services I own are secured, and **verifies it with live
probes** against the production-like platform (all TeleMed IA services in containers, real
identity service). The probes run from a throwaway container **inside** the platform network,
so the calls that skip the gateway behave like a compromised neighbour or an SSRF would.
Executed on 2026-10-27: **19 of 20 probes passed; the one that did not is a real finding**
(section 6).

---

## 1. Authentication vs authorization in TeleMed IA

| | Where | How |
|---|---|---|
| **Authentication** (who you are) | Identity & Access | Login returns a JWT signed with **RS256** (private key only in identity). Claims: `sub` (account id), `role` (`PATIENT`, `PROFESSIONAL`, `ADMIN`, `SERVICE`), `iat`, `exp` |
| **Edge check** | API gateway (nginx) | `/api/v1/...` without credentials → `401` before reaching any service; rate limits and timeouts per route |
| **Token validation** | **every service** | each service verifies the RS256 signature with the public key, the algorithm, and `exp`; no database call (stateless) |
| **Authorization** (what you may do) | **in the use case** of each service, not in the controller | e.g. registering a professional requires `ADMIN`; a patient reads only their own documents; the e-mail of a professional is returned only to `ADMIN` |

---

## 2. Zero trust: the network is not a guard

The gateway is the first door, not the only one. Each service is reachable by its neighbours on
the platform network, so **each service authenticates and authorizes every request itself**.

```
internet ─► gateway (401 without token) ─► service (verify RS256 + exp ─► authorize in use case ─► validate input)
                                            ▲
             compromised neighbour / SSRF ──┘  same checks, no shortcut for "internal" callers
```

---

## 3. Service-to-service trust

| Call | Credential | Least privilege |
|---|---|---|
| worker → Document Generation `POST /api/documents/generate` | short-lived **service token** (`role: SERVICE`, `sub: worker`, 10 min, no refresh) from `POST /internal/service-token` with client id + secret | the API accepts `SERVICE` only for clients in `GENERATION_SERVICE_CLIENTS` (default `worker`) |
| Professional Management → identity `POST /internal/accounts` | service token `sub: professional-management` | identity accepts it only for clients in `ACCOUNT_PROVISIONING_CLIENTS` |
| Document Generation → Medical Consultation (read summary) | service token `sub: document-generation` | read-only use |

- Client secrets are injected at run time (`SERVICE_CLIENT_SECRET`), never in code, images or
  `.env.example`; identity stores only their **bcrypt hash**.
- Tokens are cached and renewed 60 s before expiry; a `401` triggers one renewal and one retry.
- Internal endpoints are not routed by the gateway, and the management ports (metrics, health)
  are never published.

---

## 4. Secrets and stored data

| Item | How it is stored |
|---|---|
| User passwords | bcrypt hash, in identity (never in these services) |
| Temporary password of a new professional | passed once to identity over the internal network; never stored, never logged; DTO `toString` excludes it |
| `Idempotency-Key` + request | the key and a **SHA-256 hash** of the request; no password in the hash input |
| Signing key | private key only in identity; services hold the public key (`JWT_PUBLIC_KEY` or `_FILE`) |
| Logs | no e-mail, name, document, password, token or clinical text (log contract, week 11) |

---

## 5. Live probes (results)

```text
## Edge: the gateway
PASS gateway, no token, list professionals                         401
PASS gateway, admin token, list professionals                      200
## Zero trust: calls that bypass the gateway
PASS service, no token                                             401
PASS service, token signed with another key                        401
PASS service, expired token                                        401
PASS service, alg none token                                       401
PASS service, patient token with role edited to ADMIN              401   (signature no longer matches)
PASS document service, no token                                    401
## Authorization in each service
PASS patient registers a professional                              403
PASS professional changes a profile status                         403
PASS patient reads the list                                        200   body has no "email"
PASS admin reads the list                                          200   body has "email"
PASS owner reads her document                                      200
PASS another patient reads that document (IDOR)                    403   (as the contract declares)
PASS another patient downloads that document (IDOR)                403
PASS service token of a client not in the allow-list asks for a PDF 403
FAIL patient asks for a PDF with an empty body                     400   expected 403
## Input validation and error hygiene
PASS id that is not a UUID ("1 OR 1=1")                            400   envelope with traceId, no internals leaked
PASS page size above the limit (1000)                              400
PASS registration without Idempotency-Key                          400
passed 19, failed 1
```

How the tokens for the negative cases were made: a key pair that is not identity's (forged),
`exp` in the past (expired), header `alg: none` with no signature, and a real patient token whose
payload was edited to `role: ADMIN` without re-signing (tampered).

---

## 6. Finding: authorization runs after validation in `POST /api/documents/generate`

- **Observed:** a `PATIENT` who sends an empty body gets `400` with the list of required fields
  (`Idempotency-Key`, `summaryId`, `patientId`) instead of `403`. With a valid body the same
  caller gets `403`, so no document can be created and no data leaks.
- **Why it matters:** an unauthorized caller should learn nothing about an endpoint it may not
  use; the order should be authenticate → authorize → validate. It is low severity (the request
  shape is public in the OpenAPI contract), but it is the pattern behind larger leaks.
- **Action:** added to the security backlog (Session 2, `SEC-05`) with a test that encodes the
  expected `403`.

The other "IDOR" answers are `403`, which the contract declares for a document of another
patient. A `404` would also hide whether the id exists; that trade-off is recorded in the backlog
as a decision for the team, not as a defect.

---

## 7. Defense in depth, layer by layer

| Layer | Controls in place |
|---|---|
| Edge | gateway authentication check, per-route rate limit (burst 20) and connect/read/send timeouts, CORS handled at the gateway |
| Service | RS256 + `exp` validation, authorization in the use case, input validation with field details, `Idempotency-Key` on every creation, error envelope without stack traces |
| Data | one PostgreSQL role per domain (`<domain>_app`, member of `_reader`/`_writer`), no cross-domain foreign keys or writes, PDFs in object storage with short-lived signed URLs (5 min) |

---

## 8. Evidence

| What | Where |
|---|---|
| RS256 validation in each service | [professional-management-api #13](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/13), [document-generation-api #9](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/9) |
| Service tokens and allow-lists | [document-generation-api #25](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/25), [#31](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/31), [professional-management-api #23](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/23) |
| Property-level authorization (e-mail only for ADMIN) | [professional-management-api #39](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/39), [telemed-ia-docs #120](https://github.com/code-corhuila/telemed-ia-docs/pull/120) |
| Patients read only their documents (DEC-004) | [document-generation-api #10](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/10) |
| Contract checks of auth and errors (Anexo C) | [document-generation-api #30](https://github.com/code-corhuila/telemed-ia-document-generation-api/pull/30), [professional-management-api #17](https://github.com/code-corhuila/telemed-ia-professional-management-api/pull/17) |
| Gateway routes | [api-gateway #15](https://github.com/code-corhuila/telemed-ia-api-gateway/pull/15), [#16](https://github.com/code-corhuila/telemed-ia-api-gateway/pull/16) |

---

## 9. Self-check

| # | Question | Answer |
|---|---|---|
| 1 | Authorization is checked… | On every protected action (not only at login) |
| 2 | A JWT is validated by a service by… | Checking its signature and expiry (stateless) |
| 3 | Zero trust means… | Don't trust the network; verify every request, even internal |
| 4 | Service-to-service calls should use… | mTLS or short-lived least-privilege tokens |
| 5 | The #1 web vulnerability class is… | Broken access control (missing authz checks) |
| 6 | An "internal only" endpoint with no auth is… | A serious risk (compromise/SSRF can reach it) |
