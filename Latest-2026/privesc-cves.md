# privesc-cves


## 2026-04-19

### GPU Memory Write Permission Bypass — `CVE-2026-21733`
- **Tags:** `#privesc`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-21733)

- **What:** Non-privileged users can gain write access to read-only memory via improper GPU system calls.
- **Why it matters:** Breaks memory protection boundaries, allowing potential code execution or data tampering from low-privileged contexts.
- **Hunt signal:** pass
- **Evidence:** [source] NVD entry describes improper GPU memory reservation handling allowing non-privileged users to modify read-only wrapped user-mode memory.

---
