# Solarwinds CVEs

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

- [labs.watchtowr.com](https://labs.watchtowr.com/buy-a-help-desk-bundle-a-remote-access-solution-solarwinds-web-help-desk-pre-auth-rce-chain-s/)

---

## Items

## 2026-04-16

### SolarWinds Web Help Desk Pre-Auth RCE Chain

- **Tags:** `#rce` `#auth-bypass`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/buy-a-help-desk-bundle-a-remote-access-solution-solarwinds-web-help-desk-pre-auth-rce-chain-s/)

- **What:** A pre-authentication Remote Code Execution vulnerability chain discovered in SolarWinds Web Help Desk.
- **Why it matters:** Unauthenticated RCE allows attackers to completely compromise the help desk server and pivot internally without credentials.
- **Hunt signal:** Scan for SolarWinds Web Help Desk instances and verify patch status against WatchTowr's findings.
- **Evidence:** [source] WatchTowr Labs blog details the 0-day discovery · [opinion] High-value target for initial access in enterprise environments.

---
