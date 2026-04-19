# Progress CVEs

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
| CVE-2026-2699 | 2026-04-16 | Progress ShareFile Pre-Auth RCE Chain (CVE-2026-2699/CVE-202 | critical | poc | [src](https://labs.watchtowr.com/youre-not-supposed-to-sharefile-with-everyone-progress-sharefile-pre-auth-rce-chain-cve-2026-2699-cve-2026-2701/) |
| CVE-2026-2701 | 2026-04-16 | Progress ShareFile Pre-Auth RCE Chain (CVE-2026-2699/CVE-202 | critical | poc | [src](https://labs.watchtowr.com/youre-not-supposed-to-sharefile-with-everyone-progress-sharefile-pre-auth-rce-chain-cve-2026-2699-cve-2026-2701/) |
| cve-2026-2699 | 2026-04-16 | Progress ShareFile Pre-Auth RCE Chain (CVE-2026-2699/CVE-202 | critical | poc | [src](https://labs.watchtowr.com/youre-not-supposed-to-sharefile-with-everyone-progress-sharefile-pre-auth-rce-chain-cve-2026-2699-cve-2026-2701/) |
| cve-2026-2701 | 2026-04-16 | Progress ShareFile Pre-Auth RCE Chain (CVE-2026-2699/CVE-202 | critical | poc | [src](https://labs.watchtowr.com/youre-not-supposed-to-sharefile-with-everyone-progress-sharefile-pre-auth-rce-chain-cve-2026-2699-cve-2026-2701/) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-2699** — [source](https://labs.watchtowr.com/youre-not-supposed-to-sharefile-with-everyone-progress-sharefile-pre-auth-rce-chain-cve-2026-2699-cve-2026-2701/)

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

- [labs.watchtowr.com](https://labs.watchtowr.com/youre-not-supposed-to-sharefile-with-everyone-progress-sharefile-pre-auth-rce-chain-cve-2026-2699-cve-2026-2701/)

---

## Items

## 2026-04-16

### Progress ShareFile Pre-Auth RCE Chain (CVE-2026-2699/CVE-2026-2701) — `CVE-2026-2699`

- **Tags:** `#rce` `#web`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/youre-not-supposed-to-sharefile-with-everyone-progress-sharefile-pre-auth-rce-chain-cve-2026-2699-cve-2026-2701/)

- **What:** A pre-authentication Remote Code Execution chain discovered in Progress ShareFile.
- **Why it matters:** Unauthenticated attackers can gain complete control over the ShareFile Storage Zone Controller, posing a severe risk to enterprise file transfer infrastructure.
- **Hunt signal:** Scan for Progress ShareFile instances and test storage zone controller endpoints for unauthenticated file upload or deserialization behaviors.
- **Evidence:** [source] WatchTowr Labs analysis reveals a critical RCE chain (CVE-2026-2699 & CVE-2026-2701) allowing pre-auth system compromise.

---
