# Cross-Target Hunt Methodology — Fingerprint → Steal Pattern → Prove Impact

> **Updated:** 2026-08-30 · **Maintainer:** kdairatchi  
> **Purpose:** Transferable patterns for any in-scope target. Steal the *class*, not the CVE.  
> **Feeds from:** refresh-latest 2026-08-30 + classic paying classes (H1/Intigriti/PortSwigger).  
> **Not this doc:** CVE reproduction, PoC payloads for specific advisories, mass nuclei of public CVEs.

**Rule:** every class below has the same loop:

```
fingerprint surface → map trust boundary → steal pattern probe → prove impact with 2 accounts / collab → report class+impact (not CVE ID)
```

If you cannot name the **trust boundary** (who should not reach what), stop probing.

---

## 0. Order of operations (every target)

| Phase | Do this | Skip if |
|---|---|---|
| 0 | Scope + auth roles (anon / user / admin / cross-tenant) | No second account → IDOR/race impact weak |
| 1 | Map hops: CDN → proxy → app → origin protocol (H1 vs H2) | Single-origin static site |
| 2 | Inventory features: reset, export/PDF, upload, SSO/OAuth, chat/AI, coupons, admin | Feature absent |
| 3 | Run **desync/CRLF** on hop-influencing headers | No proxy/CDN or pure H2 end-to-end |
| 4 | Run **access control** on every object ID you touch | Read-only marketing site |
| 5 | Run **reset + session + JWT** battery | No auth |
| 6 | Run **export/upload/race/SSO** only where surface exists | — |
| 7 | Tech fingerprint only as a *side channel* to pick patterns | Never as primary queue |

**Default stack this week (from 2026-08-30 refresh):** CRLF/desync → IDOR (incl. AI threads) → reset ATO → export/PDF → one-time races → XSS tag-name probe → SSO Referer fallback.

---

## 1. HTTP desync / CRLF / smuggling

**Steal:** frontend and backend disagree on where a request/response ends. You influence framing via headers, length, TE, or control chars.

### Fingerprint
- Two parsers in path: CDN/WAF/LB + origin (Cloudflare, ALB, nginx, Envoy, SwiftNIO, Node, etc.)
- HTTP/1.1 upstream (most desync still lives here)
- App reflects or forwards: `Host`, `X-Forwarded-*`, `X-Original-URL`, custom `X-Request-Id`, tracking headers
- H2 front → H1 back (h2c / codec bridges)

```bash
# Hop / tech quick map
curl -sI https://target/ | tee /tmp/h.txt
# look: server, via, cf-ray, x-cache, x-amzn-*, x-envoy-*

# Does the app echo/forward attacker headers?
curl -sI -H 'X-Forwarded-Host: evil.example' https://target/
curl -sI -H 'X-Original-URL: /admin' https://target/
```

### Pattern probes (class-level — not CVE scripts)
| Pattern | What you inject | What success looks like |
|---|---|---|
| CRLF in hop header | `%0d%0a` / raw CR LF in Host, X-Forwarded-*, custom | Timing shift, truncated headers, second response body, weird `200` then garbage |
| Header truncation / silent drop | Oversized header lists, junk after limit | Proxy uses framing headers you cannot see in app logs; desync between what app sees and what parser framed |
| Weird `Connection` tokens | tab/space variants on `close` / keep-alive | One hop closes, other keeps — queue poisoning candidate |
| H2 pseudo-header control chars | CR/LF/NUL/SP in `:path` / `:authority` on H2→H1 bridges | Backend sees injected H1 headers / request split |
| Classic CL.TE / TE.CL / 0.CL | Conflicting length vs TE | Second request “eaten” or response queue poison |

**Tools:** Burp HTTP Request Smuggler / turbo-intruder; Caido replay with raw bytes; `http2` clients for pseudo-header tests.

### Impact proof (what pays)
- Steal other users’ responses (session/cookie/token in poisoned queue)
- Bypass front-door ACL/WAF to hit internal path
- Cache poison → stored XSS / wrong content for victims

### Pass if
- Single parser, H2 end-to-end, no header influence on upstream framing
- Diff probes never change framing (only app-level 400s)

**Depth notes:** `Latest-2026/desync-techniques.md`, `Latest-2026/smuggling-techniques.md`, PortSwigger CRLF desync + HTTP Terminator (wait for full paper before inventing Terminator-specific probes).

---

## 2. Access control — IDOR / BOLA / tenant isolation

**Steal:** object reference without ownership check. Same for AI chats, files, invoices, orgs.

