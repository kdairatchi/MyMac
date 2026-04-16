# citrix-cves


## 2026-04-16

### Citrix NetScaler Memory Leak & RXSS (CVE-2025-12101) — `CVE-2025-12101`
- **Tags:** `#xss` `#citrix` `#appliance`
- **Severity:** medium · **Hunt:** 3/5 · **Score:** 22.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/is-it-citrixbleed4-well-no-is-it-good-also-no-citrix-netscalers-memory-leak-rxss-cve-2025-12101/)

- **What:** A reflected cross-site scripting (RXSS) vulnerability and memory leak in Citrix NetScaler ADC/Gateway.
- **Why it matters:** While less severe than the RCE-focused "CitrixBleed" series, this flaw allows script execution in the appliance context, posing risks of admin session hijacking or credential theft.
- **Hunt signal:** Check NetScaler management and gateway login pages for parameter reflection without proper encoding or sanitization.
- **Evidence:** [watchtowr_labs] Analysis confirms CVE-2025-12101 is distinct from CitrixBleed but valid, detailing the memory leak and RXSS mechanics.

---
