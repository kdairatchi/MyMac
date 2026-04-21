---
tags: [bugbounty, checklist, methodology, recon]
aliases: [Hunt Checklist, Master Checklist, New Target]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Master Hunt Checklist — New Target

> [!tip] How to use
> Run this checklist on every new target. Columns: `[ ]` = not tested, `[~]` = in progress, `[x]` = done, `[!]` = finding.
> First 2 hours = recon + quick wins. Hours 2–8 = deep dive on interesting surface.

---

## Phase 1 — Scope & Recon (First 30 min)

```
[ ] Read program brief completely — note OOS, special rules, bonus targets
[ ] Parse wildcards: *.target.com → subfinder, assetfinder, chaos
[ ] Run subfinder + assetfinder + dnsx + httpx pipeline
[ ] Check for high-value subdomains: admin.*, api.*, internal.*, staging.*
[ ] Google: site:target.com (get main structure)
[ ] GitHub dorks: org:target-company password token secret key
[ ] Shodan: org:"Target Inc" — find exposed infra
[ ] Check for leaks: dehashed.com, haveibeenpwned API, pastebins
[ ] Identify tech stack (Wappalyzer, headers, cookies)
[ ] Find old versions: web.archive.org/web/*/target.com/*
```

---

## Phase 2 — Quick Wins (30–90 min)

```
[ ] Run nuclei -u https://target.com -t cves/ -t exposures/ -t misconfigs/
[ ] Check for exposed panels: /admin, /phpmyadmin, /.git, /api/docs, /swagger
[ ] Test for open redirect: ?next=, ?url=, ?redirect=, ?return=
[ ] Check robots.txt and sitemap.xml
[ ] Test password reset: Host header injection, param pollution
[ ] Check CORS: curl -H "Origin: https://evil.com" ... and see Access-Control headers
[ ] Check for exposed .env, .git, .htaccess: ffuf -w sensitive_files.txt
[ ] Run gau to collect historical URLs, look for old params/endpoints
[ ] Test for subdomain takeover: check CNAME → dangling targets
[ ] Look for API keys in JS files: gau | grep \.js | js-secret-finder
```

---

## Phase 3 — Authentication Testing (1–2 hours)

```
[ ] Test login: SQLi, default creds, username enumeration (timing/message)
[ ] Test forgot password (see [[../06-checklists/forgot-password]])
[ ] Test registration: existing email, duplicate reg, email param pollution
[ ] Test 2FA: response manipulation, code in response, brute force, skip step
[ ] Test OAuth/SSO: state param, redirect_uri manipulation, PKCE bypass
[ ] Test session management: cookie attributes, token rotation, logout
[ ] Test "remember me" functionality
[ ] Test account lockout (is there a lockout? rate limit?)
```

---

## Phase 4 — Authorization Testing (1–2 hours)

```
[ ] Set up two accounts (A and B)
[ ] Test IDOR on all ID-containing endpoints (see [[../01-vuln/idor]])
[ ] Test horizontal privesc: A's token → B's resources
[ ] Test vertical privesc: user endpoints vs. admin endpoints
[ ] Test parameter-based role: ?role=admin, ?admin=true
[ ] Test unauthenticated access to authenticated endpoints
[ ] Test BFLA (Broken Function Level Authorization): admin functions as user
```

---

## Phase 5 — Injection Testing (2–4 hours)

```
[ ] XSS: all input fields, URL params, headers (User-Agent, Referer)
[ ] SQLi: numeric params, search, filter, login, sort params
[ ] SSRF: URL params, image upload, webhook, import-by-URL (see [[../01-vuln/ssrf]])
[ ] SSTI: template fields, profile names, error messages with variable injection
[ ] XXE: XML upload, SOAP endpoints, SVG upload
[ ] CRLF: any param reflected in response headers
[ ] Open Redirect: redirect/return/next params
[ ] Host header injection: password reset, email templates
[ ] Command injection: server-side file operations, ping features, DNS lookup
```

---

## Phase 6 — File Upload Testing

```
[ ] Find all upload endpoints
[ ] Test: .php, .php5, .phtml, .asp, .aspx upload
[ ] Test: MIME type bypass (change Content-Type to image/jpeg)
[ ] Test: double extension (.php.jpg)
[ ] Test: null byte (.php%00.jpg)
[ ] Test: SVG with XSS payload
[ ] Test: HTML file upload
[ ] Test: ZIP with path traversal inside
[ ] Test: path traversal in filename (../shell.php)
```

---

## Phase 7 — API Testing

```
[ ] Find API docs: /api/docs, /swagger, /openapi.json, /api/v1/
[ ] Test all HTTP methods: GET, POST, PUT, DELETE, PATCH on each endpoint
[ ] Test parameter types: string → number, number → string, null, array, object
[ ] Test mass assignment: add extra fields (role, is_admin, etc.)
[ ] Test GraphQL (if present, see [[../01-vuln/graphql]])
[ ] Test API versioning: /v1/ vs /v2/ — old versions may have less security
[ ] Test rate limiting on auth endpoints
[ ] Test JWT if used (see [[../01-vuln/jwt]])
```

---

## Phase 8 — Business Logic

```
[ ] Map all money flows: cart, coupon, checkout, refund, subscription
[ ] Test negative values: quantity, price, discount
[ ] Test race conditions: coupon use, withdrawal, unique operations
[ ] Test subscription: cancel + access, refund + access
[ ] Test discount codes: reuse, race condition, apply to excluded items
[ ] Test role/plan tampering: cookie/response modification
```

---

## Phase 9 — Chained / Advanced

```
[ ] Chain any open redirect with OAuth
[ ] Chain any SSRF with cloud metadata
[ ] Chain any XSS with CSRF bypass
[ ] Chain any IDOR with email change → ATO
[ ] Test HTTP request smuggling (if load balancer detected)
[ ] Test cache poisoning (if CDN detected: Cloudflare, Varnish, Nginx cache)
[ ] Test WebSocket endpoints
[ ] Test for clickjacking on sensitive actions
```

---

## Quick Command Reference

```bash
# Full recon pipeline
TARGET=target.com
subfinder -d $TARGET -silent | dnsx -silent | httpx -silent -o live_hosts.txt
katana -list live_hosts.txt -jc -d 5 -o endpoints.txt
nuclei -list live_hosts.txt -t ~/nuclei-templates/cves/ -t ~/nuclei-templates/exposures/

# JS secret hunt
cat endpoints.txt | grep "\.js$" | httpx -mc 200 | xargs -I{} curl -s {} | \
  grep -E "(api_key|apikey|secret|token|password|passwd|credential)" -i

# XSS bulk test
cat endpoints.txt | grep "=" | dalfox pipe --silence

# SQLi detection
cat endpoints.txt | grep "=" | gf sqli | sqlmap --batch --level=1

# Open redirect
cat endpoints.txt | grep -E "(next|redirect|url|return|redir)=" | \
  qsreplace "https://evil.com" | httpx -location -mc 301,302,307,308
```

---

## Notes Section

Use this area for target-specific notes during the hunt:
```
Target: 
Program: 
Date: 
Scope: 
Interesting endpoints:
- 
Potential findings:
- 
```
