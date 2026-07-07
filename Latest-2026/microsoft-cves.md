# Microsoft CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-19 · Items: 1_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-21709 | 2026-04-19 | Windows Driver Signature Enforcement Bypass | medium | unknown | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-21709) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-21709** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-21709)

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

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-21709)

---

## Items

## 2026-04-19

### Windows Driver Signature Enforcement Bypass — `CVE-2026-21709`
- **Tags:** `#privesc` `#auth-bypass`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-21709)

- **What:** A local administrator can bypass Windows Driver Signature Enforcement (DSE) to load unsigned drivers.
- **Why it matters:** Enables attackers to load malicious kernel-mode code (rootkits/BYOVD) for persistence or defense evasion after gaining admin access.
- **Hunt signal:** pass
- **Evidence:** [source] NVD listing confirms the bypass capability. [opinion] Critical for post-exploitation phases but limited by the requirement for existing admin privileges.

---
