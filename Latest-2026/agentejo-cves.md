# agentejo-cves


## 2026-07-01

### Cockpit CMS Path Traversal via YAMLLoad in htaccess Handler — `CVE-2026-13533`
- **Tags:** `#lfi` `#path-traversal`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13533)

- **What:** Spyc::YAMLLoad in /config/config.yaml of Cockpit CMS ≤0.12.2 allows remote attackers to access arbitrary files or directories through the htaccess Handler.
- **Why it matters:** Unauthenticated remote file access on a CMS with a publicly disclosed exploit and an unresponsive vendor means many instances will remain vulnerable indefinitely.
- **Hunt signal:** Probe `GET /config/config.yaml` and look for YAML parsing artifacts; test path traversal vectors via the htaccess Handler endpoint for `/etc/passwd` or similar file reads.
- **Evidence:** [source] NVD entry confirms remote attack vector with public exploit disclosure · [opinion] Unresponsive vendor + public PoC = high likelihood of active exploitation; prioritize Cockpit instances running ≤0.12.2.

---
