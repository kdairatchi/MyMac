# microsoft-cves


## 2026-04-19

### Windows Driver Signature Enforcement Bypass — `CVE-2026-21709`
- **Tags:** `#privesc` `#auth-bypass`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-21709)

- **What:** A local administrator can bypass Windows Driver Signature Enforcement (DSE) to load unsigned drivers.
- **Why it matters:** Enables attackers to load malicious kernel-mode code (rootkits/BYOVD) for persistence or defense evasion after gaining admin access.
- **Hunt signal:** pass
- **Evidence:** [source] NVD listing confirms the bypass capability. [opinion] Critical for post-exploitation phases but limited by the requirement for existing admin privileges.

---
