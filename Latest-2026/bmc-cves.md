# BMC CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-16 · Items: 1_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

_No CVE-assigned items yet. Items below are pre-CVE or class-level findings._

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

_No PoCs in items yet._

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

- [labs.watchtowr.com](https://labs.watchtowr.com/thanks-itsms-threat-actors-have-never-been-so-organized-bmc-footprints-pre-auth-remote-code-execution-chains/)

---

## Items

## 2026-04-16

### BMC FootPrints Pre-Auth RCE Chains

- **Tags:** `#rce` `#web`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/thanks-itsms-threat-actors-have-never-been-so-organized-bmc-footprints-pre-auth-remote-code-execution-chains/)

- **What:** Pre-authenticated remote code execution vulnerability chains impacting the BMC FootPrints ITSM platform.
- **Why it matters:** ITSM solutions are high-value targets for ransomware gangs due to their privileged access and sensitive data repositories.
- **Hunt signal:** pass
- **Evidence:** [watchtowr_labs] demonstrates the exploitation chains highlighting the organized interest in ITSM software like BMC, Ivanti, and SolarWinds · [opinion] classify ITSM assets as critical infrastructure requiring immediate patching given the active threat landscape.

---
