# Wc Lovers CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-17 · Items: 1_

---

## What


---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2025-63029 | 2026-04-17 | WCFM Marketplace SQL Injection (CVE-2025-63029) | high | patched | [src](https://nvd.nist.gov/vuln/detail/CVE-2025-63029) |

---

## Probes


---

## PoCs


- **CVE-2025-63029** — [source](https://nvd.nist.gov/vuln/detail/CVE-2025-63029)

---

## Reproduction


---

## Defense


---

## References

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2025-63029)

---

## Items

## 2026-04-17

### WCFM Marketplace SQL Injection (CVE-2025-63029) — `CVE-2025-63029`

- **Tags:** `#sqli` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2025-63029)

- **What:** SQL injection vulnerability in WC Lovers WCFM Marketplace plugin affecting versions through 3.7.1.
- **Why it matters:** Allows attackers to interfere with database queries, potentially leading to data exfiltration, modification, or server takeover.
- **Hunt signal:** pass
- **Evidence:** [source] NVD confirms improper neutralization of special elements in SQL commands within the plugin.

---
