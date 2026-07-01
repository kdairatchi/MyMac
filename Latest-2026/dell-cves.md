# dell-cves


## 2026-07-01

### Dell DDMA Link Following Local Privilege Escalation (CVE-2026-41121) — `CVE-2026-41121`
- **Tags:** `#privesc` `#path-traversal`
- **Severity:** medium · **Hunt:** 3/5 · **Score:** 13.25 · **Status:** unknown · **Age:** 7d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-41121)

- **What:** Dell Device Management Agent (prior to DDMA 26.05) improperly resolves symbolic links before file access, allowing a low-privileged local attacker to escalate privileges.
- **Why it matters:** Local privilege escalation on endpoints running Dell management agents — common in enterprise environments — can turn a low-priv foothold into SYSTEM/root.
- **Hunt signal:** Check installed DDMA version string via registry or binary metadata; look for symlink artifacts in DDMA writable dirs. Low remote signal — primarily chain value after initial access.
- **Evidence:** [NVD] CWE-59 Link Following · [opinion] solid chain candidate for post-exploitation privesc on Dell-managed endpoints, but limited standalone bounty value due to local-access requirement.

---
