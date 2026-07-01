# gotohttp-cves


## 2026-07-01

### GotoHTTP XSS via sn param in /reg.12x — `CVE-2026-13536`
- **Tags:** `#xss` `#web`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 15.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13536)

- **What:** Reflected XSS in GotoHTTP ≤10.2 through the `sn` argument in the `/reg.12x` endpoint, exploitable remotely.
- **Why it matters:** Public PoC exists, but the vendor downplayed it — claiming the affected URL is never exposed to users in practice and deferred the fix to a future release.
- **Hunt signal:** Check GotoHTTP instances for `/reg.12x?sn=<payload>` reflection; low real-world impact per vendor but worth verifying exposure.
- **Evidence:** [source] NVD entry confirms public exploit disclosure · [opinion] Vendor's dismissive response suggests low practical severity, but reflected XSS on a remote access tool could still chain into session hijacking if an attacker can lure interaction.

---
