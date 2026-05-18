# cpanel-cves

CVEs and auth bypass patterns in cPanel & WHM.

---

## 2026-04-29 — CVE-2026-41940

### CVE-2026-41940 — cPanel & WHM Authentication Bypass

- **Date:** 2026-04-29 · **Source:** [labs.watchtowr.com](https://labs.watchtowr.com/the-internet-is-falling-down-falling-down-falling-down-cpanel-whm-authentication-bypass-cve-2026-41940/) · **Class:** cve
- **Severity:** Critical (auth bypass) · **Hunt:** 5/5 · **Status:** patched — check unpatched installs
- **Tags:** `#cpanel` `#whm` `#auth-bypass` `#hosting` `#preauth`

- **What:** Pre-authentication bypass in cPanel & WHM. watchTowr full technical writeup dropped 2026-04-29. Auth bypass means no creds needed — direct access to control panel functionality.
- **Why it matters:** cPanel powers millions of shared hosting accounts globally. Any hosted company running cPanel (hosting providers, SMBs managing own servers) is potentially affected. Confirmed bug bounty programs that run cPanel-based hosting infrastructure should be checked. [inference] Given KEV precedent for cPanel (CVE-2023-29489 XSS was widely exploited), this class of vuln gets fast adoption.
- **Hunt signal:** Scope-check for programs with `*.cpanel.*`, `whm.*`, `cpsrvd`, or hosting providers in-scope. Run `curl -s https://target/cpanelwebcall/` — cPanel installations fingerprint easily. Nuclei: check `cves/2026/CVE-2026-41940.yaml`. Grep prior Assetnote research: [cPanel XSS CVE-2023-29489 writeup](https://www.assetnote.io/resources/research/advisory-reflected-cross-site-scripting-in-cpanel-cve-2023-29489) for attack surface pattern.
- **Evidence:** [source] https://labs.watchtowr.com/the-internet-is-falling-down-falling-down-falling-down-cpanel-whm-authentication-bypass-cve-2026-41940/

**Variant hunting targets:**
- Same cPanel version but different endpoints — look for similar bypass patterns in `cpanelwebcall/` or `json-api/` handlers
- WHM equivalent endpoints — cPanel and WHM share auth stack; bypass in one often transfers
- Reseller accounts — if bypass escalates to reseller level, impact is higher
