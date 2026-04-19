#!/usr/bin/env bash
# run.sh — full pipeline orchestrator for refresh-latest
# Stages: fetch → compress+tag → publish (cluster+rank+file) → state update
# Intended to be invoked by /refresh-latest skill or daily cron.

set -uo pipefail
SKILL="${SKILL_DIR:-$HOME/.claude/skills/refresh-latest}"

log() { printf '\033[36m[%s]\033[0m %s\n' "$(date -u +%H:%M:%S)" "$*"; }
die() { printf '\033[31m[FATAL]\033[0m %s\n' "$*" >&2; exit 1; }

log "stage 1/3 — fetch"
"$SKILL/refresh.sh" >/dev/null || die "fetch stage failed"

log "stage 2/3 — compress + tag (fabric)"
"$SKILL/fabric-compress.sh" || die "compress stage failed"

log "stage 3/3 — cluster + rank + publish"
python3 "$SKILL/publish.py" || die "publish stage failed"

log "done. commit step is manual — review Latest-2026/ first, then 'git add' + commit as kdairatchi."
