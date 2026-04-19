# Latest-2026 — Rolling Attack Surface Tracker

> **Last refresh:** 2026-04-15 · Maintainer: [@kdairatchi](https://github.com/kdairatchi)

A rolling index of fresh attack surface, CVEs, and techniques that matter for bug bounty **right now**. Dated, evidence-labeled, no filler.

If you find this doc and the dates are >3 months old — it's stale, trust the primary source over me.

## Contents

- [HTTP Desync 2025/2026](desync-2025.md) — Kettle's latest, H2 smuggling, 0.CL attacks
- [Next.js / Framework CVEs](nextjs-framework-cves.md) — middleware bypass, RSC, server actions
- [Supply Chain 2025/2026](supply-chain.md) — npm/PyPI, slopsquatting, lockfile attacks
- [Cloud Native](cloud-native.md) — K8s, eBPF, container escape
- [Appliance chains](appliance-chains.md) — Ivanti/Fortinet/Citrix-style patterns
- [LLM security → `../Cheatsheets/llm-security.md`](../Cheatsheets/llm-security.md)

## How to use

```bash
# Grep by CVE
grep -rln "CVE-2025" Latest-2026/

# Grep by class
grep -rln "desync\|smuggling" Latest-2026/
```

## Contribution

One rule: **every claim gets a date and a source link**. No "recent research shows" without a URL. If I can't verify it, it doesn't go in.
