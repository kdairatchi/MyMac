# fortinet-cves


## 2026-04-16

### Fortinet FortiWeb Auth Bypass via Impersonation — `CVE-2025-64446`
- **Tags:** `#auth-bypass` `#fortinet` `#appliance`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/when-the-impersonation-function-gets-used-to-impersonate-users-fortinet-fortiweb-auth-bypass/)

### Fortinet FortiWeb Auth Bypass via Impersonation — auth-bypass
- **What:** A designated administrative "impersonation" function in Fortinet FortiWeb can be leveraged to bypass authentication and take over arbitrary user sessions.
- **Why it matters:** As a central WAF appliance, compromising FortiWeb provides attackers with a privileged position to inspect, modify, or block traffic and potentially pivot to internal networks.
- **Hunt signal:** Scan FortiWeb management interfaces for exposed impersonation endpoints or test for logic flaws that allow switching user contexts without proper validation.
- **Evidence:** [watchtowr_labs] Technical analysis of CVE-2025-64446 revealing the misuse of the impersonation API. · [opinion] Critical vulnerability for perimeter defense appliances; patch immediately if exposed.

---
