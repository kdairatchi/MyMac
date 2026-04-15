#!/usr/bin/env bash
# update-all.sh — refresh + security-audit tools, runtimes, repos.
# Captures BEFORE/AFTER snapshots, runs vuln scanners, scans for supply-chain
# tampering in cloned repos, and emits a diff + markdown report.
#
# Usage:
#   ./update-all.sh                  # full run
#   ./update-all.sh --fast           # skip apt upgrade
#   ./update-all.sh --audit-only     # skip updates, run security audit only
#   ./update-all.sh --skip go,repos  # skip sections
#   ./update-all.sh --no-sync        # don't copy report anywhere external
#
# Sections: system go python rust node pdtm nuclei repos claude audit
#
# First-responder posture: logs every action, no silent failures, captures
# outbound package names before trusting them.
#
# Optional env vars:
#   VAULT        — path to external notes folder (e.g. Obsidian vault root)
#   VAULT_DROP   — subfolder inside VAULT to drop the daily report into

set -u
umask 077

# ---------- flags ----------
SKIP=""
FAST=0
AUDIT_ONLY=0
SYNC=1
for a in "$@"; do
  case "$a" in
    --fast)       FAST=1 ;;
    --audit-only) AUDIT_ONLY=1 ;;
    --no-sync)    SYNC=0 ;;
    --skip)       shift; SKIP="${1:-}" ;;
    --skip=*)     SKIP="${a#--skip=}" ;;
    -h|--help)    sed -n '2,17p' "$0"; exit 0 ;;
  esac
done
skip() { [[ ",$SKIP," == *",$1,"* ]]; }

# ---------- paths ----------
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
TODAY="$(date -u +%Y-%m-%d)"
OUT="$HOME/.local/state/update-all/$STAMP"
LATEST="$HOME/.local/state/update-all/latest"
VAULT="${VAULT:-}"
VAULT_DROP="${VAULT_DROP:-${VAULT:+$VAULT/01 - Inbox}}"
mkdir -p "$OUT"

LOG="$OUT/run.log"
REPORT="$OUT/report.md"
BEFORE="$OUT/snapshot.before.json"
AFTER="$OUT/snapshot.after.json"
DIFF="$OUT/diff.txt"
AUDIT="$OUT/audit.md"
SUSPECT="$OUT/supply-chain.txt"

# ---------- logging ----------
c_reset=$'\033[0m'; c_cyan=$'\033[1;36m'; c_yellow=$'\033[1;33m'; c_red=$'\033[1;31m'; c_green=$'\033[1;32m'
log()   { printf '\n%s[+] %s%s\n' "$c_cyan" "$*" "$c_reset" | tee -a "$LOG"; }
warn()  { printf '%s[!] %s%s\n'   "$c_yellow" "$*" "$c_reset" | tee -a "$LOG"; }
err()   { printf '%s[x] %s%s\n'   "$c_red"    "$*" "$c_reset" | tee -a "$LOG"; }
ok()    { printf '%s[done] %s%s\n' "$c_green"  "$*" "$c_reset" | tee -a "$LOG"; }
run()   { echo "    \$ $*" | tee -a "$LOG"; "$@" >>"$LOG" 2>&1 || warn "failed: $*"; }
have()  { command -v "$1" >/dev/null 2>&1; }

exec > >(tee -a "$LOG") 2>&1
echo "# update-all run $STAMP" >"$LOG"

# ---------- snapshot helper ----------
snapshot() {
  local out="$1"
  {
    echo "{"
    echo "  \"ts\": \"$(date -u +%FT%TZ)\","
    echo -n "  \"go\": ["
    if have go && [[ -d $HOME/go/bin ]]; then
      ls "$HOME/go/bin" 2>/dev/null | awk 'BEGIN{f=0}{printf("%s\"%s\"", f?",":"", $0); f=1}'
    fi
    echo "],"
    echo -n "  \"pipx\": ["
    have pipx && pipx list --short 2>/dev/null | awk 'BEGIN{f=0}{printf("%s\"%s@%s\"", f?",":"", $1, $2); f=1}'
    echo "],"
    echo -n "  \"cargo\": ["
    [[ -f $HOME/.cargo/.crates.toml ]] && awk -F'"' '/^"/{printf("%s\"%s\"", f?",":"", $2); f=1}' "$HOME/.cargo/.crates.toml"
    echo "],"
    echo -n "  \"npm_g\": ["
    have npm && npm ls -g --depth=0 --json 2>/dev/null | python3 -c 'import sys,json;d=json.load(sys.stdin).get("dependencies",{});print(",".join(f"\"{k}@{v.get(\"version\",\"?\")}\"" for k,v in d.items()))' 2>/dev/null
    echo "],"
    echo "  \"kernel\": \"$(uname -r)\","
    echo "  \"apt_upgradable\": $(apt list --upgradable 2>/dev/null | wc -l)"
    echo "}"
  } >"$out"
}

