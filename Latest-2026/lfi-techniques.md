# lfi-techniques


## 2026-04-16

### Flarum Blind File Oracle Vulnerability
- **Tags:** `#lfi` `#path-traversal` `#flarum`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://www.assetnote.io/resources/research/leaking-file-contents-with-a-blind-file-oracle-in-flarum)

- Blind file oracle technique in Flarum's file handling mechanism
- Allows attackers to exfiltrate arbitrary local file contents
- Exploitable through crafted requests that manipulate file path parameters
- Does not require authentication to target installations
- Could lead to sensitive data exposure including configuration files

Takeaways:
- Implement proper input validation and path sanitization for file operations
- Restrict file access to intended directories only and validate all file path parameters

---
