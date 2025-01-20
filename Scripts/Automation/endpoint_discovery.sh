#!/bin/bash

# endpoint_discovery.sh
# ----------------------
# Discover hidden APIs and endpoints from historical data.

set -e

domain="$1"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "[*] Collecting endpoints for $domain..."

cd "recon/$domain" || exit

cat all_subdomains.txt | waybackurls > waybackurls.txt
cat all_subdomains.txt | gau >> waybackurls.txt

# Remove duplicates
sort -u waybackurls.txt -o waybackurls.txt

echo "[*] Extracting parameters into params.txt..."
cat waybackurls.txt | grep "=" | qsreplace -a > params.txt

echo "[*] Endpoint discovery completed for $domain."
