# Scope Review

Before typing a single payload — read the program.

## Read in order

1. **Brief / policy page** — paid? VDP? safe harbor? legal language.
2. **In-scope assets** — domains, wildcards, mobile apps, APIs, source repos.
3. **Out-of-scope** — hosts, subdomains, third-party SaaS, acquisitions, staff portals.
4. **Out-of-scope issues** — SPF/DMARC, clickjacking on non-sensitive, rate limit, best-practice reports, self-XSS, missing cookie flags, outdated software w/o PoC.
5. **Reward table** — severity → $. Note minimum bar.
6. **Required PoC quality** — some programs require video; some require impact chain.
7. **Disclosure rules** — public disclosure only after fix, coordinated timing.

## OOS traps to internalize

- **Wildcard `*.target.com` but not acquisitions.** Check the parent domain's WHOIS/SAN before firing.
- **Scope says "core app", excludes "*.dev.target.com".** Recon will find dev hosts — don't report them.
- **Third-party SaaS (Zendesk, Atlassian, Salesforce, Intercom).** Often OOS even when the subdomain resolves on target. Verify before reporting.
- **"No DoS" includes unbounded password reset floods, big regex ReDoS, zip bombs.**
- **Social engineering / physical / phishing** — almost always OOS.
- **Auto-scanner noise** — most programs ban wide crawling, aggressive fuzz, automated PoCs without manual verification.

## Reward-tier signals

- Flat bounty + no severity table → small / budget-limited. Prioritize low-effort, high-impact bugs.
- CVSS-driven with P1 ≥ $5k → worth chaining for impact.
- "Bonus for chain" or "full account takeover" language → look for pre-auth IDOR, auth bypass, priv-esc chains.

## Pre-hunt checklist

- [ ] Copied scope and OOS to `Targets.md` for the program
- [ ] Noted reward tiers and minimum severity accepted
- [ ] Noted PoC requirements (video? browser? specific account?)
- [ ] Confirmed safe-harbor / legal language
- [ ] Rate-limit / header / user-agent rules captured
- [ ] Test accounts created where required

## Safe headers during testing

```
X-Bug-Bounty: HackerOne-<username>
X-Bug-Bounty-Research: kdairatchi
User-Agent: kdairatchi-bugbounty-research/2026
```

Set these as Burp match/replace so every request carries them. Programs with WAFs often whitelist known researchers by UA or custom header.

## References

- HackerOne — https://docs.hackerone.com/hackers/hacker-guidelines.html
- Bugcrowd VRT — https://bugcrowd.com/vulnerability-rating-taxonomy
- disclose.io — https://github.com/disclose/disclose.io
