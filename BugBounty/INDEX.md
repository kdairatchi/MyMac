---
tags: [bugbounty, index, hub]
cssclasses: [bb-index]
updated: 2026-04-21
---

# Bug Bounty Hub — kdairatchi

> [!tip] How to use this vault
> Every file follows the same layout: **TL;DR → Where to Hunt → Hunt Steps → Payload Vault → 2025-2026 Updates → Chain Ideas → Tools**.
> Open the vuln file on the left pane, Burp/terminal on the right. All payloads are copy-paste ready.

---

## Recon

| File | What |
|------|------|
| [[00-recon/subdomain-enum]] | Passive + active subdomain enumeration, live host discovery |
| [[00-recon/dorks]] | GitHub, Google, Shodan, Fofa dorks — organized by signal |
| [[00-recon/js-analysis]] | JS secret hunting, endpoint extraction, source map leaks |
| [[00-recon/scope]] | Scope parsing, wildcard handling, out-of-scope traps |

---

## Vuln Classes

| File | Severity | 2025 Updated |
|------|----------|--------------|
| [[01-vuln/xss]] | P1–P3 | ✓ |
| [[01-vuln/ssrf]] | P1–P2 | ✓ |
| [[01-vuln/idor]] | P1–P3 | ✓ |
| [[01-vuln/sqli]] | P1–P2 | ✓ |
| [[01-vuln/oauth]] | P1–P2 | ✓ |
| [[01-vuln/cors]] | P2–P3 | ✓ |
| [[01-vuln/csrf]] | P2–P3 | ✓ |
| [[01-vuln/lfi]] | P1–P2 | ✓ |
| [[01-vuln/file-upload]] | P1–P2 | ✓ |
| [[01-vuln/host-header]] | P2–P3 | ✓ |
| [[01-vuln/jwt]] | P1–P3 | ✓ |
| [[01-vuln/prototype-pollution]] | P1–P3 | ✓ |
| [[01-vuln/ssti]] | P1 | ✓ |
| [[01-vuln/xxe]] | P1–P2 | ✓ |
| [[01-vuln/cache-poisoning]] | P1–P3 | ✓ |
| [[01-vuln/crlf]] | P2–P3 | ✓ |
| [[01-vuln/nosqli]] | P1–P2 | ✓ |
| [[01-vuln/mass-assignment]] | P2–P3 | ✓ |
| [[01-vuln/open-redirect]] | P3–P4 (chain to P1) | ✓ |
| [[01-vuln/http-desync]] | P1 | ✓ |
| [[01-vuln/graphql]] | P1–P3 | ✓ 2025 |
| [[01-vuln/llm-injection]] | P1–P2 | ✓ 2026 |

---

## Bypass Techniques

| File | What |
|------|------|
| [[02-bypass/403]] | Path tricks, header injection, method switching |
| [[02-bypass/2fa]] | Response manipulation, code reuse, race conditions |
| [[02-bypass/429]] | Header spoofing, param append, IP rotation tricks |
| [[02-bypass/captcha]] | Method change, empty value, token reuse |
| [[02-bypass/waf]] | Cloudflare, Imperva, ModSecurity, AWS WAF bypasses |
| [[02-bypass/auth]] | Auth flow logic gaps, session fixation, JWT none |

---

## Technology Specifics

| File | CVEs/Exploits |
|------|---------------|
| [[03-tech/jenkins]] | Script console RCE, Groovy injection |
| [[03-tech/wordpress]] | Plugin vulns, XML-RPC, REST API abuse |
| [[03-tech/jira-confluence]] | SSRF, path traversal, EL injection |
| [[03-tech/grafana]] | Path traversal, SSRF, SQLi |
| [[03-tech/nginx-apache]] | Path normalization, off-by-slash, HTTP splitting |
| [[03-tech/laravel]] | Debug RCE, mass assignment, .env exposure |

---

## Miscellaneous Attacks

| File | Notes |
|------|-------|
| [[04-misc/ato]] | ATO via OAuth, CSRF, IDOR, password reset |
| [[04-misc/biz-logic]] | Coupon abuse, race conditions, price tampering |
| [[04-misc/exposed-api-keys]] | JS hunting, header leaks, git history |
| [[04-misc/email-spoofing]] | SPF/DKIM bypass, header injection |
| [[04-misc/subdomain-takeover]] | Dangling DNS, service fingerprinting |

---

## Exploit Chains

| Chain | Severity Uplift |
|-------|----------------|
| [[05-chains/ssrf-to-rce]] | SSRF → cloud metadata → IAM → RCE |
| [[05-chains/xss-to-ato]] | Stored XSS → cookie steal / OAuth token theft |
| [[05-chains/idor-chain]] | IDOR → data exfil → ATO |
| [[05-chains/open-redirect-oauth]] | Open Redirect → OAuth code intercept → ATO |
| [[05-chains/lfi-to-rce]] | LFI → log poisoning → RCE |

---

## Hunt Checklists

| Checklist | When to use |
|-----------|-------------|
| [[06-checklists/master-checklist]] | Every new target — first 2 hours |
| [[06-checklists/forgot-password]] | Password reset flow testing |
| [[06-checklists/registration-flow]] | Sign-up/account creation |
| [[06-checklists/api-endpoints]] | REST/GraphQL API surface |
| [[06-checklists/oauth-flow]] | OAuth/SSO integration |

---

## Scripts & Automation

```bash
# Obsidian sync from this workspace
bash /home/anon/MyMac/BugBounty/scripts/obsidian-sync.sh

# Quick recon pipeline
bash /home/anon/MyMac/BugBounty/scripts/recon-pipeline.sh <domain>
```

| Script | What it does |
|--------|--------------|
| [[scripts/obsidian-sync]] | Rsync BugBounty/ → Obsidian vault |
| [[scripts/recon-pipeline]] | subfinder → httpx → katana → nuclei one-liner |
| [[scripts/js-secret-hunt]] | gau → JS file grep for secrets |

---

## Obsidian Dataview Queries

````dataview
TABLE updated, tags
FROM "BugBounty/01-vuln"
SORT updated DESC
````

````dataview
TABLE updated, tags
FROM "BugBounty"
WHERE contains(tags, "2026")
SORT updated DESC
````

---

## Quick Links

- Cheatsheets: [[../Cheatsheets/xss]] | [[../Cheatsheets/ssrf]] | [[../Cheatsheets/oauth]]
- Methodology: [[../Methodology/bb-methodology]] | [[../Methodology/01-scope-review]]
- Latest 2026: [[../Latest-2026/README]]
- Targets: [[../Targets]]
