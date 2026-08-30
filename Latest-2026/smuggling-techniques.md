# Smuggling Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: — · Items: 0_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

_No CVE-assigned items yet. Items below are pre-CVE or class-level findings._

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

_No PoCs in items yet._

---

## Reproduction

_Step-by-step repro steps per CVE. Populated as items arrive with enough detail._
_pending enrichment_

---

## Defense

_Patch guidance and detection rules. Populated from vendor advisories._
_pending enrichment_

---

## References

_Populated by daily refresh-latest pipeline._

---

## Items

> HTTP request smuggling — exploiting parsing discrepancies between front-end proxies and back-end servers to desynchronize the connection and poison subsequent requests.

## Surface

- Any site behind a reverse proxy or CDN (Cloudflare, Nginx, HAProxy, Varnish, AWS ALB)
- Load-balanced applications where front-end and back-end disagree on body length
- HTTP/1.1 endpoints — `Transfer-Encoding: chunked` vs `Content-Length` ambiguity
- HTTP/2 downgrade scenarios — H2.CL and H2.TE
- WebSocket upgrade paths and HTTP/2 cleartext (h2c) upgrade requests

## Test Approach

1. **Detect with timing** — CL.TE: send a request where CL says body is complete but TE has a leftover chunk; if 10s+ delay, likely vulnerable:

   ```
   POST / HTTP/1.1
   Host: target.com
   Content-Length: 6
   Transfer-Encoding: chunked

   0

   X
   ```

2. **Confirm with differential response** — smuggle a partial request, send a normal follow-up, check if it gets garbled:

   ```
   POST / HTTP/1.1
   Host: target.com
   Content-Length: 49
   Transfer-Encoding: chunked

   e
   q=smuggling&x=
   0

   GET /404-doesnt-exist HTTP/1.1
   X-Foo: x
   ```

3. **Use HTTP Request Smuggler** (Burp extension) — automated detection of CL.TE, TE.CL, TE.TE, H2.CL, H2.TE
4. **H2.CL smuggling** — HTTP/2 request with `content-length` header forcing back-end to read extra bytes:
   - Use Burp's HTTP/2 raw editor to inject `content-length: <wrong value>`
5. **Test header obfuscation** for TE.TE:

   ```
   Transfer-Encoding: xchunked
   Transfer-Encoding: chunked
   Transfer-Encoding : chunked
   Transfer-Encoding[tab]: chunked
   ```

6. **Exploit: poison next user's request** — prepend a malicious partial request that modifies the next victim's headers

## Tools

- **HTTP Request Smuggler** (Burp extension) — automated CL.TE/TE.CL/H2.CL/H2.TE detection
- **Smuggler.py** — CLI smuggling prober: `python3 smuggler.py -u https://target.com`
- **turbo-intruder** — high-speed parallel requests for timing-based confirmation
- **nuclei** — smuggling detection templates: `nuclei -t http-request-smuggling/ -u https://target.com`

## Payloads / Probes

```http
# CL.TE timing probe
POST / HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 4
Transfer-Encoding: chunked

1
A
X

# TE.CL confirmation
POST / HTTP/1.1
Host: target.com
Content-Length: 3
Transfer-Encoding: chunked

8
SMUGGLED
0


# TE.TE obfuscation variants
Transfer-Encoding: chunked, chunked
X-Transfer-Encoding: chunked
Transfer-encoding: chunked

# H2.CL (HTTP/2 — inject via Burp raw editor)
:method POST
content-length: 0
# Body contains injected CL mismatch
```

## Chain Opportunities

- **Smuggling → cache poisoning** — poison CDN cache with malicious response served to other users
- **Smuggling → request capture** — steal other users' cookies/tokens from absorbed requests
- **Smuggling → auth bypass** — prepend headers that bypass front-end access controls
- **Smuggling → reflected XSS escalation** — turn self-XSS into cross-user XSS
- **H2.TE → WebSocket hijack** — inject into upgrade path

## Recent Intel

