# MyMac — Bug Bounty Workbench

A curated, ever-growing collection of bug bounty techniques, payloads, checklists, scripts, and references — organized so a researcher can find what they need in one grep.

Maintained by **[kdairatchi](https://github.com/kdairatchi)** · [ProwlrBot](https://prowlrbot.com)

![status](https://img.shields.io/badge/status-active-success) ![license](https://img.shields.io/badge/license-MIT-blue) ![topics](https://img.shields.io/badge/topics-bugbounty%20%7C%20pentest%20%7C%20recon%20%7C%20payloads-purple)

See [`INDEX.md`](INDEX.md) for a flat, scannable map of the whole repo.

---

## What's in here

| Dir | Contents |
|---|---|
| [`AI/`](AI/) | AI-assisted hunting prompts and notes |
| [`Awesome/`](Awesome/) | Curated awesome-lists — tools, resources, readings |
| [`Burp/`](Burp/) | Burp Suite configs, extensions, match/replace rules |
| [`Cheatsheets/`](Cheatsheets/) | Per-class cheatsheets + Keyhacks + tools index |
| [`Checklists/`](Checklists/) | Hunt checklists — web, mobile, API, cloud + vuln-classes |
| [`Cloudflare-WAF-Bypass/`](Cloudflare-WAF-Bypass/) | CF WAF bypass techniques |
| [`Dorks/`](Dorks/) | Google / GitHub / Shodan dorks |
| [`Infosec/`](Infosec/) | General infosec references |
| [`Methodology/`](Methodology/) | Hunt methodology, triage + validation, rules |
| [`Notes/`](Notes/) | Field notes by topic |
| [`OWASP/`](OWASP/) | WSTG, MASTG, API Top 10, cheatsheets |
| [`Payloads/`](Payloads/) | Categorized payloads (XSS, 403, JWT, WP, leaks) |
| [`PoCs/`](PoCs/) | Proof-of-concept exploits |
| [`Recon/`](Recon/) | Recon playbook, subdomain enum, content discovery, JS analysis, GitHub dorking |
| [`RedTeam/`](RedTeam/) | Red team TTPs, tooling, OPSEC |
| [`Scripts/`](Scripts/) | Automation scripts — recon, fuzz, helpers |
| [`Templates/`](Templates/) | Report-writing + target-notes templates |
| [`Web3/`](Web3/) | Smart contract audit methodology, bug classes, grep arsenal, Foundry PoCs |
| [`Links.md`](Links.md) | Master link index (1,300+ references) |
| [`Targets.md`](Targets.md) | Target intel notes |
| [`bug.md`](bug.md) | Quick bug notes |

---

## Quick start

```bash
git clone https://github.com/kdairatchi/MyMac
cd MyMac

# Find something fast
grep -rln "SSRF" Checklists/ Cheatsheets/ Notes/

# Run a script
ls Scripts/
```

### Companion repos

- [`kdairatchi/nuclei-templates-custom`](https://github.com/kdairatchi/nuclei-templates-custom) — personal nuclei templates
- [`kdairatchi/gf-patterns`](https://github.com/kdairatchi/gf-patterns) — gf pattern library (67 patterns, ERE-safe)
- [`kdairatchi/WordList`](https://github.com/kdairatchi/WordList) — custom wordlists

---

## Topics covered

Cross-Site Scripting (XSS) · SQL Injection · SSRF · RCE · IDOR · XXE · CSRF · Business Logic · Auth Bypass · OAuth / Access Token Theft · Race Conditions · File Upload · WAF Bypass · Subdomain Takeover · Cache Poisoning · Host Header Injection · Deserialization · Prototype Pollution · Mobile (iOS/Android) · API (REST/GraphQL) · Cloud (AWS/GCP/Azure) · Recon · Red Team Ops

See [`Links.md`](Links.md) for the full indexed reading list.

---

## Contributing

This is a personal knowledge base, but PRs that add **real, tested** techniques (with a writeup link) are welcome. No AI-generated filler.

## License

MIT — do whatever helps you hunt. Attribution appreciated, not required.

## Contact

- GitHub: [@kdairatchi](https://github.com/kdairatchi)
- Email: prowlr@proton.me
- Site: [prowlrbot.com](https://prowlrbot.com)
