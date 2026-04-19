#!/usr/bin/env bash
# fabric-compress — stage 2 of refresh-latest
# ONE API call per item (kdai_item pattern outputs frontmatter + summary together).
# Parallel: up to MAX_PARALLEL sources concurrently; MAX_API_CALLS global fabric
# calls at once via fd-8 semaphore to stay within Z.AI rate limits.

set -uo pipefail

SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills/refresh-latest}"
CACHE="$SKILL_DIR/cache"
COMPRESSED="$CACHE/compressed"
STATE="$SKILL_DIR/state.json"
FABRIC="${FABRIC_BIN:-$HOME/go/bin/fabric}"
TODAY=$(date -u +%Y-%m-%d)
MAX_PARALLEL="${FABRIC_PARALLEL:-6}"
MAX_API_CALLS="${FABRIC_MAX_API:-4}"

mkdir -p "$COMPRESSED"
log() { printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$*" >&2; }

# ── Source config (disabled list + max_items) ────────────────────────────────
SOURCES_YAML="$SKILL_DIR/sources.yaml"
_SRC_CONFIG=$(python3 - "$SOURCES_YAML" <<'PY'
import sys, json
try:
    import yaml
    data = yaml.safe_load(open(sys.argv[1]))
except ImportError:
    # yaml not available — minimal parser for our simple format
    import re
    data = {'sources': {}}
    cur = None
    for line in open(sys.argv[1]):
        m = re.match(r'^  (\w+):$', line)
        if m: cur = m.group(1); data['sources'][cur] = {}; continue
        if cur:
            me = re.match(r'^    (enabled|max_items):\s*(.+)', line)
            if me: data['sources'][cur][me.group(1)] = me.group(2).strip()
disabled = [s for s,v in data.get('sources',{}).items() if str(v.get('enabled','true')).lower() == 'false']
max_items = {s: int(v['max_items']) for s,v in data.get('sources',{}).items() if 'max_items' in v}
print(json.dumps({'disabled': disabled, 'max_items': max_items}))
PY
)
DISABLED_SOURCES=$(echo "$_SRC_CONFIG" | python3 -c "import sys,json; d=json.load(sys.stdin); print('\n'.join(d['disabled']))" 2>/dev/null || true)
get_max_items() { echo "$_SRC_CONFIG" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['max_items'].get('$1', 15))" 2>/dev/null || echo 15; }
is_disabled() { echo "$DISABLED_SOURCES" | grep -qxF "$1"; }

# ── Single-instance guard ────────────────────────────────────────────────────
LOCK="$CACHE/.compress.lock"
exec 9>"$LOCK"
if ! flock -n 9; then
  log "already running — exiting"; exit 0
fi

[[ ! -x "$FABRIC" ]] && { log "fabric not found — skipping"; exit 0; }

# ── Global API semaphore (fd 8, MAX_API_CALLS tokens) ───────────────────────
_F=$(mktemp -u); mkfifo "$_F"; exec 8<>"$_F"; rm -f "$_F"; unset _F
for _i in $(seq 1 "$MAX_API_CALLS"); do printf 'T' >&8; done; unset _i
acquire_api() { local _t; read -r -n1 _t <&8; }
release_api()  { printf 'T' >&8; }

# ── Seen-hash helpers ────────────────────────────────────────────────────────
SEEN_FILE="$CACHE/.seen.txt"
jq -r '.seen[]?' "$STATE" 2>/dev/null > "$SEEN_FILE"
sha()     { printf '%s' "$1" | sha256sum | awk '{print $1}'; }
is_seen() { grep -qxF "$1" "$SEEN_FILE" 2>/dev/null; }

# ── Feed extractors ──────────────────────────────────────────────────────────
extract_rss_items() {
  local path="$1" max="${2:-15}"
  python3 - "$path" "$max" <<'PY'
import sys, re, html, xml.etree.ElementTree as ET, json, os
path, max_items = sys.argv[1], int(sys.argv[2])
try:
    size = os.path.getsize(path)
    strip = lambda tag: tag.split('}')[-1]
    results = []
    if size > 2_000_000:
        # Large feed: stream with iterparse, stop after max_items entries
        cur = {}
        in_item = False
        for event, el in ET.iterparse(path, events=('start','end')):
            tag = strip(el.tag)
            if event == 'start' and tag in ('item','entry'):
                cur = {}; in_item = True
            elif event == 'end' and in_item:
                if tag in ('title','pubDate','published','updated','description','content','summary'):
                    cur[tag] = (el.text or '').strip()
                elif tag == 'link':
                    cur['link'] = el.text or el.attrib.get('href','')
                elif tag in ('item','entry'):
                    results.append(cur); cur = {}; in_item = False
                    if len(results) >= max_items: break
    else:
        tree = ET.parse(path); root = tree.getroot()
        for el in root.iter(): el.tag = strip(el.tag)
        for it in (root.findall('.//item') + root.findall('.//entry'))[:max_items]:
            def t(tag): n = it.find(tag); return (n.text or '').strip() if n is not None and n.text else ''
            cur = {'title': t('title'), 'link': t('link') or (it.find('link').attrib.get('href','') if it.find('link') is not None else ''),
                   'pubDate': t('pubDate') or t('published') or t('updated'),
                   'description': t('description') or t('content') or t('summary')}
            results.append(cur)
    for it in results:
        title = it.get('title','')
        link  = it.get('link','')
        date  = it.get('pubDate','') or it.get('published','') or it.get('updated','')
        body  = it.get('description','') or it.get('content','') or it.get('summary','')
        body  = re.sub(r'<[^>]+>', ' ', html.unescape(body))[:2000]
        if not (title and link): continue
        print(json.dumps({'url':link,'title':title,'date':date,'body':body}))
except Exception as e:
    print(f"# parse error: {e}", file=sys.stderr)
PY
}

extract_json_items() {
  local path="$1" max="${2:-15}"
  python3 - "$path" "$max" <<'PY'
import sys, json
path, max_items = sys.argv[1], int(sys.argv[2])
try:    data = json.load(open(path))
except: sys.exit(0)
if isinstance(data, dict) and 'vulnerabilities' in data:
    for v in data['vulnerabilities'][:max_items]:
        c = v.get('cve', {})
        cid  = c.get('id','')
        desc = next((d['value'] for d in c.get('descriptions',[]) if d.get('lang')=='en'), '')
        pub  = c.get('published','')[:10]
        print(json.dumps({'url':f"https://nvd.nist.gov/vuln/detail/{cid}",'title':cid,'date':pub,'body':desc}))
elif isinstance(data, dict) and 'data' in data and 'children' in data.get('data',{}):
    for p in data['data']['children'][:max_items]:
        d = p.get('data',{})
        print(json.dumps({'url':f"https://reddit.com{d.get('permalink','')}",'title':d.get('title',''),'date':'','body':d.get('selftext','')[:1000]}))
elif isinstance(data, dict) and 'hits' in data:
    for h in data['hits'][:max_items]:
        print(json.dumps({'url':h.get('url') or f"https://news.ycombinator.com/item?id={h.get('objectID','')}",'title':h.get('title',''),'date':h.get('created_at','')[:10],'body':h.get('story_text','') or ''}))
elif isinstance(data, list) and data and 'commit' in data[0]:
    for c in data[:max_items]:
        msg = c.get('commit',{}).get('message','')
        print(json.dumps({'url':c.get('html_url',''),'title':msg.split('\n')[0][:120],'date':c.get('commit',{}).get('author',{}).get('date','')[:10],'body':msg[:1500]}))
PY
}

# ── Class hint (passed in payload so model knows what summary format to use) ─
class_for() {
  case "$1" in
    portswigger_research|assetnote_research|project_zero|anthropic_security|openai_blog) echo technique ;;
    watchtowr_labs|nvd_recent|trickest_cve|nomi_sec_poc) echo cve ;;
    hackerone_hacktivity|medium_bugbounty|medium_infosec|medium_pentesting) echo writeup ;;
    nuclei_templates|awesome_hahwul|awesome_bugbounty_edoverflow) echo tool ;;
    *) echo reading ;;
  esac
}

