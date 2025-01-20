#!/bin/bash

# subdomain_takeover.sh
# ---------------------
# Check subdomains for potential takeover.

set -e

domain="$1"
# Update with your local path to the subjack fingerprints
fingerprints="/Users/anom/tools/subjack/fingerprints.json"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

if [ ! -f "$fingerprints" ]; then
    echo "[!] Fingerprints file not found at: $fingerprints"
    exit 1
fi

echo "[*] Checking for subdomain takeover on $domain..."

cd "recon/$domain" || exit

subjack -w all_subdomains.txt \
        -t 100 \
        -timeout 30 \
        -ssl \
        -c "$fingerprints" \
        -v \
        -o subjack_results.txt

echo "[*] Subdomain takeover check completed for $domain."
