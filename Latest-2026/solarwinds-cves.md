# solarwinds-cves


## 2026-04-16

### SolarWinds Web Help Desk Pre-Auth RCE Chain
- **Tags:** `#rce` `#auth-bypass`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/buy-a-help-desk-bundle-a-remote-access-solution-solarwinds-web-help-desk-pre-auth-rce-chain-s/)

### SolarWinds Web Help Desk Pre-Auth RCE Chain — rce
- **What:** A pre-authentication Remote Code Execution vulnerability chain discovered in SolarWinds Web Help Desk.
- **Why it matters:** Unauthenticated RCE allows attackers to completely compromise the help desk server and pivot internally without credentials.
- **Hunt signal:** Scan for SolarWinds Web Help Desk instances and verify patch status against WatchTowr's findings.
- **Evidence:** [source] WatchTowr Labs blog details the 0-day discovery · [opinion] High-value target for initial access in enterprise environments.

---