# ── Per-item model (single call now — use quality model for important classes) ─
model_for() {
  local env_var="FABRIC_MODEL_kdai_item_${1}"
  if [[ -n "${!env_var:-}" ]]; then echo "${!env_var}"; return; fi
  case "$1" in
    cve|technique|writeup) echo "${FABRIC_MODEL_kdai_item:-glm-4.7}" ;;
    *)                      echo "${FABRIC_MODEL_kdai_item:-glm-4.5-air}" ;;
  esac
}

FALLBACK="${FABRIC_FALLBACK_MODEL:-glm-4.5-air}"

# ── Per-source worker ────────────────────────────────────────────────────────
process_source() {
  local src_dir="$1" stats_dir="$2"
  local src; src=$(basename "$src_dir")

  # Skip disabled sources (avoid wasting tokens on old cached data)
  if is_disabled "$src"; then
    log "[$src] disabled — skipping"
    echo "0 0 0" > "$stats_dir/$src"
    return 0
  fi

  local raw; raw=$(ls -t "$src_dir" 2>/dev/null | head -1)
  [[ -z "$raw" ]] && return 0
  local raw_path="$src_dir$raw"

  local max_items; max_items=$(get_max_items "$src")

  local items
  if head -c 100 "$raw_path" | grep -qE '^(<\?xml|<rss|<feed)'; then
    items=$(extract_rss_items "$raw_path" "$max_items")
  elif head -c 1 "$raw_path" | grep -qE '^[\{\[]'; then
    items=$(extract_json_items "$raw_path" "$max_items")
  else
    return 0
  fi
  [[ -z "$items" ]] && return 0

  local class out_dir
  class=$(class_for "$src")
  out_dir="$COMPRESSED/$src/$TODAY"
  mkdir -p "$out_dir"

  local total=0 compressed=0 skipped=0

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local url; url=$(echo "$line" | jq -r .url)
    [[ -z "$url" || "$url" == "null" ]] && continue
    local h; h=$(sha "$url")

    if is_seen "$h"; then skipped=$((skipped+1)); continue; fi

    local out_file="$out_dir/$h.md"
    if [[ -f "$out_file" ]]; then
      if [[ "$(head -c 3 "$out_file")" == "---" ]]; then
        skipped=$((skipped+1)); continue
      fi
      rm -f "$out_file"
    fi

    local title date body
    title=$(echo "$line" | jq -r .title)
    date=$(echo "$line"  | jq -r .date)
    body=$(echo "$line"  | jq -r .body)

    local payload="---
url: $url
title: $title
date: $date
class: $class
source: $src
---

$body"

    local model; model=$(model_for "$class")

    # Single call: frontmatter + summary together
    acquire_api
    local result
    result=$(echo "$payload" | timeout 90 "$FABRIC" -p kdai_item -m "$model" 2>/dev/null)
    release_api

    # 429 backoff + fallback
    if echo "$result" | grep -qiE "429|Too Many Requests|Rate limit"; then
      log "[$src] 429 — backoff 15s then fallback"
      result=""
      sleep 15
      acquire_api
      result=$(echo "$payload" | timeout 90 "$FABRIC" -p kdai_item -m "$FALLBACK" 2>/dev/null)
      release_api
    elif [[ -z "$result" || ${#result} -lt 80 ]]; then
      acquire_api
      result=$(echo "$payload" | timeout 90 "$FABRIC" -p kdai_item -m "$FALLBACK" 2>/dev/null)
      release_api
    fi

    if [[ "${result:0:3}" == "---" && ${#result} -ge 80 ]]; then
      echo "$result" > "$out_file"
      log "[$src] ok: $title"
      compressed=$((compressed+1))
    else
      rm -f "$out_file"
      log "[$src] fail: $title"
    fi
    total=$((total+1))
  done <<< "$items"

  echo "$compressed $total $skipped" > "$stats_dir/$src"
}

# ── Main loop ────────────────────────────────────────────────────────────────
STATS_DIR=$(mktemp -d)
PIDS=(); active=0

for src_dir in "$CACHE"/*/; do
  src=$(basename "$src_dir")
  [[ "$src" == "compressed" ]] && continue

  while (( active >= MAX_PARALLEL )); do
    wait -n 2>/dev/null || wait "${PIDS[0]}"
    PIDS=("${PIDS[@]:1}"); active=$((active-1))
  done

  process_source "$src_dir" "$STATS_DIR" &
  PIDS+=($!); active=$((active+1))
done

for pid in "${PIDS[@]}"; do wait "$pid" 2>/dev/null || true; done

# ── Aggregate + state update ─────────────────────────────────────────────────
total=0; compressed=0; skipped=0
for f in "$STATS_DIR"/*; do
  [[ -f "$f" ]] || continue
  read -r c t s < "$f"
  compressed=$((compressed+c)); total=$((total+t)); skipped=$((skipped+s))
done
rm -rf "$STATS_DIR"

log "compressed: $compressed / $total attempted ($skipped skipped)"

python3 - <<PY
import json
state = json.load(open("$STATE"))
state["last_compress"] = "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
json.dump(state, open("$STATE","w"), indent=2)
PY

echo "$COMPRESSED"
