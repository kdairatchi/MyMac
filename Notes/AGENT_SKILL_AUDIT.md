---
audit_date: 2026-05-14
operator: kdairatchi
counts: 20 agents, 55 skills, 85 commands
---

# Agent + Skill + Command Audit — KEEP / MERGE / KILL

> **Goal:** stop the clutter. The workspace has too many overlapping things. Right now: 20 agents, 55 skills, 85 commands. Half are duplicates or stale. After this audit: ~10 agents, ~20 skills, ~30 commands. Less is more.

## Decision criteria
- **KEEP** = used in last sprint OR maps to a money-making class
- **MERGE** = overlaps with another; combine into single entry
- **KILL** = unused, stale, or for a workflow you've abandoned (engagement-style pentest, web3, infra-mgmt)

---

## Agents (20 → 10 keep + 2 merged + 8 killed)

### KEEP (10 — your core hunt loop)
| Agent | Why keep | Last useful |
|---|---|---|
| `autopilot` | Full hunt cycle scope→recon→hunt→validate→report. Use with `--paranoid` for new programs. | every sprint |
| `recon-agent` | Active recon pipeline (subfinder/httpx/katana/nuclei). Foundation. | every new target |
| `recon-ranker` | Turns recon output into ranked attack surface. Use after every recon run. | last 5 sessions |
| `scope-auditor` | Verifies in-scope before any active testing. Catches stale scope. | every session |
| `validator` | 7-Question Gate. Kills weak findings before report. **Save this**, prevents N/A submissions. | every report |
| `report-writer` | H1/Bugcrowd/Intigriti report formatting + CVSS. Final-mile tool. | every report |
| `loss-curator` | Post-submit close-out. Tags lessons into memory. **Critical for learning loop.** | every closed report |
| `payout-analyst` | $/hour + ROI rank from journal. Uses real data not gut. | weekly |
| `chain-builder` | Escalates Lows to Highs. Has known patterns (IDOR→ATO, SSRF→cloud, etc). | when stuck on Low |
| `red-team-reproducer` | Replay past wins for variant hunt + chain candidates. | re-hunting Hostinger |

### MERGE → `hunt-pulse` (combine 3 agents)
- `hunt-dashboard` + `hunt-watchdog` + `bias-detector` → **`hunt-pulse`** (one daily check)
- All three answer "how am I doing right now?" — split is friction. One unified status agent.
- **Action:** create `agents/hunt-pulse.md` combining the prompts; archive the 3 old files to `agents/_archive/`

### MERGE → `intel` (combine 2 agents)
- `technique-scout` + `intel-harvester` → **`intel`**
- Both pull external context (techniques, CVEs, writeups). Single agent, multiple modes.
- **Action:** create `agents/intel.md`; archive originals

### KILL (5 — clutter)
| Agent | Why kill | What replaces it |
|---|---|---|
| `agency-dispatcher` | 0 wins from agency runs in journal; your workflow is sequential not parallel | manually invoke `autopilot` with `--handle X` |
| `web3-auditor` | TRON closed Dup; no other web3 in queue; revisit when re-picking web3 | nothing — re-create when needed |
| `gap-researcher` | Overlaps with skill-recommender hook | skill-recommender hook |
| `rules-enforcer` | Overlaps with `validator` and `scope-auditor` | those two combined |
| `code-reviewer` | Useful but only for tooling self-audit, low-frequency | direct invocation when editing tools |

---

## Skills (55 → 18 keep + 6 merged → 3 + 31 killed/archived)

### KEEP (18 — actually used or maps to attack class)
**Hunt loop (5):**
- `bug-bounty` — master orchestrator
- `web2-recon` — recon execution
- `web2-vuln-classes` — class reference
- `caido-db` — Caido SQLite mining (used heavily this sprint)
- `krait` — your custom IDOR/SSRF tool

**Vuln-class deep dives (5):**
- `js-security` — frontend XSS / postMessage / DOM
- `http-smuggling` — niche but high-pay
- `fuzzing` — controlled active fuzzing
- `ai-assistant-attacks` — ASI / prompt injection (eero, smtp2go AI integrations)
- `cve-hunt` — CVE intel + variant hunt

**Specialized (8):**
- `mobile` — Android/iOS APK + Frida
- `opsec` — IP rotation, account hygiene
- `secret-scanning` — leaked credentials in repos
- `cdn-bypass-arsenal` — WAF bypass payloads
- `nuclei-template-gen` — custom template authorship
- `report-writing` — companion to report-writer agent
- `triage-validation` — companion to validator agent
- `osint` — target intel gathering

### MERGE → 3 master skills (combine 8 → 3)
| New skill | Combines | Why |
|---|---|---|
| `bb-master` | `bb-methodology` + `bug-bounty` + `structured-analysis` | Three skills cover same methodology — one canonical source |
| `cve-intel` | `cve-hunt` + `daily-cve-intel` + `searchsploit` | All CVE-related; single skill for all variant hunting + active CVE refresh |
| `pre-hunt` | `complex-hunt` + `complex-study` + `target-intel` | All "what to know before hunting" |

### KILL or move to `infra/` (29)
**Move to `infra/` (devops, not hunt):**
- `node-mac` · `node-pi` · `node-vps` · `node-wsl` · `mesh-agency` · `hermes-bounty-ops` · `grafana-oss`

