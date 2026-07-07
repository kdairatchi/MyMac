# hoppscotch-cves


## 2026-07-07

### Hoppscotch Mass Assignment Overwrites JWT_SECRET — Full Takeover — `CVE-2026-50160`
- **Tags:** `#auth-bypass` `#jwt` `#api` `#web`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-50160)

- **What:** Unauthenticated POST /v1/onboarding/config allows mass assignment of JWT_SECRET and SESSION_SECRET via extra body properties, because NestJS ValidationPipe lacks `whitelist: true` and the service iterates unknown keys as InfraConfigEnum entries.
- **Why it matters:** Overwriting JWT_SECRET lets an attacker forge valid tokens for any user including administrators, resulting in full server compromise.
- **Hunt signal:** Find exposed self-hosted Hoppscotch instances that haven't completed onboarding and POST to `/v1/onboarding/config` with `{"JWT_SECRET":"attackerkey"}` — then mint admin JWTs with the known secret.
- **Evidence:** [nvd] Mass assignment on unauth onboarding endpoint overwrites critical InfraConfigEnum keys · [opinion] Narrow window (pre-onboarding / no users) but trivially exploitable and yields complete auth bypass — high value for scanning fresh self-hosted deployments

---
