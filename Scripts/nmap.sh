#!/bin/bash
# Enhanced Nmap Recon Script
# Scans top 1000 ports + runs default scripts with full automation

set -euo pipefail

# Colors for output
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

# Randomized User-Agent for NSE
USER_AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
    "Mozilla/5.0 (X11; Linux x86_64)"
    "curl/7.68.0"
    "Wget/1.21.1"
)
UA=${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}

# Check args
if [ $# -lt 1 ]; then
    echo -e "${RED}Usage:${NC} $0 <target> [extra_nmap_args]"
    exit 1
fi

TARGET=$1
EXTRA_ARGS=${@:2}

# Timestamp + output dir
TS=$(date +"%Y%m%d_%H%M%S")
OUTDIR="recon_${TARGET}_${TS}"
mkdir -p "$OUTDIR"

echo -e "${BLUE}[*] Starting Nmap Recon on $TARGET${NC}"
echo -e "${YELLOW}[*] Output directory:${NC} $OUTDIR"

# Fast Top Ports Scan
echo -e "${GREEN}[*] Running Top 1000 TCP Ports Scan...${NC}"
nmap -T4 --top-ports 1000 -Pn -n -vv \
     -oA "$OUTDIR/top_ports" \
     "$TARGET" $EXTRA_ARGS || true

# Default Scripts + Service Detection
echo -e "${GREEN}[*] Running Default + Safe NSE Scripts...${NC}"
nmap -T4 --top-ports 1000 -Pn -n -sC -sV -vv \
     --script-args="http.useragent=$UA" \
     -oA "$OUTDIR/nse_default" \
     "$TARGET" $EXTRA_ARGS || true

# Grepable summary
echo -e "${GREEN}[*] Extracting open ports...${NC}"
grep -i "open" "$OUTDIR/top_ports.nmap" > "$OUTDIR/open_ports.txt" || true

# Final Summary
echo -e "\n${BLUE}=== Scan Complete ===${NC}"
echo -e "${YELLOW}Target:${NC} $TARGET"
echo -e "${YELLOW}Output:${NC} $OUTDIR"
echo -e "${YELLOW}Open Ports Saved:${NC} $OUTDIR/open_ports.txt"
echo -e "${YELLOW}Random User-Agent Used:${NC} $UA"
echo -e "${GREEN}Next Step:${NC} Run targeted scans per service (e.g. http, smb, ssh)..."
