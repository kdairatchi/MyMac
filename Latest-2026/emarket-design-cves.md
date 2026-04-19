# emarket-design-cves


## 2026-04-17

### Emarket-design YouTube Showcase Stored XSS — `CVE-2025-15636`
- **Tags:** `#xss` `#web`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2025-15636)

- **What:** Stored XSS vulnerability in Emarket-design YouTube Showcase plugin through version 3.5.1.
- **Why it matters:** Enables persistent script execution which can hijack admin sessions or deface sites.
- **Hunt signal:** Fingerprint for plugin version < 3.5.2 and test inputs in showcase fields.
- **Evidence:** [source] NVD confirms improper neutralization of input allows stored XSS.

---
