# Bug Bounty OPSEC

Stay in scope, stay identified as a researcher, stay safe.

## Identity

- Use a dedicated researcher handle on platforms (HackerOne, Bugcrowd, Intigriti, YesWeHack).
- Researcher-ID headers on every request:

```
X-Bug-Bounty: HackerOne-<username>
X-Bug-Bounty-Research: kdairatchi
User-Agent: kdairatchi-bugbounty-research/2026 (+https://prowlrbot.com)
```

Configure in Burp → Proxy → Match/Replace as header-add rules. Caido equivalent via Match/Replace.

- Separate researcher email used for test accounts (not personal).

## Scope hygiene

- Before every run, re-read `Methodology/01-scope-review.md`.
- Keep a per-program `scope.txt` allowlist; pipe recon through `--domain-file` checks.
- Filter tools: `httpx -l raw.txt | grep -Ff scope.txt`.
- Never report an OOS asset even if it's vulnerable.

## Rate / etiquette

- Default: `-rate 50` or lower, `-concurrency 10-15`.
- Watch for 429, Cloudflare challenges, captcha walls — back off immediately.
- No password/OTP flood. Most programs forbid bruteforce.
- No auto-scanners without permission (nuclei okay with bounded templates; acunetix/burpscanner often banned).

## Test accounts

- Create within program rules (many provide test accounts for paid programs).
- Use distinctive emails: `kdairatchi+victim@...`, `kdairatchi+attacker@...` — makes reports crystal clear.
- Clean up created data when done.

## PoC restraint

- Read once, stop. If SSRF leaks AWS creds — confirm `sts get-caller-identity`, don't enumerate the whole account.
- If SQLi — `--current-user --current-db`, never `--dump` user tables.
- Screenshots should redact other users' data.
- Never access another user's PII beyond proving the bug class.

## Infrastructure

- Dedicated research VM / namespace — no personal browsing on the same profile.
- Outbound interactsh / Collaborator on a subdomain you own; don't share with anything else.
- Keep C2-like infra (for blind XSS, SSRF callback) clearly labeled in URLs — `//xss.kdairatchi.prowlrbot.com/` so target SOC doesn't mistake you for a live attacker.

## Disclosure

- Honor platform disclosure timelines.
- Don't tweet details pre-fix.
- Writeups only after public disclosure approval or at least after remediation.

## Legal

- Safe-harbor language is not a free pass — read it.
- Unscoped testing = unauthorized access in many jurisdictions.
- If you find something outside scope by accident, stop, document internally, report via responsible channel (security.txt) without exploit details.

## Personal

- Burnout is real. Cap hunt sessions. Keep a log (see `Templates/target_notes.md`).
- Track earnings in the Obsidian vault `10 - Finance/`.
- Don't chase — pick your battles based on program ROI.

## References

- HackerOne Hacker Guidelines — https://docs.hackerone.com/hackers/hacker-guidelines.html
- Bugcrowd Standard Disclosure Terms — https://bugcrowd.com/engagements
- disclose.io core terms — https://github.com/disclose/disclose.io
