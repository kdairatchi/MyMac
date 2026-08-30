# dbgate-cves


## 2026-08-30

### DbGate ZIP Path Traversal to Unauth RCE as Root (CVE-2026-47669) — `CVE-2026-47669`
- **Tags:** `#path-traversal` `#rce` `#docker` `#api`
- **Severity:** critical · **Hunt:** 3/5 · **Score:** 27.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-47669)

- **What:** DbGate's `unzipDirectory()` doesn't validate extracted file paths, allowing ZIP slip with `../` entries; default Docker runs as root with `none` auth provider that issues JWTs without credentials.
- **Why it matters:** Any network-adjacent attacker can obtain a JWT unauthed, upload a malicious ZIP, and write arbitrary files as root — trivially chainable to full RCE.
- **Hunt signal:** `curl -X POST /auth/login -d '{}' → JWT → upload ZIP with ../entries → check /etc/crontab overwrite`
- **Evidence:** [NVD] Zip slip in unzipDirectory.js line 27, fixed in 7.1.9 · [opinion] default Docker config (root + no-auth) makes this wormable on any exposed instance; hunt for unpatched DbGate containers on standard ports

---
### CVE-2026-47670 — DbGate Authenticated RCE via import() bypass — `CVE-2026-47670`
- **Tags:** `#rce` `#web` `#api`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-47670)

- **What:** Authenticated users can achieve root-level RCE via the unsanitized `functionName` parameter on `/runners/load-reader`, bypassing the `require = null` mitigation with dynamic `import()`.
- **Why it matters:** Runs OS commands as root from a low-privilege authenticated context; the require-null bypass shows a common Node.js sandbox escape pattern that applies broadly.
- **Hunt signal:** Look for DbGate instances exposing `/runners/load-reader`, then test `import()` in `functionName` to confirm patch status.
- **Evidence:** [nvd] Authenticated RCE as root in DbGate ≤7.1.8; trivial `import()` bypass of `require=null` sandbox · [opinion] Classic Node.js sandbox escape — useful pattern knowledge for other JS apps even though this specific instance is patched.

---
