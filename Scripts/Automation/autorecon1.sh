#!/bin/bash

# auto_recon.sh
# -------------
# A single script to run the entire reconnaissance workflow.

set -euo pipefail

# Check if domain is provided
domain="$1"

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Output file for storing results
output_file="recon_results_${domain}.txt"
echo "[*] Starting automated reconnaissance on $domain" > "$output_file"

# Ensure all scripts are executable
chmod +x subdomain_enum.sh \
         port_scan.sh \
         http_probe.sh \
         dir_bruteforce.sh \
         vuln_scan.sh \
         js_collection.sh \
         endpoint_discovery.sh \
         subdomain_takeover.sh

# --------------------------------------------------
# Step 1: Subdomain Enumeration
# --------------------------------------------------
echo "[*] Running subdomain enumeration..." >> "$output_file"
./subdomain_enum.sh "$domain" >> "$output_file"

# --------------------------------------------------
# Step 2: Port Scanning
# --------------------------------------------------
echo "[*] Running port scanning..." >> "$output_file"
./port_scan.sh "$domain" >> "$output_file"

# --------------------------------------------------
# Step 3: HTTP Probing and Screenshotting
# --------------------------------------------------
echo "[*] Running HTTP probing..." >> "$output_file"
./http_probe.sh "$domain" >> "$output_file"

# --------------------------------------------------
# Step 4: Directory and File Bruteforcing
# --------------------------------------------------
echo "[*] Running directory and file bruteforcing..." >> "$output_file"
./dir_bruteforce.sh "$domain" >> "$output_file"

# --------------------------------------------------
# Step 5: Vulnerability Scanning
# --------------------------------------------------
echo "[*] Running vulnerability scanning..." >> "$output_file"
./vuln_scan.sh "$domain" >> "$output_file"

# --------------------------------------------------
# Step 6: Collecting and Analyzing JavaScript Files
# --------------------------------------------------
echo "[*] Collecting and analyzing JavaScript files..." >> "$output_file"
./js_collection.sh "$domain" >> "$output_file"

# Analyze JavaScript files
if [ -d "recon/$domain/javascript_files" ]; then
    cd "recon/$domain/javascript_files" || exit
    python3 ../../../js_analyzer.py >> "$output_file"
    cd ../../../
else
    echo "[!] JavaScript files directory not found! Skipping analysis." >> "$output_file"
fi

# --------------------------------------------------
# Step 7: API and Endpoint Discovery
# --------------------------------------------------
echo "[*] Running API and endpoint discovery..." >> "$output_file"
./endpoint_discovery.sh "$domain" >> "$output_file"

# --------------------------------------------------
# Step 8: Subdomain Takeover Check
# --------------------------------------------------
echo "[*] Checking for subdomain takeovers..." >> "$output_file"
./subdomain_takeover.sh "$domain" >> "$output_file"

# --------------------------------------------------
# Additional Checks
# --------------------------------------------------
# Define an array of tools and their commands
declare -A tools=(
    [Vulners]="vulners -s"
    [GetJS]="GetJS -u"
    [GoLinkFinder]="GoLinkFinder -u"
    [GetAllURLs]="getallurls -u"
    [WayBackUrls]="waybackurls"
    [Waymore]="waymore -i recon/$domain/live_subdomains.txt -fc 200 -mode R"
    [WayBackRobots]="waybackrobots"
    [FFuF]="ffuf"
    [XSSHunter]="xsshunter"
    [SQLMap]="sqlmap"
    [XXEInjector]="xxeinjector"
    [SSRFDetector]="ssrfdetector"
    [GitTools]="gittools"
    [GitAllSecrets]="gitallsecrets"
    [RaceTheWeb]="racetheweb"
    [CORSTest]="cors-test"
    [EyeWitness]="eyewitness"
    [Parameth]="parameth"
)

for tool in "${!tools[@]}"; do
    echo "[*] Running $tool..." >> "$output_file"
    ${tools[$tool]} "$domain" >> "$output_file" 2>/dev/null || echo "[!] $tool failed or is not installed." >> "$output_file"
done

# Finalize the process
echo "[*] Automated reconnaissance completed for $domain" >> "$output_file"
echo "Results saved in $output_file"