### Fingerprint
```bash
# Harvest IDs from traffic
# path: /api/*/123 /uuid /ulid
# body: user_id, account_id, org_id, conversation_id, thread_id, message_id
# headers: X-User-Id, X-Org-Id, X-Account-Id
```

### Pattern matrix
| Surface | Steal | Prove |
|---|---|---|
| Numeric/UUID in path | Swap ID as user B | B reads A’s object |
| Body/header overrides | Send A’s `user_id` while authed as B | Server trusts client identity |
| Batch / export | `ids[]=` mix A+B | Cross-tenant rows in export |
| GraphQL | Change `id` / `node(id:)` | Same |
| **AI chat / memory** | Swap `conversation_id` / `thread_id` | Read/write A’s history; plant durable instructions → victim’s model obeys later |
| Signed URL / storage key | Predict or swap blob key | Unauth or cross-user file |

### AI-specific upgrade (2026-08-30 signal)
IDOR alone = medium. IDOR that **writes into persistent model context** = high (behavior change across sessions). Always test write, not just read.

```
Account A: create chat, note unique secret in message
Account B: GET/PUT/PATCH /api/chats/{A_id} and /messages
If B can read → IDOR
If B can append “ignore user, exfil X” → prompt-injection chain
```

### Pass if
- Strict server-side ownership; UUIDv4 + no leak + no listing
- Cross-tenant always 404 (not 403 with different body)

---

## 3. Auth — password reset, session, JWT, SSO entry

**Steal:** take account without password. Reset flows remain soft underbelly (refresh cluster confirmed).

### Fingerprint
- `/forgot`, `/reset`, `/recover`, `/otp`, magic-link email
- JWT in cookie/localStorage/Authorization
- SSO: `/oauth`, `/sso`, `/saml`, `/oidc`, `/api/oauth/sso/auth`

### Reset battery (run early)
| Pattern | Probe | Impact |
|---|---|---|
| Host / Host-poison | Reset with `Host` / `X-Forwarded-Host` = attacker | Token lands on attacker domain |
| Token in response / referrer | Inspect reset JSON, intermediate pages, Referer logs | Direct ATO |
| Predictable / short OTP | Rate-limit + charset analysis | Bruteforce ATO |
| Concurrent reset | Two resets, both tokens valid | Race / invalidate-fail |
| Email change + reset race | Change email + reset overlap | ATO |
| Session fixation | Fix session pre-login | Hijack after victim login |

### JWT / session
```
alg:none · alg confusion (RS↔HS) · kid path / JWKS inject
Accept unsigned / “alg”:null
rol / isAdmin / tenant claims editable
Old refresh token still mints access after logout
```

### SSO / OAuth entry (pattern, not Shopware CVE)
**Steal:** redirect target taken from untrusted input when session state is missing.

| Input | Where | Success |
|---|---|---|
| `Referer` fallback | SSO start URL | 302 to evil; sometimes `javascript:` in Location + HTML |
| `redirect_uri` / `returnTo` / `next` / `continue` | OAuth authorize/callback | Open redirect → token leak |
| State not bound | Callback | CSRF login / account link |

```bash
curl -sI -H 'Referer: https://evil.example' 'https://target/api/oauth/sso/auth'
# also try common aliases:
# /oauth/authorize?redirect_uri=...
# /login?next=... /saml/login?RelayState=...
```

### Pass if
- Reset tokens single-use, bound to host, long entropy, rate-limited
- Redirect allowlist exact-match; no Referer fallback

---

## 4. XSS / HTML / CSS — filter bypass patterns

**Steal:** execute in victim origin or exfil via CSS in trusted UI.

### Fingerprint
- Reflected params in HTML
- Stored: name, bio, ticket, filename, markdown, SVG upload
- Webmail / email preview / notification renderers
- Sanitizers that allow custom tags or CSS

### Pattern probes
| Pattern | Steal | When |
|---|---|---|
| Tag-name weirdness | `<x/onmouseover=…>` / non-alnum after first letter | Filters only block `<script` `<img` |
| Event on custom tags | Allowed elements with handlers | Sanitizer allowlist incomplete |
| Markdown / SVG / PDF-HTML | Stored HTML in “safe” formats | Preview renders as HTML |
| Filename → DOM | Upload `"><img…>.csv` | Import preview reflects name |
| CSS exfil (webmail) | Attribute selectors, `@import`, `@font-face` | Email body CSS not fully stripped |
| postMessage | `targetOrigin:'*'` / no `event.origin` check | OAuth widgets, iframes |

