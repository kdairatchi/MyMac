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
