# yunaiv-cves


## 2026-07-01

### Path traversal in ruoyi-vue-pro file upload — `CVE-2026-13528`
- **Tags:** `#path-traversal` `#web` `#api`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13528)

- **What:** The `generateUploadPath` function in `FileServiceImpl.java` of the AppFileController file upload endpoint allows path traversal, enabling remote attackers to write files to arbitrary locations.
- **Why it matters:** Path traversal in a file upload endpoint can chain to RCE by writing webshells or overwriting critical config files; a public exploit exists and the attack is remotely exploitable.
- **Hunt signal:** Upload a file with `../` sequences in the filename via the `/infra/file/upload` endpoint and check for writes outside the intended upload directory.
- **Evidence:** [source] NVD entry confirms remote exploitation with public PoC and available patch (4ae3f6b) · [opinion] High-value target for bug bounty — authenticated file upload path traversal with a known PoC is a reliable chain starter to RCE.

---