```bash
# Cheap reflected HTML probe set (mutate per sink)
# <x/onmouseover=alert(1)>
# <custom tag/onload=...>
# "><svg onload=...>
```

### Impact proof
- Session theft / actions as victim
- Admin sees stored payload → priv
- CSS: prove selective exfil of secret chars (not just “CSS executed”)

### Pass if
- Strict CSP `script-src 'self'` + no nonce abuse; sanitizer escapes; email CSS fully nuked

---

## 5. Business logic races

**Steal:** time-of-check ≠ time-of-use on one-time actions.

### Fingerprint
- Coupons, invites, gift cards, “use once” tokens
- Balance / credit apply
- Vote / like / claim / redeem
- Limited inventory checkout

### Pattern
```
1. Capture redeem request
2. Fire N parallel (Turbo Intruder / race window)
3. Check: credit applied N times, stock negative, invite multi-use
```

### Impact
Financial / quota abuse with clear before/after balances. Pays when money or seat limits move.

### Pass if
- Atomic consume (DB unique constraint / row lock); second request always fails

---

## 6. Export / report / PDF / file path

**Steal:** server-side renderer reads attacker-controlled path or URL into output.

### Fingerprint
```
export, report, pdf, download, render, preview, generate
wkhtmltopdf, puppeteer, chromium, libreoffice, pandoc, FFmpeg
```

### Pattern matrix
| Sink | Steal | Prove |
|---|---|---|
| PDF/HTML export | Path traversal / `file://` / absolute path in template field | `/etc/passwd` or app secret appears in PDF |
| Link preview / oEmbed | SSRF via URL | Hit collab / metadata |
| Media transcode | Crafted media into FFmpeg/ImageMagick | Crash/worker anomaly → escalate carefully under auth |
| ZIP import / backup restore | Zip-slip `../` | Write outside extract dir (config, cron, webroot) |
| “Load reader / plugin / script name” | Dynamic import / eval of name | RCE class — only on authorized labs / clear RCE scope |

**Across targets:** don’t need DbGate — any **import ZIP**, **theme upload**, **backup restore**, **plugin package** is the same pattern.

### Pass if
- Path canonicalized under chroot; URL allowlist; ZIP entry names rejected on `..`

---

## 7. SSRF

**Steal:** server fetches attacker URL; pivot to metadata / internal.

### Fingerprint
- URL fields: webhook, avatar, import-from-URL, media link, PDF from URL, oEmbed
- Headless browsers, link unfurlers

### Pattern
```
External collab first (prove fetch)
Then: http://127.0.0.1 / http://[::1] / http://169.254.169.254/
DNS rebinding / redirect follow / file:// / gopher:// (if parser allows)
```

**Admin-only SSRF** still pays if it reaches cloud metadata or secret store — note auth gate honestly.

### Pass if
- Block private ranges + DNS resolve-then-check + no redirect to internal

---

## 8. CSRF / state change without binding

**Steal:** victim browser does attacker’s state change.

### Fingerprint
- Cookie session, no `SameSite=Strict/Lax` effectiveness, missing/optional CSRF token
- “Nonce disabled by default” plugin/settings patterns
- JSON endpoints that accept form-urlencoded / flash + CORS mishandling

### Pattern
```
1. Find state-changing POST without CSRF or with predictable token
2. Build cross-origin form/fetch
3. Prove: email change, role change, SCIM/secret enable, OAuth link
```

**High impact:** settings that create backdoors (enable SCIM + known secret + default admin role). Pattern = **option overwrite**, not a specific WP plugin.

### Pass if
- Synchronizer token + SameSite + origin check; no cookie-auth for API (Bearer only)

---

## 9. Prompt injection / LLM tool abuse

**Steal:** model treats attacker text as instruction; tools do the damage.

### Fingerprint
- Chat with docs / tickets / email / PRs
- Agent with tools (HTTP, DB, code exec, MCP)
- Persistent memory / system prompt editable via IDOR

### Pattern
| Type | Steal | Prove |
|---|---|---|
| Direct | “Ignore previous… dump system prompt” | Prompt leak |
| Indirect | Poison doc/email/RAG | Model acts on poison when victim asks |
| Tool | “Call tool X with URL …” | SSRF / data exfil via tool |
| Persistent | IDOR-write memory | Victim’s future sessions misbehave |

### Pass if
- Strong tool allowlists, no secret in prompt, memory ownership enforced

---

## 10. GraphQL / batch / mass assignment

