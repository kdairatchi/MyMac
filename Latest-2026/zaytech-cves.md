# Zaytech CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-17 · Items: 1_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2025-15635 | 2026-04-17 | CSRF in Zaytech Smart Online Order for Clover | medium | unknown | [src](https://nvd.nist.gov/vuln/detail/CVE-2025-15635) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2025-15635** — [source](https://nvd.nist.gov/vuln/detail/CVE-2025-15635)

---

## Reproduction

_Step-by-step repro steps per CVE. Populated as items arrive with enough detail._
_pending enrichment_

---

## Defense

_Patch guidance and detection rules. Populated from vendor advisories._
_pending enrichment_

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
