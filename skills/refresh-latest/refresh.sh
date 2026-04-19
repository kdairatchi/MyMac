#!/usr/bin/env bash
# refresh-latest — fetcher + orchestrator
# Called by the skill. Pulls sources, caches raw output. Parsing/humanizing
# is done by Claude reading the cache (this script doesn't try to LLM-summarize).

set -uo pipefail

SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills/refresh-latest}"
CACHE="$SKILL_DIR/cache"
STATE="$SKILL_DIR/state.json"
SOURCES="$SKILL_DIR/sources.yaml"
TODAY=$(date -u +%Y-%m-%d)
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
UA="kdairatchi-refresh-latest/1.0"

mkdir -p "$CACHE"

# Init state if missing
if [[ ! -f "$STATE" ]]; then
  echo '{"last_run":null,"seen":[],"stats":{}}' > "$STATE"
fi

LAST_RUN=$(jq -r '.last_run // empty' "$STATE")
SINCE="${LAST_RUN:-$(date -u -d '2 days ago' +%Y-%m-%dT%H:%M:%SZ)}"

log() { printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$*" >&2; }
ok()  { printf '  ✓ %s\n' "$*" >&2; }
err() { printf '  ✗ %s\n' "$*" >&2; }

fetch() {
  local name="$1" url="$2" out="$CACHE/$name/$TODAY"
  mkdir -p "$(dirname "$out")"
  if curl -fsSL -A "$UA" --max-time 30 -o "$out" "$url" 2>/dev/null; then
    local sz; sz=$(stat -c%s "$out" 2>/dev/null || echo 0)
    ok "$name ($sz bytes)"
    return 0
  else
    err "$name (fetch failed)"
    return 1
  fi
}

fetch_github_commits() {
  local name="$1" repo="$2"
  local url="https://api.github.com/repos/$repo/commits?since=$SINCE&per_page=50"
  local out="$CACHE/$name/$TODAY.json"
  mkdir -p "$(dirname "$out")"
  local auth=()
  local tok="${CLASSIC_PAT:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
  [[ -n "$tok" ]] && auth=(-H "Authorization: Bearer $tok")
  if curl -fsSL -A "$UA" --max-time 30 "${auth[@]}" -H "Accept: application/vnd.github+json" -o "$out" "$url" 2>/dev/null; then
    local n; n=$(jq 'length' "$out" 2>/dev/null || echo 0)
    ok "$name ($n commits since $SINCE)"
    return 0
  else
    err "$name (github api fail)"
    return 1
  fi
}

log "refresh-latest — $TODAY (since $SINCE)"

export SKILL_DIR

# Parse sources.yaml — minimal yq-free parser for our flat structure.
# Simple: grep lines, extract name/type/url/repo/enabled.
python3 - <<'PY' > "$CACHE/.plan.json"
import re, json, sys, os
sources_path = os.path.join(os.environ["SKILL_DIR"], "sources.yaml")
try:
    import yaml  # noqa
    with open(sources_path) as f:
        data = yaml.safe_load(f)
    plan = []
    for name, cfg in (data.get("sources") or {}).items():
        if not cfg.get("enabled", True): continue
        plan.append({
            "name": name,
            "type": cfg.get("type"),
            "url": cfg.get("url",""),
            "repo": cfg.get("repo",""),
        })
    print(json.dumps(plan))
except ModuleNotFoundError:
    # Fallback bare parser (best-effort)
    with open(sources_path) as f:
        txt = f.read()
    blocks = re.split(r'\n  (\w+):\n', txt)
    plan=[]
    for i in range(1, len(blocks), 2):
        name = blocks[i]
        body = blocks[i+1]
        if "enabled: false" in body: continue
        m_type = re.search(r'type:\s*(\S+)', body)
        m_url  = re.search(r'url:\s*(\S+)', body)
        m_repo = re.search(r'repo:\s*(\S+)', body)
        plan.append({
            "name": name,
            "type": m_type.group(1) if m_type else None,
            "url":  m_url.group(1) if m_url else "",
            "repo": m_repo.group(1) if m_repo else "",
        })
    print(json.dumps(plan))
PY

export SKILL_DIR

ok_count=0; fail_count=0
while IFS= read -r item; do
  name=$(echo "$item" | jq -r .name)
  type=$(echo "$item" | jq -r .type)
  url=$(echo  "$item" | jq -r .url)
  repo=$(echo "$item" | jq -r .repo)
  case "$type" in
    rss|json|hackerone)
      # Expand {since}/{now} in URL
      u="${url//\{since\}/$SINCE}"
      u="${u//\{now\}/$NOW}"
      if fetch "$name" "$u"; then ok_count=$((ok_count+1)); else fail_count=$((fail_count+1)); fi
      ;;
    github_commits)
      if fetch_github_commits "$name" "$repo"; then ok_count=$((ok_count+1)); else fail_count=$((fail_count+1)); fi
      ;;
    *)
      err "$name (unknown type: $type)"
      fail_count=$((fail_count+1))
      ;;
  esac
done < <(jq -c '.[]' "$CACHE/.plan.json")

log "fetched: $ok_count ok, $fail_count failed"
log "raw cache: $CACHE/"
log "next: Claude reads cache/, dedupes vs state.seen[], humanizes, files into /home/anon/MyMac/"

# Write a manifest Claude will consume
MANIFEST="$CACHE/manifest-$TODAY.json"
jq -n --arg today "$TODAY" --arg since "$SINCE" --arg now "$NOW" \
  --argjson ok "$ok_count" --argjson fail "$fail_count" \
  '{today:$today, since:$since, now:$now, fetched_ok:$ok, fetched_fail:$fail}' \
  > "$MANIFEST"

log "manifest: $MANIFEST"
echo "$MANIFEST"
