# Ivanti CVEs

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
| CVE-2026-1281 | 2026-04-16 | Ivanti EPMM Pre-Auth RCEs (CVE-2026-1281, CVE-2026-1340) | critical | itw | [src](https://labs.watchtowr.com/someone-knows-bash-far-too-well-and-we-love-it-ivanti-epmm-pre-auth-rces-cve-2026-1281-cve-2026-1340/) |
| CVE-2026-1340 | 2026-04-16 | Ivanti EPMM Pre-Auth RCEs (CVE-2026-1281, CVE-2026-1340) | critical | itw | [src](https://labs.watchtowr.com/someone-knows-bash-far-too-well-and-we-love-it-ivanti-epmm-pre-auth-rces-cve-2026-1281-cve-2026-1340/) |
| cve-2026-1281 | 2026-04-16 | Ivanti EPMM Pre-Auth RCEs (CVE-2026-1281, CVE-2026-1340) | critical | itw | [src](https://labs.watchtowr.com/someone-knows-bash-far-too-well-and-we-love-it-ivanti-epmm-pre-auth-rces-cve-2026-1281-cve-2026-1340/) |
| cve-2026-1340 | 2026-04-16 | Ivanti EPMM Pre-Auth RCEs (CVE-2026-1281, CVE-2026-1340) | critical | itw | [src](https://labs.watchtowr.com/someone-knows-bash-far-too-well-and-we-love-it-ivanti-epmm-pre-auth-rces-cve-2026-1281-cve-2026-1340/) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-1281** — [source](https://labs.watchtowr.com/someone-knows-bash-far-too-well-and-we-love-it-ivanti-epmm-pre-auth-rces-cve-2026-1281-cve-2026-1340/)

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

- [labs.watchtowr.com](https://labs.watchtowr.com/someone-knows-bash-far-too-well-and-we-love-it-ivanti-epmm-pre-auth-rces-cve-2026-1281-cve-2026-1340/)

---

## Items

## 2026-04-16

### Ivanti EPMM Pre-Auth RCEs (CVE-2026-1281, CVE-2026-1340) — `CVE-2026-1281`

- **Tags:** `#rce` `#command-injection` `#ivanti`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 36.0 · **Status:** itw · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/someone-knows-bash-far-too-well-and-we-love-it-ivanti-epmm-pre-auth-rces-cve-2026-1281-cve-2026-1340/)

- **What:** Pre-authentication Remote Command Execution vulnerabilities in Ivanti EPMM allow unauthenticated attackers to execute arbitrary Bash commands on the management server.
- **Why it matters:** These flaws are actively exploited in the wild, granting attackers full control over enterprise mobility management infrastructure without credentials.
- **Hunt signal:** Inspect appliance logs for anomalous POST requests to `/mics/` endpoints or suspicious process execution by the `tomcat` user; generic signatures often fail.
- **Evidence:** [source] WatchTowr Labs analysis ... [opinion] continues the trend of critical authentication bypasses in network appliances, requiring immediate isolation.

---

## 2026-07-01

### Ivanti Sentry Pre-Auth OS Command Injection (CVE-2026-10520) — `CVE-2026-10520`
- **Tags:** `#command-injection` `#ivanti` `#appliance`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/more-evidence-that-words-dont-mean-what-we-thought-they-meant-ivanti-sentry-pre-auth-os-command-injection-cve-2026-10520/)

- **What:** Pre-authenticated OS command injection in Ivanti Sentry, allowing unauthenticated remote attackers to execute arbitrary commands on the appliance.
- **Why it matters:** Pre-auth RCE on a perimeter appliance that typically sits at the network edge — no credentials needed, full shell-level impact, classic high-value enterprise target.
- **Hunt signal:** Probe Ivanti Sentry instances for the vulnerable endpoint via crafted HTTP requests matching the injection pattern; look for distinctive response timing or command output artifacts.
- **Evidence:** [source] watchtowr labs published detailed analysis of the vulnerability · [opinion] Ivanti appliances remain consistently fertile ground for critical pre-auth bugs; prioritize patching and external-facing asset audits.

---
