# Gnu CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-16 · Items: 1_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-32746 | 2026-04-16 | GNU inetutils Telnetd Pre-Auth RCE | critical | poc | [src](https://labs.watchtowr.com/a-32-year-old-bug-walks-into-a-telnet-server-gnu-inetutils-telnetd-cve-2026-32746/) |
| cve-2026-32746 | 2026-04-16 | GNU inetutils Telnetd Pre-Auth RCE | critical | poc | [src](https://labs.watchtowr.com/a-32-year-old-bug-walks-into-a-telnet-server-gnu-inetutils-telnetd-cve-2026-32746/) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2026-32746** — [source](https://labs.watchtowr.com/a-32-year-old-bug-walks-into-a-telnet-server-gnu-inetutils-telnetd-cve-2026-32746/)

---

## Reproduction

_Step-by-step repro steps per CVE. Populated as items arrive with enough detail._
_pending enrichment_

---

## Defense

_Patch guidance and detection rules. Populated from vendor advisories._
_pending enrichment_

---

## References

- [labs.watchtowr.com](https://labs.watchtowr.com/a-32-year-old-bug-walks-into-a-telnet-server-gnu-inetutils-telnetd-cve-2026-32746/)

---

## Items

## 2026-04-16

### GNU inetutils Telnetd Pre-Auth RCE — `CVE-2026-32746`

- **Tags:** `#rce` `#auth-bypass`
- **Severity:** critical · **Hunt:** 5/5 · **Score:** 67.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/a-32-year-old-bug-walks-into-a-telnet-server-gnu-inetutils-telnetd-cve-2026-32746/)

- **What:** A pre-authentication remote code execution vulnerability in GNU inetutils telnetd dating back to 1994.
- **Why it matters:** It enables unauthenticated attackers to completely compromise systems exposing this Telnet daemon, often found in legacy or embedded setups.
- **Hunt signal:** `nmap -p 23 -sV <target> | grep -i "inetutils"`
- **Evidence:** [source] WatchTowr Labs discovery and writeup of the decades-old flaw · [opinion] Underscores the danger of unmaintained legacy network services.

---
