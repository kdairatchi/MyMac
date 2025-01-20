#!/bin/bash

# subdomain_enum.sh
# -----------------
# Discover all subdomains of a given domain.

set -e

domain="$1"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "[*] Enumerating subdomains for: $domain"

# Create output directory
mkdir -p "recon/$domain"
cd "recon/$domain" || exit

# Sublist3r
echo "[*] Running Sublist3r..."
python3 /Users/anom/tools/Sublist3r/sublist3r.py -d "$domain" -o sublist3r.txt || true

# Sublist3r
echo "[*] Running Spyhunt..."
python3 /Users/anom/tools/spyhunt/spyhunt.py -s "$domain" --save spyhunt.txt || true


# Assetfinder
echo "[*] Running Assetfinder..."
assetfinder --subs-only "$domain" > assetfinder.txt || true

# Amass
echo "[*] Running Amass (passive)..."
amass enum -passive -d "$domain" -o amass.txt || true

# Subfinder
echo "[*] Running Subfinder..."
subfinder -d "$domain" -o subfinder.txt || true

# Combine results
echo "[*] Combining and sorting subdomains..."
cat spyhunt.txt sublist3r.txt assetfinder.txt amass.txt subfinder.txt 2>/dev/null | sort -u > all_subdomains.txt

count_subs=$(wc -l < all_subdomains.txt)
echo "[*] Found $count_subs unique subdomains for $domain."
