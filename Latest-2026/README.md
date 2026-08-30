# Latest-2026 — Rolling Attack Surface Tracker

> **Last refresh:** 2026-08-30 · Maintainer: [@kdairatchi](https://github.com/kdairatchi)

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
| 2026-08-30 | CVE-2026-8452 Citrix NetScaler Pre-Auth RCE (watchTowr) | cve | 4/5 |
| 2026-08-30 | CVE-2026-63359 Equifax Appriss VINE unauth auth bypass | cve | 5/5 |
| 2026-08-30 | CVE-2026-47669 DbGate ZIP slip → unauth RCE as root | cve | 3/5 |
| 2026-08-30 | CVE-2026-15212 WPO365 CSRF → admin takeover | cve | 3/5 |
| 2026-08-30 | CRLF-Powered Desync — Beheading HTTP Streams (PortSwigger) | technique | 4/5 |
| 2026-08-30 | HTTP Terminator — AI-discovered desync (PortSwigger) | technique | 3/5 |
| 2026-08-30 | What's in a Tag Name? JS in tag names (PortSwigger) | technique | 3/5 |
| 2026-08-30 | CSS bomb in the inbox — webmail CSS exfil (PortSwigger) | technique | 3/5 |
| 2026-08-30 | IDOR → poison another user's AI chat context | writeup | 4/5 |
| 2026-08-30 | PDF export LFI — $14k | writeup | 3/5 |

## Contribution

One rule: **every claim gets a date and a source link**. No "recent research shows" without a URL. If I can't verify it, it doesn't go in.
