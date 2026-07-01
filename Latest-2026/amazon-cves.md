# amazon-cves


## 2026-07-01

### AWS CLI overly permissive file permissions expose credentials to local users — `CVE-2026-13769`
- **Tags:** `#aws` `#cloud` `#data-exfil`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13769)

- **What:** AWS CLI v1 <1.44.78 and v2 <2.34.29 on Unix-like systems with default umask writes credential files world-readable, letting co-tenant local users read secrets produced by `codeartifact login`, `iam create-virtual-mfa-device`, and `deploy register`.
- **Why it matters:** Credentials harvested from a shared host (CI runner, bastion, dev box) can be leveraged for lateral movement into the victim's AWS account — real impact in multi-tenant or shared-CI environments.
- **Hunt signal:** Check shared CI runners or bastion hosts for world-readable `~/.aws/` files; grep `aws codeartifact login` artifact tokens in `/tmp` or home dirs. Low signal for remote bug bounty — skip unless target uses shared infrastructure.
- **Evidence:** [source] NVD entry confirms local read of credentials via default umask · [opinion] solid chain starter on shared hosts but limited standalone bounty value

---
