# Trezor CVEs

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
| CVE-2025-69893 | 2026-04-16 | Side-channel vulnerability in Trezor hardware wallets | high | poc | [src](https://nvd.nist.gov/vuln/detail/CVE-2025-69893) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2025-69893** — [source](https://nvd.nist.gov/vuln/detail/CVE-2025-69893)

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

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2025-69893)

---

## Items

## 2026-04-16

### Side-channel vulnerability in Trezor hardware wallets — `CVE-2025-69893`

- **Tags:** `#auth-bypass` `#physical-access` `#data-exfil` `#hardware` `#wallet`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 10.5 · **Status:** poc · **Age:** 30d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2025-69893)

- **What:** Side-channel vulnerability in Trezor hardware wallets allowing mnemonic recovery via physical access during setup.
- **Why it matters:** Attackers can steal cryptocurrency assets by recovering mnemonic codes through DL-SCA.
- **Hunt signal:** Monitor for side-channel attacks during device initialization sequences.
- **Evidence:** [NVD] ... · [opinion] High-risk physical attack vector against critical infrastructure.

---
