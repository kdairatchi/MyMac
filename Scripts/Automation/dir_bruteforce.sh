#!/bin/bash

# dir_bruteforce.sh
# -----------------
# Bruteforce directories and files on live subdomains.

set -e

domain="$1"
# Adjust the path to your desired wordlist
wordlist="/Users/anom/SecLists/Discovery/Web-Content/dirsearch.txt"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

if [ ! -f "$wordlist" ]; then
    echo "[!] Wordlist not found at: $wordlist"
    exit 1
fi

echo "[*] Starting directory bruteforce for $domain..."

cd "recon/$domain" || exit
mkdir -p dirsearch_results

while read -r url; do
    echo "[*] Scanning $url..."
    # Using dirsearch from /opt/dirsearch:
    python3 /opt/dirsearch/dirsearch.py \
        -u "$url" \
        -w "$wordlist" \
        -e php,html,js,txt \
        -t 50 \
        --plain-text-report="dirsearch_results/$(echo "$url" | sed 's/[:\/]/_/g').txt" \
        --silent
done < live_subdomains.txt

echo "[*] Directory bruteforcing completed for $domain."