# ============================================================
# PHASE 1 — BEFORE snapshot
# ============================================================
log "snapshot (before)"
snapshot "$BEFORE"

# ============================================================
# PHASE 2 — UPDATES (unless --audit-only)
# ============================================================
if [[ $AUDIT_ONLY -eq 0 ]]; then

  # System
  if ! skip system; then
    log "apt update & upgrade"
    run sudo apt-get update -y
    [[ $FAST -eq 0 ]] && run sudo apt-get upgrade -y
    run sudo apt-get autoremove -y
  fi

  # Go
  if ! skip go && have go; then
    log "go tools refresh"
    for bin in "$HOME"/go/bin/*; do
      [[ -x "$bin" ]] || continue
      mod=$(go version -m "$bin" 2>/dev/null | awk '$1=="path"{print $2; exit}')
      [[ -n "$mod" ]] && run go install "${mod}@latest"
    done
  fi

  # ProjectDiscovery + nuclei
  if ! skip pdtm && have pdtm; then log "pdtm -ut"; run pdtm -ut; fi
  if ! skip nuclei && have nuclei; then log "nuclei templates"; run nuclei -update-templates -silent; fi

  # Python
  if ! skip python; then
    have pipx && { log "pipx upgrade-all"; run pipx upgrade-all; }
    if have pip; then
      log "pip --user outdated"
      pip list --user --outdated --format=json 2>/dev/null | \
        python3 -c 'import sys,json;[print(p["name"]) for p in json.load(sys.stdin)]' | \
        xargs -r -n1 pip install --user -U >>"$LOG" 2>&1 || true
    fi
  fi

  # Rust
  if ! skip rust && have rustup; then
    log "rustup + cargo-install-update"
    run rustup update
    have cargo-install-update && run cargo install-update -a
  fi

  # Node
  if ! skip node && [[ -s $HOME/.nvm/nvm.sh ]]; then
    log "npm globals"
    # shellcheck disable=SC1091
    . "$HOME/.nvm/nvm.sh"
    have npm && run npm update -g
  fi

  # Repos — integrity-aware pull
  if ! skip repos; then
    log "git pull across repo roots (integrity-aware)"
    ROOTS=(
      "$HOME/Tools" "$HOME/recon" "$HOME/bounty" "$HOME/ext"
      "$HOME/nuclei-templates" "$HOME/bounty-targets-data"
      "$HOME/DefaultCreds-cheat-sheet" "$HOME/atomic-red-team"
      "$HOME/.oh-my-zsh" "$HOME/mcp"
      "$HOME/reconftw" "$HOME/theHarvester" "$HOME/spiderfoot"
    )
    pull_one() {
      local d="$1"
      local before after url
      url=$(git -C "$d" remote get-url origin 2>/dev/null || echo "?")
      before=$(git -C "$d" rev-parse HEAD 2>/dev/null || echo "?")
      git -C "$d" pull --ff-only --quiet 2>>"$LOG" || { warn "pull failed: $d"; return; }
      after=$(git -C "$d" rev-parse HEAD 2>/dev/null)
      if [[ "$before" != "$after" ]]; then
        echo "$d $before..$after $url" >>"$OUT/repo-updates.txt"
        # Red flag: any newly added agent config or hook after pull
        if git -C "$d" diff --name-only "$before" "$after" 2>/dev/null | grep -qE '(^|/)\.claude/|(^|/)\.github/workflows/|(^|/)hooks?\.(sh|ya?ml|json)$'; then
          echo "SUSPECT $d — new agent/workflow/hook in $before..$after" >>"$SUSPECT"
          warn "supply-chain flag: $d changed agent/workflow/hooks"
        fi
      fi
    }
    for root in "${ROOTS[@]}"; do
      [[ -d "$root" ]] || continue
      if [[ -d "$root/.git" ]]; then pull_one "$root"; continue; fi
      while IFS= read -r -d '' d; do pull_one "$d"; done \
        < <(find "$root" -mindepth 1 -maxdepth 2 -type d -name .git -printf '%h\0' 2>/dev/null)
    done
  fi
fi

# ============================================================
# PHASE 3 — AFTER snapshot + diff
# ============================================================
log "snapshot (after)"
snapshot "$AFTER"
diff -u "$BEFORE" "$AFTER" >"$DIFF" || true
ok "diff: $DIFF"

# ============================================================
# PHASE 4 — SECURITY AUDIT
# ============================================================
log "security audit"
: >"$AUDIT"
echo "# Security audit — $STAMP" >>"$AUDIT"

# pip-audit
if have pip-audit; then
  echo; echo "## pip-audit (user site)" >>"$AUDIT"
  pip-audit --progress-spinner off 2>/dev/null | tee -a "$AUDIT" >/dev/null || true
elif have pipx; then
  warn "pip-audit missing -> installing via pipx"
  pipx install pip-audit >>"$LOG" 2>&1 || true
fi

# govulncheck — scan every module in ~/go/bin that still has source
if have govulncheck; then
  echo; echo "## govulncheck (installed binaries)" >>"$AUDIT"
  for bin in "$HOME"/go/bin/*; do
    [[ -x "$bin" ]] || continue
    out=$(govulncheck -mode=binary "$bin" 2>/dev/null | grep -E 'Vulnerability|GO-[0-9]+-' || true)
    [[ -n "$out" ]] && { echo "### $(basename "$bin")"; echo '```'; echo "$out"; echo '```'; } >>"$AUDIT"
  done
else
  warn "govulncheck missing -> go install golang.org/x/vuln/cmd/govulncheck@latest"
fi

# cargo-audit
if have cargo-audit; then
  echo; echo "## cargo-audit" >>"$AUDIT"
  for mf in "$HOME"/*; do
    [[ -f "$mf/Cargo.lock" ]] && { echo "### $mf"; echo '```'; (cd "$mf" && cargo audit 2>&1 | tail -40); echo '```'; } >>"$AUDIT"
  done
fi

# npm audit (globals)
if have npm; then
  echo; echo "## npm audit (global)" >>"$AUDIT"
  npm_prefix=$(npm prefix -g 2>/dev/null)
  [[ -f "$npm_prefix/package.json" ]] && { echo '```'; (cd "$npm_prefix" && npm audit --production 2>&1 | tail -30); echo '```'; } >>"$AUDIT"
fi

# osv-scanner — universal
if have osv-scanner; then
  echo; echo "## osv-scanner (home lockfiles)" >>"$AUDIT"
  echo '```' >>"$AUDIT"
  osv-scanner --recursive "$HOME" 2>/dev/null | tail -80 >>"$AUDIT" || true
  echo '```' >>"$AUDIT"
else
  warn "osv-scanner missing -> https://github.com/google/osv-scanner/releases"
fi

# Supply-chain checks on cloned repos
echo; echo "## Supply-chain flags" >>"$AUDIT"
if [[ -s "$SUSPECT" ]]; then
  echo '```' >>"$AUDIT"; cat "$SUSPECT" >>"$AUDIT"; echo '```' >>"$AUDIT"
  err "$(wc -l <"$SUSPECT") suspect repo change(s) — review $SUSPECT"
else
  echo "- none observed in this run" >>"$AUDIT"
fi

# Secret sweep — quick sanity, no heavy scanners
echo; echo "## Secret sweep (fast regex, informational)" >>"$AUDIT"
if have rg; then
  echo '```' >>"$AUDIT"
  rg -n --no-heading --hidden -g '!**/.git/**' -g '!**/node_modules/**' \
     -e 'AKIA[0-9A-Z]{16}' \
     -e 'sk-[A-Za-z0-9]{32,}' \
     -e 'ghp_[A-Za-z0-9]{36}' \
     -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
     "$HOME/scripts" "$HOME/Tools" 2>/dev/null | head -20 >>"$AUDIT" || true
  echo '```' >>"$AUDIT"
fi

# Breach / CVE feed (stdlib only — no network tools required)
if have curl; then
  echo; echo "## CVE feed (CISA KEV, last 7d)" >>"$AUDIT"
  echo '```' >>"$AUDIT"
  curl -fsSL --max-time 10 https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json 2>/dev/null \
    | python3 -c "
import sys,json,datetime as d
try:
  k=json.load(sys.stdin)['vulnerabilities']
  cut=(d.datetime.utcnow()-d.timedelta(days=7)).date().isoformat()
  rows=[v for v in k if v.get('dateAdded','')>=cut]
  for v in rows[-15:]:
    print(f\"{v['dateAdded']}  {v['cveID']}  {v['vendorProject']}/{v['product']}  — {v['vulnerabilityName'][:80]}\")
  print(f\"total new KEV entries (7d): {len(rows)}\")
except Exception as e: print('feed error:', e)
" >>"$AUDIT" 2>&1 || echo "feed fetch failed" >>"$AUDIT"
  echo '```' >>"$AUDIT"
fi

# ============================================================
# PHASE 5 — LEADERBOARDS / ANALYST VIEW
# ============================================================
LEAD="$OUT/leaderboard.md"
{
  echo "# Leaderboard — $STAMP"
  echo
  echo "## Tool counts"
  echo "| bucket | count |"
  echo "|--------|------:|"
  echo "| go bins        | $(ls "$HOME/go/bin" 2>/dev/null | wc -l) |"
  echo "| pipx apps      | $(have pipx && pipx list --short 2>/dev/null | wc -l || echo 0) |"
  echo "| cargo crates   | $(grep -c '^"' "$HOME/.cargo/.crates.toml" 2>/dev/null || echo 0) |"
  echo "| npm globals    | $(have npm && npm ls -g --depth=0 --json 2>/dev/null | python3 -c 'import sys,json;print(len(json.load(sys.stdin).get(\"dependencies\",{})))' 2>/dev/null || echo 0) |"
  echo "| nuclei tmpl    | $(find "$HOME/nuclei-templates" -name '*.yaml' 2>/dev/null | wc -l) |"
  echo "| repos tracked  | $(cat "$OUT/repo-updates.txt" 2>/dev/null | wc -l) updated, $(find "$HOME"/Tools "$HOME"/recon "$HOME"/ext -maxdepth 3 -name .git 2>/dev/null | wc -l) total |"
  echo
  echo "## Local models (ollama)"
  if have ollama; then
    echo '```'
    ollama list 2>/dev/null | head -25
    echo '```'
  else echo "_ollama not installed_"
  fi
  echo
  echo "## Top 15 recently-updated go tools"
  ls -lt "$HOME/go/bin" 2>/dev/null | head -16 | awk 'NR>1{print "- "$NF" ("$6" "$7")"}'
  echo
  echo "## Updated repos this run"
  if [[ -s "$OUT/repo-updates.txt" ]]; then
    echo '```'; cat "$OUT/repo-updates.txt"; echo '```'
  else echo "_none_"
  fi
} >"$LEAD"

# ============================================================
# PHASE 6 — FINAL REPORT
# ============================================================
{
  echo "---"
  echo "title: \"Toolchain update — $TODAY\""
  echo "tags: [ops, security, tools, update-all, daily]"
  echo "created: $STAMP"
  echo "---"
  echo
  echo "# Toolchain update — $TODAY"
  echo
  echo "**Run:** \`$STAMP\`  · **Host:** \`$(hostname)\`  · **Mode:** $([[ $AUDIT_ONLY -eq 1 ]] && echo audit-only || echo full)"
  echo
  echo "## Summary"
  echo "- apt upgradable (before): $(grep apt_upgradable "$BEFORE" | tr -dc 0-9)"
  echo "- apt upgradable (after):  $(grep apt_upgradable "$AFTER"  | tr -dc 0-9)"
  echo "- repos updated:           $(wc -l <"$OUT/repo-updates.txt" 2>/dev/null || echo 0)"
  echo "- supply-chain flags:      $(wc -l <"$SUSPECT" 2>/dev/null || echo 0)"
  echo
  echo "## Diff (before -> after)"
  echo '```diff'
  sed -n '1,120p' "$DIFF"
  echo '```'
  echo
  cat "$LEAD"
  echo
  cat "$AUDIT"
  echo
  echo "---"
  echo "_Artifacts: \`$OUT\`_"
} >"$REPORT"

# symlink latest
ln -sfn "$OUT" "$LATEST"

# External sync (e.g. notes vault)
if [[ $SYNC -eq 1 && -n "$VAULT_DROP" && -d "$VAULT_DROP" ]]; then
  cp "$REPORT" "$VAULT_DROP/Toolchain update — $TODAY.md"
  ok "synced to: $VAULT_DROP/Toolchain update — $TODAY.md"
fi

ok "report: $REPORT"
ok "diff:   $DIFF"
ok "audit:  $AUDIT"
[[ -s "$SUSPECT" ]] && err "REVIEW: $SUSPECT"
log "done"
