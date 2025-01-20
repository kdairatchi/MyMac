#!/bin/bash

# probe.sh
# -------------
# Identify live HTTP services and capture screenshots.

set -e

domain="$1"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "[*] Probing for live HTTP servers on $domain..."

cd "recon/$domain" || exit

# Check for live subdomains (HTTP/HTTPS)
cat all_subdomains.txt | httprobe | sort -u > live_subdomains.txt

count_live=$(wc -l < live_subdomains.txt)
echo "[*] Found $count_live live subdomains."

# Screenshotting
echo "[*] Taking screenshots with Gowitness..."
gowitness file -s live_subdomains.txt -d screenshots --disable-logging

echo "[*] Screenshots saved in recon/$domain/screenshots."
