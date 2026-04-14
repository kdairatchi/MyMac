# GraphQL Checklist

Endpoint signals: `/graphql`, `/graphiql`, `/api/graphql`, `/v1/graphql`, `/query`. Check `Content-Type: application/json` POST bodies for `query`, `mutation`, `variables`.

## Discovery

```bash
# Known paths
ffuf -u https://target.com/FUZZ -w <(echo "graphql\ngraphiql\napi/graphql\nv1/graphql\nquery\napi/query\ngql\napi/gql") -mc 200,400

# Fingerprint + introspection
graphw00f -t https://target.com/graphql
clairvoyance https://target.com/graphql -o schema.json   # rebuild schema when introspection disabled
```

## Introspection

```bash
curl -s https://target.com/graphql -H 'Content-Type: application/json' \
  -d '{"query":"{__schema{types{name,fields{name,args{name,type{name}}}}}}"}' | jq .
```

- **Open introspection in prod** → info leak. Low alone, fuel for everything else.
- **Disabled introspection** → still try field suggestions (`{ userX }` returns "Did you mean `user`?").
- Use clairvoyance to rebuild schema from suggestions.

## Authorization bugs (highest ROI)

- IDOR by swapping ID in `user(id: "123")` — test across tenants and roles.
- Field-level authz: `User { email, passwordHash, ssn }` — some resolvers forget to check per-field.
- Mutations that skip tenant checks (`updateUser(id, input)`).

## Batching / DoS

- Query batching — one POST with `[{query:...},{query:...}]` — bypasses rate limits per request.
- Alias abuse — 1000 aliases in a single query to brute force (`a1: login(...) a2: login(...)`).
- Nested recursion — `user { posts { author { posts { author { ... } } } } }` — DoS if no depth limit.

## CSRF

- `Content-Type: application/json` blocks simple CSRF, **but** GET-based queries (`/graphql?query=mutation{...}`) are CSRF-able.
- Check if server accepts `application/x-www-form-urlencoded` with query in form body.

## Injection

- SQLi in resolver args — `user(name: "admin' OR 1=1--")`.
- SSRF via URL-accepting fields (`fetchImage(url: ...)`).
- NoSQL injection in `filter: {}` objects.

## PoC template

```
POST /graphql HTTP/1.1
Host: target.com
Content-Type: application/json
Authorization: Bearer <victim-token>

{"query":"query { user(id: \"<victim-id>\") { email, passwordHash } }"}
```

## Remediation

- Disable introspection in prod.
- Enforce authz per resolver, not just per endpoint.
- Depth + complexity limits (graphql-depth-limit, graphql-query-complexity).
- Disable aliases or cap per query.
- Rate-limit at query cost, not request count.

## References

- Dolev Farhi — https://github.com/dolevf/graphql-cop
- escape.tech — https://escape.tech/academy/graphql-api/
- HackTricks GraphQL — https://book.hacktricks.xyz/pentesting-web/graphql
