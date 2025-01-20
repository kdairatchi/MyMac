#!/bin/bash

# port_scan.sh
# ------------
# Scan subdomains for common web ports.

set -e

domain="$1"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "[*] Starting port scan for $domain..."

cd "recon/$domain" || exit

# Scan common web ports
nmap -iL all_subdomains.txt -p 80,443,8080,8443 -T4 -oA nmap_scan

echo "[*] Port scanning completed for $domain."
