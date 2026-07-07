# Prasathmani CVEs

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
| CVE-2026-6496 | 2026-04-19 | TinyFileManager <= 2.6 Path Traversal via file[] | high | poc | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-6496) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-6496** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-6496)

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

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-6496)

---

## Items

## 2026-04-19

### TinyFileManager <= 2.6 Path Traversal via file[] — `CVE-2026-6496`
- **Tags:** `#path-traversal` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-6496)

- **What:** A path traversal vulnerability in the `file[]` POST parameter of `/filemanager.php` allows reading arbitrary files.
- **Why it matters:** Public exploits are available, enabling attackers to exfiltrate sensitive configuration files or source code.
- **Hunt signal:** POST `file[]=../../../etc/passwd` to `/filemanager.php` and inspect response for file contents.
- **Evidence:** [source] NVD confirms the flaw affects the POST Parameter Handler in versions up to 2.6. [opinion] A strong primitive for chaining, particularly if log poisoning or file write features exist.

---
