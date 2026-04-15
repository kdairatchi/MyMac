#!/usr/bin/env bash
# MyMac cross-repo search wrapper.
# Usage: search.sh <pattern> [dir...]
# Searches Cheatsheets/, Checklists/, Methodology/, Recon/, Cheatsheets/, Notes/, RedTeam/, Web3/, Payloads/, Templates/ by default.

set -euo pipefail

PATTERN="${1:-}"
if [[ -z "$PATTERN" ]]; then
  echo "usage: $(basename "$0") <pattern> [dir...]" >&2
  exit 1
fi
shift || true

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULTS=(Cheatsheets Checklists Methodology Recon Notes RedTeam Web3 Payloads Templates AI Dorks Infosec OWASP)
DIRS=("$@")
[[ ${#DIRS[@]} -eq 0 ]] && DIRS=("${DEFAULTS[@]}")

cd "$ROOT"

if command -v rg >/dev/null 2>&1; then
  rg --color=always --line-number --heading --smart-case -- "$PATTERN" "${DIRS[@]}"
else
  grep -rn --color=always -I --exclude-dir=.git -- "$PATTERN" "${DIRS[@]}"
fi
