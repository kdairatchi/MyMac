# Jetbrains CVEs

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
| CVE-2026-41153 | 2026-04-19 | JetBrains Junie RCE via Project File | critical | poc | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-41153) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-41153** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-41153)

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

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-41153)

---

## Items

## 2026-04-19

### JetBrains Junie RCE via Project File — `CVE-2026-41153`
- **Tags:** `#rce`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-41153)

- **What:** JetBrains Junie before build 252.549.29 allows arbitrary command execution when loading a malicious project file.
- **Why it matters:** Developers can be compromised simply by opening a shared or downloaded project, leading to host takeover.
- **Hunt signal:** pass (file-based interaction required).
- **Evidence:** [NVD] confirms RCE via project file manipulation.

---
