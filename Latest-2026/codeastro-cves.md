# Codeastro CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-19 · Items: 1_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-37749 | 2026-04-19 | CodeAstro Attendance SQLi Auth Bypass | critical | poc | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-37749) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-37749** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-37749)

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

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-37749)

---

## Items

## 2026-04-19

### CodeAstro Attendance SQLi Auth Bypass — `CVE-2026-37749`

- **Tags:** `#sqli` `#auth-bypass`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37749)

- **What:** Unauthenticated SQL injection in the username parameter of index.php allows authentication bypass.
- **Why it matters:** Enables remote attackers to gain full administrative access to the system without credentials.
- **Hunt signal:** `' OR 1=1-- -` in username field.
- **Evidence:** [NVD] Confirmed vector in v1.0 · [analysis] Classic boolean-based injection.

---
