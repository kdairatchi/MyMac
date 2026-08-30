# equifax-cves


## 2026-08-30

### Unauth Auth Bypass in Appriss VINE Apps — `CVE-2026-63359`
- **Tags:** `#auth-bypass` `#data-exfil` `#web`
- **Severity:** critical · **Hunt:** 5/5 · **Score:** 45.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-63359)

- **What:** Unauthenticated attacker can bypass the login page on Appriss Insights (Equifax) VINE applications to access other users' credentials, take over accounts, read sensitive PII, and dump database contents.
- **Why it matters:** Full unauth access chain — login bypass leads to credential theft, account takeover, and mass PII/database exfiltration on a victim-notification platform handling sensitive criminal-justice data.
- **Hunt signal:** Probe VINE app login endpoints for auth-bypass patterns (parameter tampering, blank password, JWT manipulation, path-based bypass like `/api/` or `/?skip_auth=1`); look for exposed user-credential or PII endpoints without session validation.
- **Evidence:** [source] NVD entry confirms unauth login bypass → credential access + account takeover + PII + DB dump · [opinion] severity is clearly critical given unauth + full takeover + PII — high-value target for both bug bounty and threat actors; no PoC published yet so first-to-exploit opportunity exists.

---
