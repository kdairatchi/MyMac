#!/bin/bash

# js.sh
# ----------------
# Collect JavaScript files from live subdomains.

set -e

domain="$1"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "[*] Collecting JavaScript files for $domain..."

cd "recon/$domain" || exit
mkdir -p javascript_files

while read -r url; do
    getJS --url "$url" >> javascript_files/js_files.txt
done < live_subdomains.txt

# Remove duplicates
sort -u javascript_files/js_files.txt -o javascript_files/js_files.txt

echo "[*] Downloading JavaScript files..."
cd javascript_files || exit

wget -q -i js_files.txt || true

echo "[*] JavaScript files collected for $domain."
