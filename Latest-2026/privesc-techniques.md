# Privesc Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-17 · Items: 2_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2024-54529 | 2026-04-17 | Exploiting CoreAudio Type Confusion | critical | poc | [src](https://projectzero.google/2026/01/sound-barrier-2.html) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2024-54529** — [source](https://projectzero.google/2026/01/sound-barrier-2.html)

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

- [projectzero.google](https://projectzero.google/2026/01/sound-barrier-2.html)
- [projectzero.google](https://projectzero.google/2026/02/gphfh-deep-dive.html)
- [projectzero.google](https://projectzero.google/2026/02/windows-administrator-protection.html)
- [projectzero.google](https://projectzero.google/2026/26/windows-administrator-protection.html)

---

## Items

## 2026-04-17

### Exploiting CoreAudio Type Confusion — `CVE-2024-54529`

- **Tags:** `#privesc` `#rce`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://projectzero.google/2026/01/sound-barrier-2.html)

**Exploiting CoreAudio Type Confusion** — Details the weaponization of a type confusion bug in the coreaudiod Mach service, turning a crash into a functional exploit. Hunt: Verify macOS build/version against patch status for CVE-2024-54529; no remote detection. [src](https://projectzero.google/2026/01/sound-barrier-2.html)

---

### GetProcessHandleFromHwnd API Deep Dive

- **Tags:** `#privesc` `#auth-bypass`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://projectzero.google/2026/02/gphfh-deep-dive.html) · [2](https://projectzero.google/2026/02/windows-administrator-protection.html) · [3](https://projectzero.google/2026/26/windows-administrator-protection.html)

**GetProcessHandleFromHwnd API Deep Dive** — Analysis of the Win32k kernel implementation revealing it bypasses documented UIAccess restrictions, allowing UAC bypass and handle leakage across different user contexts. Hunt: Test by calling GetProcessHandleFromHwnd from a UIAccess process targeting a higher-integrity HWND to verify handle leakage. [src](https://projectzero.google/2026/02/gphfh-deep-dive.html)

---
*Clustered 3 sources for this item.*
