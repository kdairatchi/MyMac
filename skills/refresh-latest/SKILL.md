---
name: refresh-latest
description: |
  Daily cybersecurity research refresh for kdairatchi's MyMac bug bounty workbench. Pulls from PortSwigger Research, watchTowr, Assetnote, HackerOne Hacktivity, Medium infosec/bug-bounty feeds, awesome-lists, GitHub CVE libraries (trickest/cve, nomi-sec/PoC-in-GitHub), nuclei-templates commits, NVD recent CVEs, Anthropic/OpenAI security blogs, and r/netsec. Dedupes against state, summarizes in kdairatchi's voice (terse, no AI slop, dated, evidence-labeled), drops content into /home/anon/MyMac/Latest-2026/ and /home/anon/MyMac/Notes/daily/<date>.md, commits as kdairatchi. Goal: make MyMac the #1 bug bounty research repo.
trigger: |
  User says "refresh latest", "daily research", "update MyMac with new attacks", "refresh knowledge", "/refresh-latest", or this skill is fired by a cron/loop.
---

# refresh-latest

**Mission:** every run, pull the newest real attack research, dedupe against last run, summarize in kdairatchi's voice, file it into `/home/anon/MyMac/` in the right place, commit. No AI filler, no stale facts, every claim dated and linked.

## Voice (non-negotiable — this is the moat)

Write in kdairatchi's style. **Terse. Honest. Dated. First-person where natural. No hype.**

- ❌ "In the ever-evolving cybersecurity landscape..."
- ❌ "Researchers have recently discovered a fascinating..."
- ❌ "It's important to note that..."
- ✅ "Kettle dropped 0.CL at DEF CON. Works on Cloudflare-fronted HTTP/1.1 upstreams. PoC in slides."
- ✅ "CVE-2025-XXXX. Unauth RCE. Patched April. Probe: `curl -H '...' /admin`."
- ✅ "I wouldn't chase this one — dupe rate on H1 is already high."

Every item has: **date**, **source link**, **one-line what**, **one-line why-it-matters**, **one-line hunt-signal-or-pass**.

Evidence labels required: `[source]`, `[inference]`, `[opinion]`.

## Sources (curated, ranked by signal-to-noise)

See `sources.yaml`. Summary:

| Tier | Source | Format |
|---|---|---|
| S | PortSwigger Research | RSS |
| S | watchTowr Labs | RSS |
| S | Assetnote Research | RSS |
| S | Google Project Zero | RSS |
| S | trickest/cve (GitHub) | repo diff |
| S | nomi-sec/PoC-in-GitHub | repo diff |
| A | HackerOne Hacktivity (public disclosed) | JSON/HTML |
| A | nuclei-templates (new templates) | git log |
| A | NVD recent CVEs | JSON feed |
| A | Medium tag: bug-bounty, infosec | RSS |
| A | Intigriti Bug Bytes | RSS |
| A | Anthropic security + OpenAI blog | RSS |
| B | r/netsec top weekly | JSON |
| B | HackerNews Security tag | Algolia |
| B | awesome-* (hahwul, EdOverflow, vasanthk) | repo diff |

## Process (run top-to-bottom)

### 0. Bootstrap

```bash
REPO=/home/anon/MyMac
SKILL=/home/anon/.claude/skills/refresh-latest
STATE=$SKILL/state.json
TODAY=$(date -u +%Y-%m-%d)
DAILY=$REPO/Notes/daily/$TODAY.md
mkdir -p "$REPO/Notes/daily"
```

If `$DAILY` already exists, this is a re-run — append, don't overwrite.

### 1. Fetch

Run `$SKILL/refresh.sh` — fetches every source in `sources.yaml`, caches raw output to `$SKILL/cache/<source>/<date>.json|xml`, respects `last_run` in state.

**Guardrails:**
- All fetches through `scope_checker.py` if available (safe-list enforced)
- 30s timeout per source, continue on failure
- User-Agent: `kdairatchi-refresh-latest/1.0`
- No auth tokens except `GITHUB_TOKEN` from env (rate limit only)

### 1b. Compress via fabric

Run `$SKILL/fabric-compress.sh` — extracts individual items from each raw feed, pipes each through the matching fabric pattern (kdai_cve_brief / kdai_writeup_tldr / extract_wisdom / summarize / rate_content), writes markdown to `cache/compressed/<source>/<date>/<hash>.md`. Dedupes against `state.seen[]` automatically. Claude reads the **compressed** dir in step 4 — not raw XML/JSON — so token intake per run is ~70% lower.

### 2. Dedupe

For each item, compute `sha256(canonical_url)`. Skip if hash in `state.json.seen[]`. Keep `state.json.seen` capped at last 5000 (FIFO).

### 3. Classify

Each new item → one of:
- `cve` — specific CVE, goes to `Latest-2026/` or creates new file if class is new
- `technique` — novel attack technique → `Latest-2026/` or relevant `Cheatsheets/`
- `writeup` — H1/Medium disclosure → `Notes/writeups-2026.md`
- `tool` — new tool release → `Cheatsheets/tools-index.md` update
- `reading` — everything else → `Notes/daily/$TODAY.md` read queue

### 4. Humanize

For each classified item, produce a kdairatchi-voice block:

```md
### <title>
- **Date:** YYYY-MM-DD · **Source:** [<domain>](url) · **Class:** cve|technique|writeup|tool
- **What:** <one sentence, direct>
- **Why it matters:** <one sentence, concrete impact for bounty or defense>
- **Hunt signal:** <probe, grep, nuclei tag> OR "pass — low value for hunting"
- **Evidence:** [source] <link> · [inference] <what I extrapolated>
```

