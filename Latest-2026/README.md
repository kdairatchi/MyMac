# Latest-2026 — Rolling Attack Surface Tracker

> **Last refresh:** 2026-05-18 · Maintainer: [@kdairatchi](https://github.com/kdairatchi)

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

## Recent (last 10)

| Date | Item | Class | Hunt |
|---|---|---|---|
| 2026-04-29 | CVE-2026-41940 cPanel & WHM Pre-Auth Bypass (watchTowr) | cve | 5/5 |
| 2026-05-17 | CVE-2026-42945 NGINX Rift 18yr flaw [unverified] | cve | hold |
| 2026-05-17 | Gadget Hunting in Practice — chain-building technique | technique | 4/5 |
| 2026-05-17 | One Vulnerability Two Reports Double Reward | writeup | 4/5 |
| 2026-05-17 | Business Logic → Negative Cart / Price Manipulation | writeup | 4/5 |
| 2026-05-13 | Project Zero: Pixel 10 0-click chain | reading | pass |
| 2026-04-30 | Intigriti SQLi exploitation guide | technique | 3/5 |
| 2026-04-23 | Firefox 150 batch — 7 CVEs (5× CRITICAL 9.8) | cve | 2/5 |
| 2026-04-23 | Rocket.Chat SQLi → auth bypass (CVE-2026-29198) | cve | 4/5 |
| 2026-04-23 | PostMessage origin bypass — full exploit guide | technique | 3/5 |

## Contribution

One rule: **every claim gets a date and a source link**. No "recent research shows" without a URL. If I can't verify it, it doesn't go in.
