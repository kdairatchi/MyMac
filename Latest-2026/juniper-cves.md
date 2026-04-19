# Juniper CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-16 · Items: 1_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-21902 | 2026-04-16 | Juniper Junos Evolved CVE-2026-21902 Pre-Auth RCE | critical | poc | [src](https://labs.watchtowr.com/sometimes-you-can-just-feel-the-security-in-the-design-junos-os-evolved-cve-2026-21902-rce/) |
| cve-2026-21902 | 2026-04-16 | Juniper Junos Evolved CVE-2026-21902 Pre-Auth RCE | critical | poc | [src](https://labs.watchtowr.com/sometimes-you-can-just-feel-the-security-in-the-design-junos-os-evolved-cve-2026-21902-rce/) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-21902** — [source](https://labs.watchtowr.com/sometimes-you-can-just-feel-the-security-in-the-design-junos-os-evolved-cve-2026-21902-rce/)

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

- [labs.watchtowr.com](https://labs.watchtowr.com/sometimes-you-can-just-feel-the-security-in-the-design-junos-os-evolved-cve-2026-21902-rce/)

---

## Items

## 2026-04-16

### Juniper Junos Evolved CVE-2026-21902 Pre-Auth RCE — `CVE-2026-21902`

- **Tags:** `#rce` `#auth-bypass` `#appliance`
- **Severity:** critical · **Hunt:** 5/5 · **Score:** 67.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/sometimes-you-can-just-feel-the-security-in-the-design-junos-os-evolved-cve-2026-21902-rce/)

- **What:** An incorrect permission assignment for critical resources in Junos OS Evolved allows unauthenticated remote code execution.
- **Why it matters:** Pre-authenticated RCE on core networking infrastructure (PTX series) grants total network control to attackers.
- **Hunt signal:** Scan for Junos Evolved management interfaces on PTX devices and check for CVE-2026-21902 patch status.
- **Evidence:** [source] WatchTowr Labs details a design flaw in Junos OS Evolved leading to critical resource exposure. · [opinion] A prime example of a design-level vulnerability bypassing standard perimeter defenses.

---
