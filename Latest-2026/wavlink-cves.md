# wavlink-cves


## 2026-04-20

### Wavlink WL-WN579A3 Hostname XSS — `CVE-2026-6559`
- **Tags:** `#xss` `#appliance`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 15.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-6559)

- **What:** Stored Cross-Site Scripting (XSS) in the `Hostname` parameter of the `/cgi-bin/login.cgi` endpoint.
- **Why it matters:** Remote attackers can inject malicious scripts into the login interface, potentially hijacking administrator sessions or performing actions on behalf of the admin.
- **Hunt signal:** `curl -X POST http://target/cgi-bin/login.cgi -d "Hostname=<script>alert(1)</script>"`
- **Evidence:** [source] NVD lists the vulnerability in function `sub_401F80` of the login CGI. [opinion] Common appliance web flaw; useful for persistence if chained with an auth bypass.

---

## 2026-07-01

### Wavlink router command injection via wireless.cgi POST params — `CVE-2026-13538`
- **Tags:** `#command-injection` `#web` `#appliance`
- **Severity:** critical · **Hunt:** 2/5 · **Score:** 27.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13538)

- **What:** Remote command injection in Wavlink WL-NU516U1-A router through POST parameters SSID2G2/SSID5G2/AuthMethod2/WPAPSK12 in /cgi-bin/wireless.cgi
- **Why it matters:** RCE on a SOHO router appliance with a publicly disclosed exploit; ideal for botnet recruitment and network pivot
- **Hunt signal:** POST /cgi-bin/wireless.cgi with SSID2G2=`;id;` or WPAPSK12 backtick injection; scan for exposed Wavlink management on :80/:443/:8080
- **Evidence:** [source] NVD CVE-2026-13538 · [opinion] Vendor patched quickly but SOHO routers rarely get field updates — unpatched instances will persist for years

---
