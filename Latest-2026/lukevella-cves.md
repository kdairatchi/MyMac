# Lukevella CVEs

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
| CVE-2026-6493 | 2026-04-19 | Rallly Reset Password RedirectTo XSS | high | poc | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-6493) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-6493** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-6493)

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

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-6493)

---

## Items

## 2026-04-19

### Rallly Reset Password RedirectTo XSS — `CVE-2026-6493`
- **Tags:** `#xss` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-6493)

- **What:** Reflected XSS via the `redirectTo` parameter in the Rallly reset password form.
- **Why it matters:** Allows attackers to steal password reset tokens or user sessions during the auth recovery flow.
- **Hunt signal:** Check `reset-password` endpoints for `redirectTo` params reflected unsanitized in the DOM.
- **Evidence:** [source] NVD disclosure confirms XSS in `reset-password-form.tsx` ... · [opinion] Auth flow XSS is a high-value target for account takeover.

---
