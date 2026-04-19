# Start Here

> New to this repo? Read this page. 5 min.

Hi — I'm **[kdairatchi](https://github.com/kdairatchi)**. This is my working bug bounty notebook. It grew from saving URLs + screenshots to a flat, greppable knowledge base. Everything here is stuff I've actually used on targets or read closely enough to trust.

Use it however helps you hunt. No attribution required, MIT.

---

## If you're a beginner

Read these **in order**. Skip nothing.

1. **[Methodology/bb-methodology.md](Methodology/bb-methodology.md)** — how hunts actually go
2. **[Recon/web2-recon.md](Recon/web2-recon.md)** — find attack surface
3. **[Checklists/vuln-classes/web2.md](Checklists/vuln-classes/web2.md)** — what to test
4. **[Cheatsheets/xss.md](Cheatsheets/xss.md)** + **[sqli](Cheatsheets/sql-injection.md)** + **[ssrf](Cheatsheets/ssrf.md)** — start with these three
5. **[Templates/report-writing.md](Templates/report-writing.md)** — how to get paid when you find something

Then pick **one program** on HackerOne/Bugcrowd/Intigriti, read its scope, and spend 20 hours on it before switching. Most beginners fail by hopping targets.

### Beginner traps (I fell in all of them)

- Don't report "I can cause a 500 error." Not a bug.
- Don't chain 3 self-XSS into "critical." Read `Methodology/triage-validation.md`.
- Don't copy-paste payloads. Understand *why* each one works.
- Duplicate reports still teach you something. Keep going.

## If you're already hunting

Fast paths into the repo:

- **Recon oneliners:** `Awesome/Awesome One-liner Bug Bounty Awesome.md`
- **Fresh attack surface (2025/2026):** [`Latest-2026/`](Latest-2026/)
- **AI/LLM bounties:** [`Cheatsheets/llm-security.md`](Cheatsheets/llm-security.md)
- **Web3:** [`Web3/00-START-HERE.md`](Web3/00-START-HERE.md)
- **Tool index:** `Cheatsheets/tools-index.md`

Grep is the interface:

```bash
grep -rln "CVE-2025" .
grep -rln "prototype pollution" Cheatsheets/ Checklists/
rg --type md "oauth" Methodology/ Cheatsheets/
```

## If you're a researcher / pentester (not bug bounty)

- Red team content: [`RedTeam/`](RedTeam/) — OPSEC, persistence, lateral movement, C2
- MITRE ATT&CK-aligned where possible
- Caido/Burp configs in [`Burp/`](Burp/)

---

## What's in what (quick map)

```
MyMac/
├── Awesome/         Curated awesome-lists (tools, writeups, oneliners)
├── Cheatsheets/     Per-class + per-tech quick refs — incl. burp, llm-security, keyhacks
├── Checklists/      Hunt checklists — web, mobile, API, cloud, vuln-classes + OWASP WSTG
├── Latest-2026/     Rolling tracker — HTTP desync, Next.js, supply chain, K8s, appliances
├── Methodology/     How hunts go — scope → recon → triage → validate
├── Notes/           Field notes — daily drops + writeups-2026.md (H1 enrichment)
├── Payloads/        Categorized payloads
├── PoCs/            Proof-of-concept exploits (CVEs)
├── Recon/           Subdomain enum, content disco, JS analysis, GitHub/Google/Shodan dorks
├── RedTeam/         TTPs, tooling, OPSEC
├── Scripts/         Automation helpers
├── skills/          refresh-latest pipeline (fetches + enriches + files)
├── Templates/       Report-writing + target-note templates
└── Web3/            Smart contract audit methodology
```

## Opinions (personal, feel free to ignore)

- **Caido > Burp** for workflow, Burp still wins for deep research. Use both.
- **nuclei** is 80% of automated recon value. Learn to write templates.
- **Writing > tools.** A $500 report and a $5k report often use the same finding — the difference is the writeup.
- **Don't skip Web3.** Payouts are higher, pool is smaller, tooling is the same mindset.
- **AI/LLM hunting in 2026** is the closest thing to "bug bounty in 2014" — wide open, undervalued.

## Useful links outside this repo

- PortSwigger Research — https://portswigger.net/research
- HackerOne Hacktivity — https://hackerone.com/hacktivity
- watchTowr Labs — https://labs.watchtowr.com
- Assetnote Research — https://www.assetnote.io/resources/research
- Intigriti blog — https://blog.intigriti.com
- My vault-backed site — https://prowlrbot.com

---

Questions, corrections, additions? Open an issue or ping **prowlr@proton.me**. PRs with real, tested techniques welcome. No AI filler.
