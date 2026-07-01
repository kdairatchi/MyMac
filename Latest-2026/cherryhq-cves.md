# cherryhq-cves


## 2026-07-01

### Cherry Studio auth bypass via sha256 state argument manipulation — `CVE-2026-13534`
- **Tags:** `#auth-bypass` `#llm`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13534)

- **What:** The `sha256` function in CherryIN Preload API (`MemoryService.ts`) accepts a `state` argument that can be manipulated to bypass authorization, exploitable remotely.
- **Why it matters:** Cherry Studio is an LLM client; auth bypass in its Electron preload API means a renderer-side attacker (e.g., via malicious content or XSS) can escalate to privileged IPC calls — full app compromise in an AI-tool context.
- **Hunt signal:** Look for Cherry Studio instances ≤1.9.7 and test the `sha256` endpoint with crafted `state` values to confirm bypass; check if the public PoC triggers on target.
- **Evidence:** [source] NVD entry confirms remote attack vector with public exploit · [opinion] High complexity limits opportunistic use but the preload API surface is attractive for chaining with renderer-side bugs; vendor plans to remove Memory in v2, so patches may be slow.

---
