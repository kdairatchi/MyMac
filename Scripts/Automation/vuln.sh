#!/bin/bash

# vuln.sh
# ------------
# Scan live subdomains for known vulnerabilities using Nuclei.

set -e

domain="$1"
# Update with your local path to the Nuclei templates:
nuclei_templates="/Users/anom/nuclei-templates/Nuclei-Templates-Collection/categorized_templates/"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

if [ ! -d "$nuclei_templates" ]; then
    echo "[!] Nuclei templates not found at: $nuclei_templates"
    exit 1
fi

echo "[*] Starting vulnerability scanning for $domain..."

cd "recon/$domain" || exit

nuclei -l live_subdomains.txt -t "$nuclei_templates" -o nuclei_results.txt

echo "[*] Vulnerability scanning completed for $domain."
