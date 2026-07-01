# yzmcms-cves


## 2026-07-01

### YzmCMS siteurl SQL Injection (CVE-2026-13529) — `CVE-2026-13529`
- **Tags:** `#sqli` `#web`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13529)

- **What:** Unauthenticated SQL injection via the `siteurl` argument in `/application/install/index.php` in YzmCMS ≤ 7.5.
- **Why it matters:** Remote SQLi in the installer endpoint could let attackers extract credentials or chain into code execution; the exploit is public and the vendor is unresponsive, meaning unpatched instances remain exposed.
- **Hunt signal:** Probe `GET /application/install/index.php?siteurl=1'+AND+(SELECT+1+FROM+(SELECT+SLEEP(5))a)--+-` and check for delayed response; flag any YzmCMS instance where the install endpoint is still reachable.
- **Evidence:** [source] NVD entry confirms remote exploitation with publicly disclosed PoC · [opinion] attack complexity is rated high so blind/time-based techniques may be required, but installer exposure on forgotten instances makes this highly exploitable in the wild.

---
