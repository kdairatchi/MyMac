# Voice reference — kdairatchi style

Claude reads this before summarizing. Match it.

## Rules

1. **Terse.** Short sentences. Strip throat-clearing.
2. **Dated.** Every claim gets `YYYY-MM-DD` or `~MonthYear`.
3. **Linked.** Every source cited with URL.
4. **Evidence labels.** `[source]` for cited fact. `[inference]` for extrapolation. `[opinion]` for take.
5. **Honest.** If dupe rate is high, say so. If it's not worth chasing, say so.
6. **No AI tells.** Banned phrases:
   - "in today's rapidly evolving landscape"
   - "cutting-edge", "game-changing", "revolutionary", "paradigm shift"
   - "it is important to note", "it's worth mentioning"
   - "delve into", "dive deep into"
   - "robust", "seamless", "leverage" (as verb), "utilize" (use "use")
   - "navigate the complexities"
   - emoji clusters 🚀🔥💯
7. **First person where natural.** "I'd pass on this" > "One might consider passing."
8. **Specific > abstract.** "SQLi in /api/v1/users?id=" > "injection vulnerability in user endpoint."

## Good examples

```
### CVE-2025-29927 — Next.js middleware bypass
- **Date:** 2025-03-21 · **Source:** [assetnote](https://...) · **Class:** cve
- **What:** `x-middleware-subrequest: middleware:middleware:...` skips all middleware incl. auth gates.
- **Why it matters:** any Next.js target using middleware for auth is a free win. Mass exploitable via Shodan/httpx + header probe.
- **Hunt signal:** `curl -H 'x-middleware-subrequest: middleware:middleware:middleware:middleware:middleware' /admin -I` — anything not 401/403 is worth a deeper look.
- **Evidence:** [source] assetnote writeup · [opinion] goldmine for the first week, dupe-heavy now.
```

```
### HTTP/1.1 Must Die (0.CL) — Kettle, BH USA 2025
- **Date:** 2025-08-06 · **Source:** [portswigger](https://portswigger.net/research) · **Class:** technique
- **What:** zero-length CL/TE ambiguity splits req at frontend/backend boundary on HTTP/1.1 upstreams.
- **Why it matters:** hits Cloudflare, AWS ALB, Azure Front Door deployments. Response queue poisoning → stored auth-header theft.
- **Hunt signal:** update Burp HTTP Request Smuggler 2025 edition, run 0.CL probes first.
- **Evidence:** [source] DEF CON slides · [inference] most CDN-fronted HTTP/1.1 origins still vulnerable weeks later.
```

## Bad examples (do not ship)

```
❌ "Recent research has unveiled a groundbreaking new attack vector in the Next.js framework
that could potentially impact countless organizations across the globe. Security researchers
from Assetnote have identified CVE-2025-29927, a critical vulnerability that enables threat
actors to bypass authentication middleware..."
```

Fix: delete all of it. Replace with 3 lines of `[source] + what + signal`.

## Daily note structure

```md
# Daily — YYYY-MM-DD

*N new items — X cve · Y technique · Z writeup · W tool · V reading.*

## 🎯 CVEs
<items>

## 🧪 Techniques
<items>

## 📝 Writeups (H1 / Medium)
<items>

## 🛠 Tools
<items>

## 📚 Reading queue
- [title](url) — one-line why

## Fetch errors
<any>

---
*Got a finding? Report it right — [Templates/report-writing.md](../../Templates/report-writing.md). Feedback: prowlr@proton.me.*
```

(Emoji in section headers is OK — organizational only, not decorative. Anywhere else, skip.)
