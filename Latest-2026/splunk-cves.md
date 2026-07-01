# splunk-cves


## 2026-07-01

### Splunk Enterprise Pre-Auth RCE (CVE-2026-20253) — `CVE-2026-20253`
- **Tags:** `#rce` `#web` `#appliance`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 52.2 · **Status:** poc · **Age:** 2d
- **Sources:** [1](https://labs.watchtowr.com/why-use-app-level-auth-when-every-database-has-auth-splunk-enterprise-cve-2026-20253-pre-auth-rce/)

- **What:** Pre-auth remote code execution in Splunk Enterprise, bypassing app-level authentication entirely via an exposed database auth path
- **Why it matters:** Unauthenticated attackers gain full RCE on widely-deployed SIEM infrastructure — no credentials needed, and Splunk instances often sit on sensitive network segments with broad data access
- **Hunt signal:** Probe Splunk Enterprise management endpoints (ports 8000/8089) for unauthenticated access to vulnerable endpoints; fingerprint via `/services/server/info`
- **Evidence:** [source] watchtowr labs detailed writeup and PoC · [opinion] critical-severity pre-auth RCE in a core enterprise security product — high-value target given Splunk's privileged position in most environments

---
