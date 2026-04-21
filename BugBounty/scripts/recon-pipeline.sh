#!/bin/bash
# Quick recon pipeline — runs against a single domain
# Usage: bash recon-pipeline.sh target.com
# Output: ./recon-TARGET/ directory

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <domain>"
  echo "Example: $0 target.com"
  exit 1
fi

TARGET="$1"
OUTDIR="./recon-${TARGET}"
mkdir -p "$OUTDIR"/{subdomains,urls,screenshots,nuclei}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Recon: $TARGET"
echo " Output: $OUTDIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Subdomain enumeration
echo "[1/6] Subdomain enum..."
subfinder -d "$TARGET" -silent 2>/dev/null > "$OUTDIR/subdomains/subfinder.txt" || true
assetfinder --subs-only "$TARGET" 2>/dev/null >> "$OUTDIR/subdomains/subfinder.txt" || true
# certificate transparency
curl -s "https://crt.sh/?q=%25.$TARGET&output=json" 2>/dev/null | \
  jq -r '.[].name_value' 2>/dev/null | \
  sed 's/\*\.//g' >> "$OUTDIR/subdomains/subfinder.txt" || true
sort -u "$OUTDIR/subdomains/subfinder.txt" > "$OUTDIR/subdomains/all_subs.txt"
COUNT=$(wc -l < "$OUTDIR/subdomains/all_subs.txt")
echo "   Found: $COUNT subdomains"

# 2. DNS resolution
echo "[2/6] DNS resolution..."
cat "$OUTDIR/subdomains/all_subs.txt" | \
  dnsx -silent -a -resp 2>/dev/null > "$OUTDIR/subdomains/resolved.txt" || true
echo "   Resolved: $(wc -l < "$OUTDIR/subdomains/resolved.txt") hosts"

# 3. HTTP probing
echo "[3/6] HTTP probing..."
cat "$OUTDIR/subdomains/all_subs.txt" | \
  httpx -silent -mc 200,301,302,403,500 -title -status-code -tech-detect \
  -o "$OUTDIR/subdomains/live_web.txt" 2>/dev/null || true
echo "   Live: $(wc -l < "$OUTDIR/subdomains/live_web.txt") web targets"

# Extract just URLs for next steps
awk '{print $1}' "$OUTDIR/subdomains/live_web.txt" > "$OUTDIR/subdomains/live_urls.txt"

# 4. URL collection
echo "[4/6] URL collection (gau + wayback)..."
echo "$TARGET" | gau --subs 2>/dev/null > "$OUTDIR/urls/gau.txt" || true
cat "$OUTDIR/subdomains/live_urls.txt" | \
  katana -jc -d 3 -silent 2>/dev/null >> "$OUTDIR/urls/gau.txt" || true
sort -u "$OUTDIR/urls/gau.txt" > "$OUTDIR/urls/all_urls.txt"

# Extract interesting params
grep "=" "$OUTDIR/urls/all_urls.txt" | \
  grep -v ".js\|.css\|.png\|.jpg\|.gif\|.svg\|.ico" > "$OUTDIR/urls/params.txt" || true
echo "   URLs: $(wc -l < "$OUTDIR/urls/all_urls.txt") total, $(wc -l < "$OUTDIR/urls/params.txt") with params"

# 5. Quick win checks
echo "[5/6] Quick win checks..."

# Exposed files
cat "$OUTDIR/subdomains/live_urls.txt" | \
  httpx -path "/.git/HEAD" -mc 200 -silent 2>/dev/null > "$OUTDIR/nuclei/exposed_git.txt" || true
cat "$OUTDIR/subdomains/live_urls.txt" | \
  httpx -path "/.env" -mc 200 -silent 2>/dev/null > "$OUTDIR/nuclei/exposed_env.txt" || true

# Open redirects
grep -E "(next|redirect|url|return|redir|goto|dest)=" "$OUTDIR/urls/params.txt" 2>/dev/null | \
  qsreplace "https://evil.com" 2>/dev/null | \
  httpx -mc 301,302,307,308 -location -silent 2>/dev/null > "$OUTDIR/nuclei/open_redirects.txt" || true

# 6. Nuclei scan
echo "[6/6] Nuclei scan (cves + exposures + misconfigs)..."
nuclei -list "$OUTDIR/subdomains/live_urls.txt" \
  -t cves/ -t exposures/ -t misconfigs/ \
  -severity medium,high,critical \
  -silent \
  -o "$OUTDIR/nuclei/findings.txt" 2>/dev/null || true
echo "   Nuclei findings: $(wc -l < "$OUTDIR/nuclei/findings.txt" 2>/dev/null || echo 0)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " DONE: $OUTDIR"
echo ""
echo " Key files:"
echo "   Subdomains:  $OUTDIR/subdomains/all_subs.txt"
echo "   Live web:    $OUTDIR/subdomains/live_web.txt"
echo "   Params:      $OUTDIR/urls/params.txt"
echo "   Nuclei hits: $OUTDIR/nuclei/findings.txt"
echo ""
echo " Next steps:"
echo "   1. Review live_web.txt for admin/staging/internal subdomains"
echo "   2. Feed params.txt to dalfox for XSS"
echo "   3. Feed params.txt to sqlmap for SQLi"
echo "   4. Look for SSRF params: url= fetch= src= dest="
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
