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


## 2026-11-18 — CVE-2026-119618: Apache HTTP Server mod_http2 Unauthenticated RCE

### Apache mod_http2 Race Condition RCE (CVE-2026-119618)
- **Tags:** `#rce` `#race-condition` `#unauthenticated`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** patched · **Age:** 7d
- **Sources:** [1](https://stack.watch/vuln/CVE-2026-119618/) [2](https://access.redhat.com/security/cve/CVE-2026-119618) [3](https://www.bleepingcomputer.com/news/security/apache-http-server-patches-critical-http-2-remote-code-execution-flaw/)

- **What:** Race condition in `assign_headers()` in mod_http2 corrupts heap memory and enables unauthenticated RCE on Apache HTTP Server 2.4.55–2.4.70 with HTTP/2 enabled.
- **Why it matters:** CVSS 9.8; unauthenticated, no user interaction, low complexity — any public-facing Apache endpoint with HTTP/2 is in scope; fixed in 2.4.71 (released 2026-11-11).
- **Hunt signal:** `curl -sI --http2 https://target/ | grep Server` — look for Apache/2.4.55–2.4.70; verify via `nuclei -t cves/2026/CVE-2026-119618.yaml`
- **KEV status:** Not confirmed in CISA KEV as of 2026-11-18 — verify at https://www.cisa.gov/known-exploited-vulnerabilities-catalog
- **PoC:** None public confirmed as of 2026-11-18 — check https://github.com/search?q=CVE-2026-119618
- **Likely bounty scope:** Programs running own Apache infrastructure (Shopify, Atlassian self-hosted, any self-managed VPS apps); scope research required for SaaS targets.
- **Evidence:** [Red Hat] https://access.redhat.com/security/cve/CVE-2026-119618
