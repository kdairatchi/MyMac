# Fortinet CVEs

## 2026-10-17 — CVE-2026-104286: FortiMail Path Traversal + NULL Byte → Unauthenticated File Write / RCE

### CVE-2026-104286 — FortiMail Unauthenticated Path Traversal + Arbitrary File Write

- **Date:** 2026-10-01 · **Source:** [watchtowr.com](https://watchtowr.com/intelligence/fortinet-fortimail-cve-2026-104286-faq/) · **Class:** cve
- **What:** Path traversal combined with NULL byte injection in FortiMail's management interface (HTTP/HTTPS) lets an unauthenticated attacker write arbitrary files to the appliance, enabling root-level RCE; affects 7.2.0–7.2.9, 7.4.0–7.4.8, 7.6.0–7.6.6, 8.0.0–8.0.1; CVSS 9.8, CISA KEV added 2026-10-13, Fortinet advisory FG-IR-26-175.
- **Why it matters:** File write to webroot = shell; no patch available as of KEV addition; workaround is CLI disable of IBE or restrict management access to trusted private networks only.
- **Hunt signal:** Scan FortiMail management ports (8443/443) for traversal patterns; public PoC at `ShadowForge-Cyber/CVE-2026-104286-POC` on GitHub (unverified — test in isolated env); nuclei tag `CVE-2026-104286`
- **Evidence:** [watchtowr FAQ] https://watchtowr.com/intelligence/fortinet-fortimail-cve-2026-104286-faq/ · [truesec] https://www.truesec.com/hub/blog/cve-2026-104286-fortimail-path-traversal-vulnerability-actively-exploited · [tenable] https://www.tenable.com/cve/CVE-2026-104286

---
