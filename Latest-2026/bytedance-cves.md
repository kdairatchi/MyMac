# bytedance-cves


## 2026-04-19

### ByteDance DeerFlow Path Traversal / Arbitrary File Write — `CVE-2026-40518`
- **Tags:** `#path-traversal`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-40518)

- **What:** A validation bypass in the bootstrap-mode custom-agent creation allows path traversal and arbitrary file writes.
- **Why it matters:** Attackers can write files outside the intended directory, potentially leading to remote code execution or system compromise.
- **Hunt signal:** Test agent name parameters in bootstrap mode for traversal payloads (e.g., `../../`) or absolute paths.
- **Evidence:** [source] NVD analysis confirms the flaw in versions prior to commit 2176b2b.

---
