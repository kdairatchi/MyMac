# Privesc Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-17 · Items: 2_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2024-54529 | 2026-04-17 | Exploiting CoreAudio Type Confusion | critical | poc | [src](https://projectzero.google/2026/01/sound-barrier-2.html) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2024-54529** — [source](https://projectzero.google/2026/01/sound-barrier-2.html)

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

- [projectzero.google](https://projectzero.google/2026/01/sound-barrier-2.html)
- [projectzero.google](https://projectzero.google/2026/02/gphfh-deep-dive.html)
- [projectzero.google](https://projectzero.google/2026/02/windows-administrator-protection.html)
- [projectzero.google](https://projectzero.google/2026/26/windows-administrator-protection.html)

---

## Items

## 2026-04-17

### Exploiting CoreAudio Type Confusion — `CVE-2024-54529`

- **Tags:** `#privesc` `#rce`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://projectzero.google/2026/01/sound-barrier-2.html)

**Exploiting CoreAudio Type Confusion** — Details the weaponization of a type confusion bug in the coreaudiod Mach service, turning a crash into a functional exploit. Hunt: Verify macOS build/version against patch status for CVE-2024-54529; no remote detection. [src](https://projectzero.google/2026/01/sound-barrier-2.html)

---

### GetProcessHandleFromHwnd API Deep Dive

- **Tags:** `#privesc` `#auth-bypass`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://projectzero.google/2026/02/gphfh-deep-dive.html) · [2](https://projectzero.google/2026/02/windows-administrator-protection.html) · [3](https://projectzero.google/2026/26/windows-administrator-protection.html)

**GetProcessHandleFromHwnd API Deep Dive** — Analysis of the Win32k kernel implementation revealing it bypasses documented UIAccess restrictions, allowing UAC bypass and handle leakage across different user contexts. Hunt: Test by calling GetProcessHandleFromHwnd from a UIAccess process targeting a higher-integrity HWND to verify handle leakage. [src](https://projectzero.google/2026/02/gphfh-deep-dive.html)

---
*Clustered 3 sources for this item.*


## 2026-04-19 — H1 disclosures

### [Vertical Privilege Escalation] User can Unapproved any Approved Translation at [/translations/unapprove/]

- **2026-04-10** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3020021](https://hackerone.com/reports/3020021) · Reporter: [@adilnbabras](https://hackerone.com/adilnbabras) · Team: [Mozilla](https://hackerone.com/mozilla)
- CWE: Privilege Escalation

**What**

A vulnerability was discovered in the Pontoon web application where any logged-in user could unapprove any approved translation, regardless of their privileges. This was due to a logical error in the validation logic, which allowed bypassing the authorization check. The vulnerability could be exploited by intercepting the request to the "/translations/unapprove/" endpoint and modifying the necessary parameters.

**Hunt signal:** Authenticate as lowest-privilege user, POST to any `/approve/`, `/unapprove/`, `/reject/`, or `/publish/` endpoint. Success from non-admin role = missing authorization check.
**Grep:** `rg -n 'login_required' src/ | rg -i '(approve|unapprove|reject|publish)' | rg -v 'permission'`
**Pass-if:** Endpoint returns 403 to low-priv users or uses role-based decorators/middleware.

---

### [Privilege Escalation] User can Pin|Unpin Any Comment on Any Project or Locale

- **2026-03-20** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3025797](https://hackerone.com/reports/3025797) · Reporter: [@adilnbabras](https://hackerone.com/adilnbabras) · Team: [Mozilla](https://hackerone.com/mozilla)
- CWE: Privilege Escalation

**What**

A vulnerability was discovered in the Pontoon application where any user could pin or unpin comments on any project or locale, despite lacking the necessary privileges. This was possible due to the lack of proper access controls in the backend code handling the pin and unpin functionality.

**Hunt signal:** Find comment pin/unpin/toggle endpoints, swap target resource IDs, send POST as low-priv user → check 200 instead of 403.
**Grep:** `rg -n 'def (pin|unpin|toggle).*comment' --type py | rg -v '@(permission|login_required|role)'`
**Nuclei:** `idor`
**Pass-if:** Pin/unpin is a frontend-only feature with no dedicated backend endpoint.

---


## 2026-05-27 — H1 disclosures

### PS4 BD-J privilege escalation using nested JAR

- **2026-04-29** · sev: Medium · bounty: $2,500
- Source: [hackerone.com/3452696](https://hackerone.com/reports/3452696) · Reporter: [@gezine](https://hackerone.com/gezine) · Team: [PlayStation](https://hackerone.com/playstation)
- CWE: Privilege Escalation

**What**

A PS4 vulnerability was discovered in the Blu-ray Disc Java (BD-J) privilege escalation using nested JAR files. The vulnerability was found in the PS4 system software versions 13.00 to the latest version 13.02. The vulnerability was caused by a discrepancy between the security policy's path canonicalization and the actual class loading path. The security policy granted AllPermission to code that appeared to be loaded from a trusted directory, while the actual code was loaded from an untrusted nested JAR on the Blu-ray disc. …

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---


## 2026-07-01 — H1 disclosures

### Privilege Escalation – Access to the Alert Subscribers page for users with low privileges

- **2026-07-01** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3353000](https://hackerone.com/reports/3353000) · Reporter: [@bl4ck-](https://hackerone.com/bl4ck-) · Team: [SingleStore](https://hackerone.com/singlestore)
- CWE: Privilege Escalation

**What**

A privilege escalation vulnerability was discovered in the SingleStore Helios alert management system. The vulnerability allowed users with low privileges to access the Alert Subscribers API endpoint and retrieve email addresses and alert severity level preferences of notification subscribers, despite lacking authorization to view this information.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---
