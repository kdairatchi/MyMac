# apache-cves


## 2026-04-20

### Airflow Keycloak OAuth State/PKCE Missing — `CVE-2026-40948`
- **Tags:** `#auth-bypass` `#csrf` `#oauth`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-40948)

- **What:** Missing OAuth state parameter and PKCE in the Keycloak provider allows login-CSRF and session fixation.
- **Why it matters:** An attacker with a realm account can hijack a victim's session to steal stored Airflow Connection credentials.
- **Hunt signal:** Inspect Keycloak login redirects for missing `state` parameter; verify `apache-airflow-providers-keycloak` version < 0.7.0.
- **Evidence:** [NVD] Confirmation that state/PKCE are missing allows session fixation via crafted callback URLs.

---
