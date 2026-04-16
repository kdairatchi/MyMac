# gnu-cves


## 2026-04-16

### GNU inetutils Telnetd Pre-Auth RCE — `CVE-2026-32746`
- **Tags:** `#rce` `#auth-bypass`
- **Severity:** critical · **Hunt:** 5/5 · **Score:** 67.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/a-32-year-old-bug-walks-into-a-telnet-server-gnu-inetutils-telnetd-cve-2026-32746/)

### GNU inetutils Telnetd Pre-Auth RCE — rce
- **What:** A pre-authentication remote code execution vulnerability in GNU inetutils telnetd dating back to 1994.
- **Why it matters:** It enables unauthenticated attackers to completely compromise systems exposing this Telnet daemon, often found in legacy or embedded setups.
- **Hunt signal:** `nmap -p 23 -sV <target> | grep -i "inetutils"`
- **Evidence:** [source] WatchTowr Labs discovery and writeup of the decades-old flaw · [opinion] Underscores the danger of unmaintained legacy network services.

---