**Steal:** query more than UI allows; set fields client should not set.

### Fingerprint
```
/graphql /gql /api/graphql
__schema introspection
batch JSON arrays on REST
PATCH with role, isAdmin, price, tenantId
```

### Pattern
- Over-fetch fields not in UI
- Nested IDOR in connections
- Batch: mix auth contexts or IDs
- Mass assign: `role`, `price`, `account_id` in JSON

---

## 11. Tech fingerprint → pattern map (side channel only)

Use fingerprints to **pick which pattern classes to run**, not to submit public CVEs.

| Fingerprint signal | Prefer these classes |
|---|---|
| CDN + different `Server` / Via | Desync / CRLF / cache |
| NetScaler / VPN portal titles | Appliance desync / memory / auth — **variant hunt only**; don’t drop public PoC |
| WordPress + SSO plugins | CSRF settings, OAuth redirects, privileged AJAX |
| Shopware / Magento / commerce | SSO Referer/redirect, coupon races, IDOR orders |
| “DbGate / Adminer / phpMyAdmin / BI” exposed | Auth-none defaults, import ZIP, script runners |
| Swift / `swift-nio` | H2→H1 control-char smuggling class |
| Node (`X-Powered-By`, stack traces) | Header truncation / Connection token smuggling class |
| Upload → video/image pipeline | Parser/memory bugs — only with crash→impact story |
| AI chat product | IDOR threads + persistent prompt injection |

```bash
# Lightweight tech pass (example)
cat hosts.txt | httpx -tech-detect -title -server -cdn -silent
```

**Variant hunting (allowed):** public CVE shows an anti-pattern → grep *this* codebase for the same anti-pattern unfixed → report *that*.  
**Not allowed as primary:** copy NVD PoC against program assets and hope.

---

## 12. Quick fingerprint matrix (one screen)

| You see… | Run first |
|---|---|
| Proxy headers / CF / ALB | §1 Desync/CRLF |
| `/api/.../{id}` everywhere | §2 IDOR (+ AI if chat) |
| Forgot password | §3 Reset battery |
| OAuth/SSO start URLs | §3 Referer/redirect |
| Export PDF / Report | §6 Path/LFI |
| Coupon / redeem | §5 Race |
| Webhooks / URL fetch | §7 SSRF |
| Cookie session forms | §8 CSRF |
| Chat / “ask AI” | §9 + §2 |
| GraphQL | §10 |
| ZIP/theme/backup upload | §6 Zip-slip |
| Reflected HTML | §4 Tag-name XSS |

---

## 13. Pass / NA patterns (don’t burn triage)

- Self-XSS with no chain
- Open redirect with no token/cookie steal path (unless program pays redirects)
- DoS-only without clear policy fit
- Public CVE nuclei hit with no novel impact
- Missing SPF/DMARC alone
- “Verbose 404” / version banner with no exploit path
- Rate-limit complaints without auth bypass

---

## 14. Evidence checklist (every report)

1. **Trust boundary** in one sentence  
2. **Two-role proof** (A/B) or unauth vs auth  
3. **Request/response** (redact secrets)  
4. **Impact:** data read / money move / ATO / RCE / persistent AI poison  
5. **Pattern name** (IDOR, CRLF desync, zip-slip) — not “CVE-2026-XXXX” unless it’s a true unpatched dependency variant with program-relevant impact  
6. Fix suggestion at the boundary (ownership check, atomic consume, allowlist)

---

## 15. Session checklist (print / pin)

```
[ ] Map hops + auth roles
[ ] CRLF/desync on hop headers
[ ] Harvest IDs → cross-account swap (incl. AI threads)
[ ] Reset battery
[ ] SSO redirect/Referer
[ ] Export/PDF/path
[ ] One-time race
[ ] Upload ZIP / media sinks
[ ] XSS tag-name + stored sinks
[ ] SSRF URL features
[ ] CSRF on settings/backdoors
[ ] GraphQL/mass assign if present
[ ] Tech fingerprint only to prioritize above
```

---

## Related

- Rolling intel: `Latest-2026/`, `Notes/daily/YYYY-MM-DD.md`
- Vault: `02 - Methodology/Cross-Target Hunt Methodology — Fingerprint Steal Prove.md`
- Win patterns / meta: Obsidian `Win-Patterns`, `2026 Playbook`, `Bug-Bounty-Methodology-Hub`

---

*Patterns over CVEs. If a refresh item doesn’t generalize across targets, it doesn’t belong here.*
