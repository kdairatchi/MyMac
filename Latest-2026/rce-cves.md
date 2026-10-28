# rce-cves


## 2026-07-01

### PoC-in-GitHub auto-update 2026-06-29
- **Tags:** `#rce` `#web`
- **Severity:** unknown · **Hunt:** 2/5 · **Score:** 12.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://github.com/nomi-sec/PoC-in-GitHub/commit/d062398fecdf698a2d67270059b143d0d93b2c58) · [2](https://medium.com/@Abhineet.Ayan/anatomy-of-a-shellcode-a-deep-dive-into-runtime-execution-internals-906f51b97d7e) · [3](https://medium.com/@Abhineet.Ayan/the-anatomy-of-shellcode-technical-deconstruction-and-execution-lifecycle-6783fc1524e7?source=rss------infosec-5)

- **What:** Automated commit to the PoC-in-GitHub repository tracking newly published proof-of-concept exploits; specific CVE not disclosed in commit title.
- **Why it matters:** Signals that one or more CVEs now have public PoC code available, raising exploit likelihood from theoretical to practical.
- **Hunt signal:** pass — no specific CVE or target identified in this commit; revisit if correlated CVE surfaces.
- **Evidence:** [source] PoC-in-GitHub auto-update commit · [opinion] Low actionable signal without a specific CVE to pivot on; monitor the repo diff for newly added CVE entries.

---
*Clustered 3 sources for this item.*

## 2026-10-28

### PHP2Shell — CVE-2026-109618 & CVE-2026-109619
- **Date:** 2026-10-28 · **Source:** [theregister.com](https://theregister.com/cyber-crime/2026/10/27/cisa-confirms-php2shell-under-attack-as-researchers-clock-successful-exploits/5305681) · **Class:** cve
- **What:** Out-of-memory corruption in PHP's request initialization via longjmp(); unauthenticated attacker achieves RCE on any PHP-FPM or CLI handler running unpatched PHP.
- **Why it matters:** CISA KEV-listed (Oct 26, deadline Oct 29 for federal). Active exploitation since Oct 21 via honeypots. Ubiquitous target surface — most PHP web apps on shared hosting and cloud still unpatched.
- **Hunt signal:** `httpx -title -tech-detect -H 'X-Powered-By'` for PHP versions < 8.2.35/8.3.36/8.4.27/8.5.12; nuclei tag `cve-2026-109618`
- **Evidence:** [source] TheRegister/CISA KEV confirmation · [Tenable FAQ](https://www.tenable.com/blog/php2shell-cve-2026-109618-cve-2026-109619-frequently-asked-questions-about-critical-php-remote) · [watchTowr](https://watchtowr.com/intelligence/php-cve-2026-109618-faq/)

