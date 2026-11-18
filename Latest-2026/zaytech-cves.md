# Zaytech CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-17 · Items: 1_

---

## What


---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2025-15635 | 2026-04-17 | CSRF in Zaytech Smart Online Order for Clover | medium | unknown | [src](https://nvd.nist.gov/vuln/detail/CVE-2025-15635) |

---

## Probes


---

## PoCs


- **CVE-2025-15635** — [source](https://nvd.nist.gov/vuln/detail/CVE-2025-15635)

---

## Reproduction


---

## Defense


---

## References

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2025-15635)

---

## Items

## 2026-04-17

### CSRF in Zaytech Smart Online Order for Clover — `CVE-2025-15635`

- **Tags:** `#csrf` `#web`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2025-15635)

- **What:** Zaytech Smart Online Order for Clover fails to validate request origins, allowing Cross-Site Request Forgery in versions through 1.6.0.
- **Why it matters:** Attackers can trick authenticated users into performing unintended actions, potentially leading to account takeover or order manipulation.
- **Hunt signal:** pass
- **Evidence:** [source] NVD entry confirms vulnerability affects versions n/a through 1.6.0.

---