**Niche / stale (delete):**
- `blockchain-source-audit` · `web3-audit` · `smart-contract-report` · `crypto` (no web3 in queue)
- `vulnerableai` (test infra, not for bounty)
- `netscaler` · `mongodb-atlas-methodology` · `mongodb-drivers-security` (single-target — fold into target's CHEATSHEET.md when active)
- `openclaw-pentest` (engagement-style, not bounty)
- `poc-recording` (use OBS Studio + screen-record manually, not a skill)
- `binary-re` (defer until binary target)
- `cloud` (overlaps with cloud sections of bug-bounty)
- `network` · `netcat` (basic, no need for dedicated skill)
- `mcp-attack` (developmental, not yet productive)
- `social-engineering` (out of scope for almost all bounty programs)
- `client-auth-hunt` (covered in `bug-bounty` auth section)
- `mobile-api-bounty` (overlaps `mobile`)
- `metadata-exfil` (single technique; fold into A10_ssrf cheatsheet)
- `origin-ip-finder` (one-off; fold into `cdn-bypass-arsenal`)
- `platform-batteries` (developmental)
- `html-views` (UI work, not hunt)
- `source-bounty` (rename to `source-audit`, keep as one skill — moved to KEEP if used)
- `shodan` (use shodan CLI directly)

---

## Commands (85 → ~30 keep + ~55 archived)

### KEEP (30) — bounty workflow
- Hunt: `/hunt`, `/recon`, `/scope`, `/intel`, `/validate`, `/report`, `/triage`
- Pre-hunt: `/target-pick`, `/new-target`, `/program-fetch`, `/cve-hunt`
- Memory: `/remember`, `/forget`, `/memory-diff`
- Loop: `/autopilot`, `/agency`, `/resume`, `/loop`
- Sandbox: `/sandbox`, `/badge`
- Specialized: `/web3-audit`, `/mobile-bounty`, `/source-bounty`, `/fuzz`, `/shodan`
- Personal: `/self`, `/badge`
- Slash-meta: `/help`, `/skills`, `/agents`
- BB-namespace: `bb:plan`, `bb:save`, `bb:checkpoint`

### KILL → archive to `commands/_pentest-archive/` (28 commands)
All `/p-*` commands are for client engagements (pentest), not bounty:
- `/p-export`, `/p-client-questions`, `/p-sec-stack`, `/p-brief`, `/p-challenge`, `/p-analyze`, `/p-timeline`, `/p-target`, `/p-checkpoint`, `/p-new-case`, `/p-collect`, `/p-status`, `/p-end`, `/p-handoff`, `/p-debrief`, `/p-osint`, `/p-screenshots`, `/p-link`, `/p-intake`, `/p-scope`, `/p-begin`, `/p-reality-check`

These are not deleted — moved to `commands/_pentest-archive/` so they're invokable when you take an engagement. Just out of the active palette.

### KILL outright (10)
- `/cai` — third-party tool, unused
- `/program-fetch.md` (duplicate of `/program-fetch`)
- Anything with no description / unclear purpose

### MERGE / RENAME (5)
- `/triage` + `/validate` are similar — consolidate into one
- `/agency` overlaps with `/autopilot` if killing agency-dispatcher agent

---

## Vault dashboards (7 competing → 1 primary)

The vault has SEVEN dashboards in `00 - Dashboard/`:
- `Home.md`
- `Bug Bounty Hub.md`
- `Bug-Bounty-Old-Home.md`
- `Hunt Ops.md`
- `Master Playbook.md`
- `MyMac-Index.md`
- `Old-BB-Dashboard.md`

**This is the user-reported clutter.** They serve overlapping purposes.

### KEEP (1)
- `MISSION_2026-05-14.html` (this sprint's mission control — newly built)

### ARCHIVE (5) — move to `00 - Dashboard/_archive/`
- `Bug-Bounty-Old-Home.md`
- `Hunt Ops.md`
- `Master Playbook.md`
- `MyMac-Index.md`
- `Old-BB-Dashboard.md`

### KEEP if still useful (1, decide based on content)
- `Bug Bounty Hub.md` — if it links to current methodology pages, keep as MD index
- `Home.md` — Obsidian's main entry — keep, but make it link to MISSION_2026-05-14.html

### ACTION (manual cleanup the operator does)
```bash
VAULT="/mnt/c/Users/Dr34d/OneDrive/Documents/Obsidian Vault"
mkdir -p "$VAULT/00 - Dashboard/_archive"
cd "$VAULT/00 - Dashboard"
mv "Bug-Bounty-Old-Home.md" "Hunt Ops.md" "Master Playbook.md" \
   "MyMac-Index.md" "Old-BB-Dashboard.md" _archive/
# Edit Home.md to point at MISSION_2026-05-14.html
```

---

## Implementation order (do not do all at once)

1. **TODAY (2026-05-14):** read this audit, agree/disagree per item
2. **Day 6 (Mon 5-19, validate-day):** kill the 5 unused agents and 28 `/p-*` commands (low risk, easy)
3. **Day 7 (Tue 5-20, review-day):** merge the 2 agent groups + 3 skill groups
4. **Day 14 (Tue 5-27, retrospective):** archive the 5 stale dashboards in vault
5. **End of June:** re-audit. If any KEEP item wasn't used in 30 days → demote to archive.

---

## Why this matters for the $2k goal
- Less clutter = faster decision-making during a session
- Cleaner agent set = clearer routing in autopilot
- Single dashboard = no switching tabs to remember the goal
- Skills focused on $-class = time on workhorses (SSRF, IDOR, OAuth) not noise

## Where this links
- ← [Mission Control](../MISSION_CONTROL.html)
- → [Sprint 2026-05-14](../sprint/SPRINT_2026-05-14.md)
