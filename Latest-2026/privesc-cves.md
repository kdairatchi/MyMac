# Privesc CVEs

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
| CVE-2026-21733 | 2026-04-19 | GPU Memory Write Permission Bypass | high | unknown | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-21733) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-21733** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-21733)

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

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-21733)

---

## Items

## 2026-04-19

### GPU Memory Write Permission Bypass — `CVE-2026-21733`

- **Tags:** `#privesc`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-21733)

- **What:** Non-privileged users can gain write access to read-only memory via improper GPU system calls.
- **Why it matters:** Breaks memory protection boundaries, allowing potential code execution or data tampering from low-privileged contexts.
- **Hunt signal:** pass
- **Evidence:** [source] NVD entry describes improper GPU memory reservation handling allowing non-privileged users to modify read-only wrapped user-mode memory.

---
