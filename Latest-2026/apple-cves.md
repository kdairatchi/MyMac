# apple-cves


## 2026-08-30

### SwiftNIO HTTP/2 Control Char Smuggling Enables Request Smuggling — `CVE-2026-64785`
- **Tags:** `#smuggling` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-64785)

- **What:** Missing validation on inbound HTTP/2 HEADERS frames allows CR, LF, NUL, SP and other control characters to pass through NIOHTTP2's HTTP/2-to-HTTP/1 codec to an HTTP/1.1 backend.
- **Why it matters:** Enables HTTP request smuggling and response splitting on any SwiftNIO-based reverse proxy handling HTTP/2 front-end and HTTP/1.1 back-end — a classic h2c desync vector.
- **Hunt signal:** Probe HTTP/2 endpoints behind SwiftNIO for CR/LF injection in `:path` or `:authority` pseudo-headers; fingerprint `swift-nio-http2 < 1.45.0` in server responses.
- **Evidence:** [NVD] CVE-2026-64785 confirms patch in swift-nio-http2 1.45.0 · [opinion] High-impact for Apple ecosystem targets — any unpatched SwiftNIO gateway proxying to HTTP/1.1 backends is directly exploitable.

---
