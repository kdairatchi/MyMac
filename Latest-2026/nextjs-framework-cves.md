# Next.js & Framework CVEs — 2025/2026

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
