# refresh-latest

Daily cybersecurity research refresh for `MyMac`. Pulls, dedupes, humanizes, files, commits.

## Manual run

```
/refresh-latest
```

## Schedule daily

```
/ecc:schedule
```

Then create trigger:
- Name: `refresh-latest`
- Cron: `0 13 * * *` (08:00 CT)
- Skill: `refresh-latest`

Or loop:
```
/loop 24h /refresh-latest
```

## Dry run (no commit)

```
/refresh-latest dry
```

## Files

- `SKILL.md` — process definition (Claude reads this)
- `sources.yaml` — feeds, toggleable
- `refresh.sh` — fetcher (bash + python3 + jq + curl)
- `humanize.md` — voice guide
- `cache/` — raw fetches (gitignored)
- `state.json` — seen hashes + stats (gitignored)

## Deps

- `bash`, `curl`, `jq`, `python3` (optional: `python3-yaml` for richer parsing)
- Optional env: `GITHUB_TOKEN` (GitHub API rate limit lift)

## Tuning

Edit `sources.yaml`:
- `enabled: false` to mute a source
- `max_per_class` caps noise
- Add new sources by copying a block

## Why this exists

Cybersecurity moves daily. Manual tracking decays. This turns a 30-min AM ritual into a reviewed diff. Content lands in `MyMac/` dated and voiced — so the repo is never stale and the brand stays consistent.

## Roadmap (user-driven)

- [ ] Auto-generate weekly newsletter roll-up (substack-ready markdown)
- [ ] Pro-tier private supplement (PoCs, nuclei templates)
- [ ] RAG index of daily notes for Q&A
- [ ] Discord/Telegram push of top-3 daily
