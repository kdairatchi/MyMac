# Emarket Design CVEs

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
| CVE-2025-15636 | 2026-04-17 | Emarket-design YouTube Showcase Stored XSS | medium | unknown | [src](https://nvd.nist.gov/vuln/detail/CVE-2025-15636) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2025-15636** — [source](https://nvd.nist.gov/vuln/detail/CVE-2025-15636)

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