**Rules for summarization:**
1. If the source gives a CVE ID, **use it verbatim**. Do not paraphrase the ID.
2. If uncertain about a date, mark `[date ~approx]`.
3. If the source is paywalled or unfetchable, note `[title-only]` and link anyway.
4. Never invent CVE numbers, CVSS scores, or researcher names.
5. Three lines max per item in the daily. Depth goes into the class file.

### 5. File into the repo

- **Daily note** at `Notes/daily/$TODAY.md` — all new items, grouped by class
- **Class files** updated with full writeup blocks:
  - CVEs in 2025/2026 → append to matching `Latest-2026/<class>.md` with `## <date> — <cve>` header
  - New vuln class → create new `Latest-2026/<slug>.md` via template
  - H1/Medium writeups → `Notes/writeups-2026.md`
  - Tools → `Cheatsheets/tools-index.md`
- **Rollup** — `Latest-2026/README.md` gets `## Recent` section updated with last 10 items

### 6. Commit

Per CLAUDE.md:
- Author: `kdairatchi`
- Never commit CLAUDE.md, plans, agent files, `.claude/` state
- Only commit files under `$REPO`
- Message format:
  ```
  research: refresh YYYY-MM-DD — N items (X cve, Y technique, Z writeup)
  
  Sources: portswigger, watchtowr, h1, nvd, ...
  ```
- `git add` specific files (never `-A`)
- Run `git config user.name` check first — abort if not `kdairatchi`

### 7. Update state

Write `state.json`:
```json
{
  "last_run": "2026-04-15T12:00:00Z",
  "last_run_items": 12,
  "seen": ["<sha>", ...],
  "stats": { "cve": 3, "technique": 2, "writeup": 5, "tool": 1, "reading": 1 }
}
```

### 8. Surface

Print to stdout:
```
refresh-latest — 2026-04-15
  fetched: 14 sources
  new:     12 items (3 cve, 2 technique, 5 writeup, 1 tool, 1 reading)
  filed:   Notes/daily/2026-04-15.md + 4 class files
  commit:  <sha>
  next:    schedule next run in 24h
```

## Monetization angle (design from day one)

This repo is the marketing. Structure so pieces can graduate to paid tiers:

- **Free tier** — daily dated notes, public repo, awesome-list-visible
- **Newsletter** — weekly roll-up of the 10 best items in your voice → substack/buttondown
- **Pro tier (later)** — private supplement with PoCs, nuclei templates, Caido workflows, program-specific intel → Gumroad/Patreon
- **Tagged taxonomy** every item → supports future RAG search over your brand

Every daily note ends with: *"Got a finding? Report it right. Template: [Templates/report-writing.md]. Feedback / tips: prowlr@proton.me."*

## Schedule

Set up daily via ecc:schedule:
```
ecc:schedule create --name refresh-latest --cron "0 13 * * *" --skill refresh-latest
```
(13:00 UTC = 08:00 America/Chicago — after morning coffee)

Or via /loop: `/loop 24h /refresh-latest`

## Failure modes (anticipate)

- **Source down** → continue, note in daily under `## Fetch errors`
- **Rate limit** → back off, retry once, then skip
- **Dup storm** (e.g. nuclei 50 new templates) → cap class at 10 per run, overflow to `Notes/daily/overflow-$TODAY.md`
- **git commit blocked** (pre-commit hook) → fix root cause, never `--no-verify`
- **Identity mismatch** → abort, surface to user

## Tuning knobs

In `sources.yaml`:
- `enabled: true/false` per source
- `min_severity` for CVE sources (default: medium+)
- `max_items_per_run` (default 30 total, 10 per class)
- `quiet_hours`: skip fetch if current hour in list (courtesy to rate-limited APIs)

## Pipeline (new — taxonomy-enforced)

```
refresh.sh         → cache/<source>/<date>.{xml,json}    [fetch]
fabric-compress.sh → cache/compressed/<src>/<date>/*.md  [summary + kdai_tag_extract frontmatter]
publish.py         → MyMac/Latest-2026/*.md + _tags.md   [validate, cluster, rank, file]
                  ↳ cache/quarantine/<date>/             [items missing required fields]
```

Run all three with `./run.sh`. Each item that survives **must** have YAML frontmatter with: `class, title, tags (>=1 from vocab), severity, hunt_value (1-5), exploit_status, freshness_days, references`. Missing fields → quarantine, never published.

Cluster key: same CVE OR same (vendor, product, primary_tag). Highest-scoring member wins, others contribute source links.

Rank score: `severity_score × hunt_value × freshness × poc_boost`.

See `taxonomy.yaml` for the full controlled vocab + rubrics.

## Files in this skill

- `SKILL.md` — this file
- `sources.yaml` — source config + fabric model routing
- `taxonomy.yaml` — required fields, controlled tag vocab, hunt_value rubric
- `refresh.sh` — stage 1: fetch
- `fabric-compress.sh` — stage 2: summary + tag-extract
- `publish.py` — stage 3: validate, cluster, rank, file
- `run.sh` — orchestrator (runs all 3 stages)
- `humanize.md` — voice reference (sample outputs)
- `state.json` — runtime state (gitignored)
- `cache/` — raw fetches + compressed + quarantine (gitignored)

## Verification checklist before commit

- [ ] All new items have date + source link
- [ ] No invented CVE IDs (grep for `CVE-\d{4}-XXXX` placeholders — reject)
- [ ] Voice check: no "in today's landscape", "revolutionary", "game-changing", emoji clusters
- [ ] git user is `kdairatchi`
- [ ] No secrets / .env / CLAUDE.md in staged files
- [ ] Daily note ends with CTA line

---

*Ship quality > ship often. If a run produces 0 high-signal items, skip the commit and log "quiet day" to state.*
