# smartertools-cves


## 2026-04-16

### SmarterMail Pre-Auth RCE (CVE-2025-52691) — `CVE-2025-52691`
- **Tags:** `#rce` `#auth-bypass` `#web`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/do-smart-people-ever-say-theyre-smart-smartertools-smartermail-pre-auth-rce-cve-2025-52691/)

- **What:** A critical pre-authenticated remote code execution vulnerability in SmarterTools SmarterMail enterprise email server.
- **Why it matters:** Allows unauthenticated attackers to fully compromise the email server and underlying operating system without credentials.
- **Hunt signal:** Scan for SmarterMail instances via HTTP headers (e.g., `Server: SmarterTools`) or favicon hashes and validate against patch status.
- **Evidence:** [source] WatchTowr Labs published a detailed advisory confirming the flaw in late 2025/early 2026 ... · [opinion] Pre-auth RCE in email infrastructure is a high-value target for initial access brokers; patch immediately.

---
### SmarterTools SmarterMail Auth Bypass
- **Tags:** `#auth-bypass`
- **Severity:** critical · **Hunt:** 5/5 · **Score:** 41.25 · **Status:** unknown · **Age:** 5d
- **Sources:** [1](https://labs.watchtowr.com/attackers-with-decompilers-strike-again-smartertools-smartermail-wt-2026-0001-auth-bypass/)

- **What:** Pre-authentication authentication bypass in SmarterTools SmarterMail email server.
- **Why it matters:** Allows unauthenticated attackers to fully compromise email infrastructure, potentially exposing all user data and system controls.
- **Hunt signal:** pass
- **Evidence:** [https://labs.watchtowr.com/attackers-with-decompilers-strike-again-smartertools-smartermail-wt-2026-0001-auth-bypass/] · [opinion] vulnerability details not provided.

---
