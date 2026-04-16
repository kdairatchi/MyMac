# juniper-cves


## 2026-04-16

### Juniper Junos Evolved CVE-2026-21902 Pre-Auth RCE — `CVE-2026-21902`
- **Tags:** `#rce` `#auth-bypass` `#appliance`
- **Severity:** critical · **Hunt:** 5/5 · **Score:** 67.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/sometimes-you-can-just-feel-the-security-in-the-design-junos-os-evolved-cve-2026-21902-rce/)

- **What:** An incorrect permission assignment for critical resources in Junos OS Evolved allows unauthenticated remote code execution.
- **Why it matters:** Pre-authenticated RCE on core networking infrastructure (PTX series) grants total network control to attackers.
- **Hunt signal:** Scan for Junos Evolved management interfaces on PTX devices and check for CVE-2026-21902 patch status.
- **Evidence:** [source] WatchTowr Labs details a design flaw in Junos OS Evolved leading to critical resource exposure. · [opinion] A prime example of a design-level vulnerability bypassing standard perimeter defenses.

---
