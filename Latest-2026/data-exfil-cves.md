# Data Exfil CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-16 · Items: 2_

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

- [labs.watchtowr.com](https://labs.watchtowr.com/stop-putting-your-passwords-into-random-websites-yes-seriously-you-are-the-problem/)

---

## Items

## 2026-04-16

### Stop Putting Your Passwords Into Random Websites

- **Tags:** `#data-exfil` `#web` `#supply-chain`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** itw · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/stop-putting-your-passwords-into-random-websites-yes-seriously-you-are-the-problem/)

### Stop Putting Your Passwords Into Random Websites — data-exfil

- **What:** Researchers identified vast quantities of exposed passwords, secrets, and keys publicly accessible on the web.
- **Why it matters:** Publicly exposed credentials allow for immediate account takeover, lateral movement, and supply chain compromise.
- **Hunt signal:** `dork: intext:"password" ext:env OR ext:log filetype:log -git`
- **Evidence:** [watchtowr_labs] analysis confirms sensitive credentials are widely exposed ... · [opinion] Users must stop reusing passwords across platforms.

---
