# Emarket Design CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-17 · Items: 1_

---

## What


---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2025-15636 | 2026-04-17 | Emarket-design YouTube Showcase Stored XSS | medium | unknown | [src](https://nvd.nist.gov/vuln/detail/CVE-2025-15636) |

---

## Probes


---

## PoCs


- **CVE-2025-15636** — [source](https://nvd.nist.gov/vuln/detail/CVE-2025-15636)

---

## Reproduction


---

## Defense


---

## References

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2025-15636)

---

## Items

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
