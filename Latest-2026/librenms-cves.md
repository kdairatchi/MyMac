# Librenms CVEs

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
| CVE-2026-30480 | 2026-04-16 | LibreNMS LFI in NFSen Module | high | poc | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-30480) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-30480** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-30480)

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

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-30480)

---

## Items

## 2026-04-16

### LibreNMS LFI in NFSen Module — `CVE-2026-30480`

- **Tags:** `#lfi` `#path-traversal` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 21.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-30480)

- **What:** Authenticated users can include and execute arbitrary PHP files via path traversal in the `nfsen` parameter.
- **Why it matters:** Successful exploitation typically leads to Remote Code Execution (RCE), allowing full server takeover.
- **Hunt signal:** Probe `nfsen.inc.php` with `nfsen=../../../../../etc/passwd` or PHP log inclusion attempts.
- **Evidence:** [source] NVD · [opinion] High impact for internal environments where LibreNMS is often used.

---
