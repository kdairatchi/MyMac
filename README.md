# MyMac — Bug Bounty Workbench

A curated, ever-growing collection of bug bounty techniques, payloads, checklists, scripts, and references — organized so a researcher can find what they need in one grep.

Maintained by **[kdairatchi](https://github.com/kdairatchi)** · [ProwlrBot](https://prowlrbot.com)

![status](https://img.shields.io/badge/status-active-success) ![license](https://img.shields.io/badge/license-MIT-blue) ![topics](https://img.shields.io/badge/topics-bugbounty%20%7C%20pentest%20%7C%20recon%20%7C%20payloads-purple)

---

## What's in here

| Dir | Contents |
|---|---|
| [`ai/`](ai/) | AI-assisted hunting prompts and notes |
| [`Awesome/`](Awesome/) | Curated awesome-lists (47 files) — tools, resources, readings |
| [`burp/`](burp/) | Burp Suite configs, extensions, match/replace rules |
| [`Cheatsheets/`](Cheatsheets/) | Per-class cheatsheets (29 files) |
| [`Checklists/`](Checklists/) | Hunt checklists — web, mobile, API, cloud |
| [`cloudflare-waf-bypass/`](cloudflare-waf-bypass/) | CF WAF bypass techniques |
| [`Dorks/`](Dorks/) | Google / GitHub / Shodan dorks |
| [`infosec/`](infosec/) | General infosec references |
| [`notes/`](notes/) | Field notes by topic (16 files) |
| [`OWASP/`](OWASP/) | WSTG, MASTG, API Top 10, cheatsheets |
| [`Payloads/`](Payloads/) | Categorized payloads |
| [`POCS/`](POCS/) | Proof-of-concept exploits (10) |
| [`Red Team/`](<Red Team/>) | Red team TTPs, tooling (29 files) |
| [`Scripts/`](Scripts/) | Automation scripts — recon, fuzz, helpers (78 files) |
| [`Links.md`](Links.md) | Master link index (1,300+ references) |
| [`Targets.md`](Targets.md) | Target intel notes |
| [`bug.md`](bug.md) | Quick bug notes |

---

## Quick start

```bash
git clone https://github.com/kdairatchi/MyMac
cd MyMac

# Find something fast
grep -rln "SSRF" Checklists/ Cheatsheets/ notes/

# Run a script
ls Scripts/
```

### Companion repos

- [`kdairatchi/bb-arsenal`](https://github.com/kdairatchi/bb-arsenal) — consolidated research notebook
- [`kdairatchi/nuclei-templates-custom`](https://github.com/kdairatchi/nuclei-templates-custom) — personal nuclei templates
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
