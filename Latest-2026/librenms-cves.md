# librenms-cves


## 2026-04-16

### LibreNMS LFI in NFSen Module — `CVE-2026-30480`
- **Tags:** `#lfi` `#path-traversal` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 21.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-30480)

- **What:** Authenticated users can include and execute arbitrary PHP files via path traversal in the `nfsen` parameter.
- **Why it matters:** Successful exploitation typically leads to Remote Code Execution (RCE), allowing full server takeover.
- **Hunt signal:** Probe `nfsen.inc.php` with `nfsen=../../../../../etc/passwd` or PHP log inclusion attempts.
- **Evidence:** [source] NVD · [opinion] High impact for internal environments where LibreNMS is often used.

---
