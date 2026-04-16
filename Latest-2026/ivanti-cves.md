# ivanti-cves


## 2026-04-16

### Ivanti EPMM Pre-Auth RCEs (CVE-2026-1281, CVE-2026-1340) — `CVE-2026-1281`
- **Tags:** `#rce` `#command-injection` `#ivanti`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 36.0 · **Status:** itw · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/someone-knows-bash-far-too-well-and-we-love-it-ivanti-epmm-pre-auth-rces-cve-2026-1281-cve-2026-1340/)

- **What:** Pre-authentication Remote Command Execution vulnerabilities in Ivanti EPMM allow unauthenticated attackers to execute arbitrary Bash commands on the management server.
- **Why it matters:** These flaws are actively exploited in the wild, granting attackers full control over enterprise mobility management infrastructure without credentials.
- **Hunt signal:** Inspect appliance logs for anomalous POST requests to `/mics/` endpoints or suspicious process execution by the `tomcat` user; generic signatures often fail.
- **Evidence:** [source] WatchTowr Labs analysis ... [opinion] continues the trend of critical authentication bypasses in network appliances, requiring immediate isolation.

---
