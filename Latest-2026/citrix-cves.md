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

## 2026-07-01

### Citrix NetScaler Pre-Auth Memory Overread (CVE-2026-8451) — `CVE-2026-8451`
- **Tags:** `#data-exfil` `#citrix` `#appliance` `#auth-bypass`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/citrixbleed-to-infinity-and-beyond-citrix-netscaler-pre-auth-memory-overread-cve-2026-8451/)

- **What:** Pre-authenticated memory overread in Citrix NetScaler that leaks sensitive process memory — a spiritual successor to CitrixBleed (CVE-2023-4966).
- **Why it matters:** Unauthenticated attackers can exfiltrate session tokens, cookies, and other secrets from a globally widespread enterprise VPN/gateway appliance, enabling full session hijacking without credentials.
- **Hunt signal:** Send a crafted request to NetScaler's VPN endpoint and inspect response body for abnormally large output containing 16-byte hex patterns or raw session cookies leaking past the expected HTTP response boundary.
- **Evidence:** [source] watchtowr labs full technical disclosure · [opinion] History repeats — expect rapid mass-scanning and exploitation mirroring the original CitrixBleed campaign; prioritize patching and session revocation immediately.

---

## 2026-08-30

### Citrix NetScaler Pre-Auth RCE (CVE-2026-8452) — `CVE-2026-8452`
- **Tags:** `#rce` `#citrix` `#appliance`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/youre-back-in-the-room-citrix-netscaler-pre-auth-rce-cve-2026-8452/)

- **What:** Pre-authentication remote code execution vulnerability in Citrix NetScaler, disclosed by watchtowr labs.
- **Why it matters:** Unauthenticated RCE on a widely-deployed perimeter appliance — prime for mass exploitation, echoing Citrix Bleed (CVE-2023-4966) impact levels.
- **Hunt signal:** Scan for exposed NetScaler VPN/login endpoints lacking the August 2026 patch; watch for abnormal child processes or unexpected outbound connections from appliance IPs.
- **Evidence:** [watchtowr_labs] Full writeup with PoC details · [opinion] Expect rapid weaponization given Citrix's history as a high-value perimeter target; CVE ID may be provisional (noted with "?" in original title) — confirm official assignment before long-term filing.

---
