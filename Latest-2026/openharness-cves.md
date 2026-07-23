# openharness-cves


## 2026-04-19

### OpenHarness Path Normalization Bypass — `CVE-2026-40515`
- **Tags:** `#path-traversal` `#data-exfil`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-40515)

- **What:** Incomplete path normalization in OpenHarness allows bypassing permission checks to read sensitive files.
- **Why it matters:** Attackers can exfiltrate keys, configs, and other restricted local content despite configured path rules.
- **Hunt signal:** Probe built-in `grep`/`glob` tools with path traversal payloads (e.g., `../etc/passwd`) against restricted directories.
- **Evidence:** [NVD] The vulnerability permits invoking built-in tools on sensitive root directories that are not properly evaluated against path rules.

---
### OpenHarness SSRF in web_fetch/web_search — `CVE-2026-40516`
- **Tags:** `#ssrf` `#cloud`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-40516)

- **What:** Server-side request forgery in OpenHarness's web_fetch and web_search tools allows bypassing validation to access internal network resources.
- **Why it matters:** Attackers can reach cloud metadata services (e.g., AWS IMDS) or local admin panels, leading to data exfiltration and lateral movement.
- **Hunt signal:** Inspect OpenHarness logs for `web_fetch` or `web_search` invocations containing 127.0.0.1, 169.254.169.254, or RFC1918 IP ranges in arguments.
- **Evidence:** [source] NVD details insufficient validation of target addresses pre-commit bd4df81. [opinion] Critical for AI agent infrastructure deployed in cloud environments.

---
