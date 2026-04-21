#!/bin/bash
# Sync BugBounty/ from MyMac workspace → Obsidian vault
# Run: bash /home/anon/MyMac/BugBounty/scripts/obsidian-sync.sh

set -euo pipefail

WORKSPACE="/home/anon/MyMac/BugBounty"
VAULT="/mnt/c/Users/Dr34d/OneDrive/Documents/Obsidian Vault"
TARGET_DIR="$VAULT/06 - Knowledge Base/BugBounty"

# Check vault is accessible
if [[ ! -d "$VAULT" ]]; then
  echo "[ERROR] Vault not accessible at: $VAULT"
  echo "Check: is OneDrive mounted? Try: ls $VAULT"
  exit 1
fi

echo "[INFO] Syncing $WORKSPACE → $TARGET_DIR"

# Create destination structure
mkdir -p "$TARGET_DIR"/{00-recon,01-vuln,02-bypass,03-tech,04-misc,05-chains,06-checklists,scripts}

# rsync with delete (destination mirrors source)
rsync -av --delete \
  --exclude="scripts/*.sh" \
  --exclude=".git" \
  "$WORKSPACE/" "$TARGET_DIR/"

# Copy scripts separately (make them readable but not executable in vault)
rsync -av --delete \
  "$WORKSPACE/scripts/" "$TARGET_DIR/scripts/"

echo "[OK] Sync complete: $TARGET_DIR"
echo "[INFO] Files synced:"
find "$TARGET_DIR" -name "*.md" | wc -l
echo " markdown files"

# Also sync cheatsheets if they exist
CHEATSHEETS_SRC="/home/anon/MyMac/Cheatsheets"
CHEATSHEETS_DST="$VAULT/06 - Knowledge Base/Cheatsheets"
if [[ -d "$CHEATSHEETS_SRC" ]]; then
  mkdir -p "$CHEATSHEETS_DST"
  rsync -av --delete --exclude=".git" "$CHEATSHEETS_SRC/" "$CHEATSHEETS_DST/"
  echo "[OK] Cheatsheets synced"
fi

# Sync Latest-2026 notes
LATEST_SRC="/home/anon/MyMac/Latest-2026"
LATEST_DST="$VAULT/01 - Inbox/Latest-2026"
if [[ -d "$LATEST_SRC" ]]; then
  mkdir -p "$LATEST_DST"
  rsync -av --delete --exclude=".git" "$LATEST_SRC/" "$LATEST_DST/"
  echo "[OK] Latest-2026 synced"
fi

echo ""
echo "[DONE] All synced. Open Obsidian and navigate to:"
echo "  06 - Knowledge Base/BugBounty/INDEX"
