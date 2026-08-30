# quinn-cves


## 2026-08-30

### CVE-2026-25800 — Quinn QUIC Assembler memory exhaustion via fragmented streams — `CVE-2026-25800`
- **Tags:** `#web` `#api`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-25800)

- **What:** Quinn's `Assembler` component incurs unbounded buffer overhead when a peer sends stream fragments with many gaps, enabling memory exhaustion on the receiving side.
- **Why it matters:** An unauthenticated peer can force a Quinn-based server to allocate excessive memory by withholding early stream fragments and sending many non-contiguous chunks, causing denial of service.
- **Hunt signal:** pass — patched in 0.11.15; targets would need to be running an older Quinn version, and the impact is DoS only.
- **Evidence:** [source] NVD entry confirms Assembler overhead for non-contiguous fragments prior to 0.11.15 · [opinion] DoS-only with a clean patch available; low bounty value but relevant for any Quinn-based service still on old versions.

---
