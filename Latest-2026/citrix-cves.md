# Citrix CVEs

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
| CVE-2025-12101 | 2026-04-16 | Citrix NetScaler Memory Leak & RXSS (CVE-2025-12101) | medium | poc | [src](https://labs.watchtowr.com/is-it-citrixbleed4-well-no-is-it-good-also-no-citrix-netscalers-memory-leak-rxss-cve-2025-12101/) |
| cve-2025-12101 | 2026-04-16 | Citrix NetScaler Memory Leak & RXSS (CVE-2025-12101) | medium | poc | [src](https://labs.watchtowr.com/is-it-citrixbleed4-well-no-is-it-good-also-no-citrix-netscalers-memory-leak-rxss-cve-2025-12101/) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2025-12101** — [source](https://labs.watchtowr.com/is-it-citrixbleed4-well-no-is-it-good-also-no-citrix-netscalers-memory-leak-rxss-cve-2025-12101/)

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

- [labs.watchtowr.com](https://labs.watchtowr.com/is-it-citrixbleed4-well-no-is-it-good-also-no-citrix-netscalers-memory-leak-rxss-cve-2025-12101/)

---

## Items

## 2026-04-16

### Citrix NetScaler Memory Leak & RXSS (CVE-2025-12101) — `CVE-2025-12101`

- **Tags:** `#xss` `#citrix` `#appliance`
- **Severity:** medium · **Hunt:** 3/5 · **Score:** 22.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/is-it-citrixbleed4-well-no-is-it-good-also-no-citrix-netscalers-memory-leak-rxss-cve-2025-12101/)

- **What:** A reflected cross-site scripting (RXSS) vulnerability and memory leak in Citrix NetScaler ADC/Gateway.
- **Why it matters:** While less severe than the RCE-focused "CitrixBleed" series, this flaw allows script execution in the appliance context, posing risks of admin session hijacking or credential theft.
- **Hunt signal:** Check NetScaler management and gateway login pages for parameter reflection without proper encoding or sanitization.
- **Evidence:** [watchtowr_labs] Analysis confirms CVE-2025-12101 is distinct from CitrixBleed but valid, detailing the memory leak and RXSS mechanics.

---
