# wikimedia-cves


## 2026-07-01

### CVE-2026-14358 — Stored XSS in Mediawiki Charts Extension — `CVE-2026-14358`
- **Tags:** `#xss` `#web`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-14358)

- **What:** Stored cross-site scripting in the Mediawiki Charts Extension due to improper input neutralization during web page generation.
- **Why it matters:** Stored XSS in a wiki extension can persist across page views, enabling session hijacking or account takeover of editors/admins on public-facing instances.
- **Hunt signal:** Find Mediawiki instances running Charts Extension versions < 1.43.9 / 1.44.6 / 1.45.4, inject chart markup with XSS payloads, check for reflection.
- **Evidence:** [NVD] Patched in 1.43.9, 1.44.6, 1.45.4 · [opinion] Low-hanging fruit on unpatched public wikis, but limited to sites with the Charts extension enabled

---