- **HTTP/1.1 must die** · CL.TE/TE.CL vulnerabilities persist despite years of mitigations; defenses are bypassable, migration to HTTP/2+ is the only real fix · https://portswigger.net/research/http1-must-die
- **HTTP Anomaly Rank** · Burp research tool using statistical deviation to auto-triage smuggling/desync responses in large-scale fuzzing · https://portswigger.net/research/introducing-http-anomaly-rank
- **H2.CL smuggling (2023)** · HTTP/2 cleartext downgrade exploited in multiple CDN configurations; HAProxy + Nginx combinations particularly prone to H2.TE variants


## 2026-04-19 — H1 disclosures

### HTTP/1.1 Response Desynchronization via conflicting CL/TE headers in Proxy CONNECT

- **2026-03-25** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3623064](https://hackerone.com/reports/3623064) · Reporter: [@3lcarry](https://hackerone.com/3lcarry) · Team: [curl](https://hackerone.com/curl)
- CWE: HTTP Request Smuggling

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---


## 2026-07-01 — H1 disclosures

### Improper Input Validation — HTTP Response Parser Unconditionally Accepts Bare CR in Status Line

- **2026-07-01** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3648681](https://hackerone.com/reports/3648681) · Reporter: [@saif-01](https://hackerone.com/saif-01) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: HTTP Request Smuggling

**What**

The llhttp HTTP response parser in Node.js up to version 24.14.1 (llhttp v9.3.0 and v9.3.1) was found to unconditionally accept a bare carriage return (CR) as a valid response status line terminator. This parsing asymmetry was present in the response path but not in the request parsing, enabling potential HTTP response queue poisoning attacks. The vulnerability was triggered in strict mode without requiring any lenient flags.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Incomplete Suppression of  Transfer-Encoding: chunked Header in HTTP/2 After Redirect From HTTP/1.1

- **2026-06-15** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3793495](https://hackerone.com/reports/3793495) · Reporter: [@unknowperson0212](https://hackerone.com/unknowperson0212) · Team: [curl](https://hackerone.com/curl)
- CWE: HTTP Request Smuggling

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Duplicate chunked Transfer-Encoding lets a malicious origin smuggle a response across reused HTTP proxy connections

- **2026-06-13** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3795615](https://hackerone.com/reports/3795615) · Reporter: [@violet12331](https://hackerone.com/violet12331) · Team: [curl](https://hackerone.com/curl)
- CWE: HTTP Request Smuggling

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---


## 2026-08-30 — H1 disclosures

### HTTP Request Smuggling via Silent Header Truncation in Node.js HTTP Parser

- **2026-08-28** · sev: Low · bounty: undisclosed · cve: CVE-2026-58044
- Source: [hackerone.com/3564941](https://hackerone.com/reports/3564941) · Reporter: [@yushengchen](https://hackerone.com/yushengchen) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: HTTP Request Smuggling

**What**

A flaw in the Node.js HTTP client was discovered that could cause a request desynchronization for Node.js-based forwarding proxies. The issue was caused by the Node.js HTTP parser omitting headers beyond the configured limit from the visible request headers, while still using those headers internally for HTTP message framing. This vulnerability was found to affect all supported Node.js release lines.

**PoC refs:** search `github.com/search?q=CVE-2026-58044` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-58044.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### HTTP Request Smuggling via Connection: close<TAB> in Node.js llhttp parser

- **2026-07-31** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3723248](https://hackerone.com/reports/3723248) · Reporter: [@nadav0077](https://hackerone.com/nadav0077) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: HTTP Request Smuggling

**What**

A vulnerability was discovered in the Node.js HTTP server where it ignores the "Connection: close" header when the token is followed by a tab character. This allows an attacker to send a second request on the same connection, even after the first request should have closed the connection.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

## 2026-08-30

### CRLF-Powered Desync Attacks — Beheading HTTP Streams
- **Tags:** `#smuggling` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/crlf-powered-desync-attacks)

**CRLF-Powered Desync Attacks — Beheading HTTP Streams** — CRLF injection in HTTP headers is far more dangerous than open-redirect/XSS; it enables full request desync by injecting stray CR/LF bytes that split and misalign the HTTP stream between frontend and backend servers, letting attackers "behead" requests and hijack downstream parsing. Hunt: inject `%0d%0a` sequences into any user-controlled header value (Host, X-Forwarded-*, custom headers) and observe differential timing or unexpected response framing that indicates backend stream desync. [PortSwigger Research](https://portswigger.net/research/crlf-powered-desync-attacks)

---
