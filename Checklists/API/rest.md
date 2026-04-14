# REST API Checklist

## Discovery

- OpenAPI / Swagger: `/swagger.json`, `/openapi.json`, `/api-docs`, `/v2/api-docs`, `/swagger-ui.html`.
- Postman collections in JS bundles, S3 buckets, GitHub.
- Actuator / management: `/actuator`, `/actuator/env`, `/actuator/heapdump` (Spring Boot).
- Hidden versions: `/v1/`, `/v2/`, `/v3/` — old versions often skip auth fixes.

```bash
ffuf -u https://target.com/FUZZ -w api-endpoints.txt -mc 200,401,403
```

## Authorization

- IDOR on every numeric/UUID id (`/users/123`, `/orders/abc-123`).
- Tenant isolation — `X-Tenant-ID`, `X-Org-ID` header swaps.
- Role downgrades — set `role: "admin"` in PATCH body.
- Mass assignment — POST extra fields (`is_admin`, `verified`, `credits`).

## HTTP verb tampering

- `GET` → `POST`, `PUT`, `PATCH`, `DELETE` on the same endpoint.
- Some WAFs / authz middlewares only check `GET`/`POST`.
- `X-HTTP-Method-Override: DELETE` header on a POST.

```bash
for m in GET POST PUT DELETE PATCH OPTIONS HEAD TRACE; do
  curl -s -o /dev/null -w "%{http_code} $m\n" -X $m https://target.com/api/v1/users/1
done
```

## Idempotency / race

- Retrying PUT/DELETE → double-spend, double-delete.
- Missing `Idempotency-Key` → coupon reuse, balance tampering.
- Race windows on `/transfer`, `/redeem`, `/claim` — see `Cheatsheets/race-conditions.md`.

## Rate limits

- Bypass via header: `X-Forwarded-For: 127.0.0.1`, `X-Real-IP`, `Client-IP`.
- Path tricks: `/api/v1/login` vs `/API/v1/login` vs `/api//v1/login`.
- Remove `User-Agent`, add trailing slash, switch HTTP/1.1 → HTTP/2.

## Input validation

- Type confusion — string where int expected, array where object expected.
- Unicode normalization — `admin` vs `ad\u006din`.
- SSRF in URL params (`callback_url`, `webhook`, `image_url`).
- Path traversal in file-ish params (`file=../../../etc/passwd`).

## JSON-specific

- Duplicate keys: `{"role":"user","role":"admin"}` — different parsers pick different values.
- Extra whitespace / comments for WAF bypass.
- JSON to form-body swap for CSRF attempts.

## Remediation

- Enforce authz at object level, not endpoint level.
- Allowlist mass-assignable fields.
- Central rate limiter keyed by user + endpoint + cost.
- Strict schema validation (OpenAPI, pydantic, zod).

## References

- OWASP API Top 10 (2023) — https://owasp.org/API-Security/
- PortSwigger Academy APIs — https://portswigger.net/web-security/api-testing
