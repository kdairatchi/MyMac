# HTTP Desync — 2025/2026 State of the Art

> Dated: **2026-04-15**. Check PortSwigger Research for anything newer: https://portswigger.net/research

## Primer (beginners)

HTTP smuggling / request-desync = when a frontend and backend disagree on where one request ends and the next begins. Attacker injects trailing bytes; frontend forwards as one message, backend reads as two. Second request runs with the victim's session or bypasses auth.

Classic variants: **CL.TE**, **TE.CL**, **TE.TE** (Kettle, 2019).

## 2022-2024 wave

- **H2.CL / H2.TE** — downgrade smuggling between HTTP/2 frontend and HTTP/1.1 backend (Kettle, 2021)
- **Browser-powered desync** — client-side co-operation (Kettle, 2022)
- **Expect-based smuggling** — header-parser differentials

## 2025 — "0.CL" and the new baseline

James Kettle's **"HTTP/1.1 Must Die"** (Black Hat USA 2025, DEF CON 33) demonstrated:

- **0.CL attacks** — request with no Content-Length/Transfer-Encoding, exploits ambiguity when frontend/backend assume zero-length differently
- **Mass desync on Cloudflare / AWS ALB / Azure Front Door** chains — live demo hit Netflix, AWS, Akamai-fronted sites
- **Response queue poisoning 2.0** — reliable over keep-alive
- **Confirmation:** HTTP/1.1 upstream from any frontend is a systemic risk. HTTP/2 end-to-end is the only safe baseline.

Slides / whitepaper: https://portswigger.net/research (search "Must Die")

## Hunting workflow

1. **Identify frontend/backend pair** — header leaks (`Server`, `Via`, `cf-ray`, `x-amz-cf-id`)
2. **Send probe requests** via Burp HTTP Request Smuggler extension (update to 2025 release)
3. **Test 0.CL first** — shortest payload, highest hit rate in 2025 scans
4. **Validate impact** — cache poisoning, session hijack, auth bypass

## Tooling

- **Burp HTTP Request Smuggler** (Kettle's extension, 2025 update) — has 0.CL probes
- **smuggler.py** (defparam) — CLI, still useful for initial triage
- **h2csmuggler** — upgrade-header smuggling
- **Turbo Intruder** — race/stress testing at scale

## What actually pays in 2026

- Cache poisoning → stored XSS on CDN-fronted login page (critical)
- Queue poisoning → stealing auth headers of next victim (critical)
- WAF bypass via desync (high-medium)

Pure "I can cause 400 errors" findings are N/A now. Chain to concrete impact.

## Defense (know both sides)

- HTTP/2 end-to-end (no HTTP/1.1 upstream)
- Strict header validation at frontend (reject ambiguous CL+TE, reject CL without TE when both present)
- Disable keep-alive on backend if frontend is HTTP/1.1

---

*Evidence:* Kettle talks at BH/DEF CON are primary source. Everything else inference from those. File rots fast — verify before betting a report on it.
