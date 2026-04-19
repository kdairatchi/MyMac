# prasathmani-cves


## 2026-04-19

### TinyFileManager <= 2.6 Path Traversal via file[] — `CVE-2026-6496`
- **Tags:** `#path-traversal` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-6496)

- **What:** A path traversal vulnerability in the `file[]` POST parameter of `/filemanager.php` allows reading arbitrary files.
- **Why it matters:** Public exploits are available, enabling attackers to exfiltrate sensitive configuration files or source code.
- **Hunt signal:** POST `file[]=../../../etc/passwd` to `/filemanager.php` and inspect response for file contents.
- **Evidence:** [source] NVD confirms the flaw affects the POST Parameter Handler in versions up to 2.6. [opinion] A strong primitive for chaining, particularly if log poisoning or file write features exist.

---
