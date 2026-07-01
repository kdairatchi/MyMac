# gradio-cves


## 2026-07-01

### Gradio FileExplorer Path Traversal — Unauth Arbitrary File Read — `CVE-2026-49119`
- **Tags:** `#path-traversal` `#lfi` `#web` `#api`
- **Severity:** high · **Hunt:** 5/5 · **Score:** 52.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-49119)

- **What:** Unauthenticated path traversal in Gradio <6.16.0 FileExplorer `preprocess()` lets attackers escape the configured `root_dir` via traversal sequences or absolute paths, bypassing `os.path.join` to read arbitrary files.
- **Why it matters:** No auth required; Gradio is ubiquitous in ML/AI demo deployments — API keys, `.env` files, and config secrets are often co-located on the same server.
- **Hunt signal:** Probe any Gradio instance exposing a FileExplorer component with path segments like `../../etc/passwd` or absolute paths like `/etc/passwd`; watch for full file content in the response.
- **Evidence:** [source] NVD confirms `os.path.join` root_dir discard via crafted segments · [opinion] trivially weaponizable — absolute-path trick (`/etc/passwd`) makes it a one-shot probe with no encoding gymnastics needed.

---
