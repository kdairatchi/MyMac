# progress-cves


## 2026-04-16

### Progress ShareFile Pre-Auth RCE Chain (CVE-2026-2699/CVE-2026-2701) — `CVE-2026-2699`
- **Tags:** `#rce` `#web`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/youre-not-supposed-to-sharefile-with-everyone-progress-sharefile-pre-auth-rce-chain-cve-2026-2699-cve-2026-2701/)

- **What:** A pre-authentication Remote Code Execution chain discovered in Progress ShareFile.
- **Why it matters:** Unauthenticated attackers can gain complete control over the ShareFile Storage Zone Controller, posing a severe risk to enterprise file transfer infrastructure.
- **Hunt signal:** Scan for Progress ShareFile instances and test storage zone controller endpoints for unauthenticated file upload or deserialization behaviors.
- **Evidence:** [source] WatchTowr Labs analysis reveals a critical RCE chain (CVE-2026-2699 & CVE-2026-2701) allowing pre-auth system compromise.

---
