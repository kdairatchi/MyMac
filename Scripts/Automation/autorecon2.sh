#!/bin/bash

# Colors for output
BOLD="\e[1m"; CYAN='\033[0;36m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

# ASCII Banner
echo -e "$CYAN${BOLD}Ultimate Bug Bounty Automation Script${NC}"
echo -e "${BOLD}By @xkdai${NC}\n"

# Check for required tools
REQUIRED_TOOLS=("subfinder" "assetfinder" "amass" "findomain" "naabu" "httpx" "nuclei" "gau" "hakrawler" "ffuf" "gospider" "unfurl" "puredns" "gotator" "cero" "Sublist3r")

for tool in "${REQUIRED_TOOLS[@]}"; do
    if [[ "$tool" == "Sublist3r" ]]; then
        if ! [[ -f "$HOME/tools/Scripts/Reconnaissance/Sublist3r" ]]; then
            echo -e "${RED}[-] Sublist3r is not installed at $HOME/tools/Scripts/Reconnaissance/Sublist3r! Exiting.${NC}"
            exit 1
        fi
    else
        command -v "$tool" &>/dev/null || { echo -e "${RED}[-] $tool is not installed! Exiting.${NC}"; exit 1; }
    fi
done

# Help Menu
if [[ "$1" == "--help" || -z "$1" ]]; then
    echo -e "${CYAN}${BOLD}Usage:${NC}"
    echo -e "${BOLD}  --full-recon [domain]     Full Automation Recon${NC}"
    echo -e "${BOLD}  --quick-recon [domain]    Quick Recon (No brute force)${NC}"
    echo -e "${BOLD}  --passive-recon [domain]  Passive Recon Only${NC}"
    echo -e "${BOLD}  --active-recon [domain]   Active Recon Only${NC}"
    echo -e "${BOLD}  --tools-check            Check installed tools${NC}"
    exit 0
fi

# Variables
DOMAIN="$2"
[[ -z "$DOMAIN" && "$1" != "--tools-check" ]] && { echo -e "${RED}Please provide a domain.${NC}"; exit 1; }
OUTPUT_DIR=~/bounty.sh/output/$DOMAIN; mkdir -p $OUTPUT_DIR

# Tool Validation Check
if [[ "$1" == "--tools-check" ]]; then
    echo -e "${CYAN}[+] Validating Tools...${NC}"
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "${GREEN}[+] $tool is installed.${NC}"
        else
            echo -e "${RED}[-] $tool is missing.${NC}"
        fi
    done
    exit 0
fi

# Subdomain Enumeration
sub_enum() {
    echo -e "${CYAN}[+] Subdomain Enumeration...${NC}"
    (subfinder -d $DOMAIN -silent | anew $OUTPUT_DIR/subs.txt; \
     assetfinder --subs-only $DOMAIN | anew $OUTPUT_DIR/subs.txt; \
     amass enum -passive -d $DOMAIN | anew $OUTPUT_DIR/subs.txt; \
     findomain --target $DOMAIN --quiet | anew $OUTPUT_DIR/subs.txt; \
     python3 $HOME/tools/Scripts/Reconnaissance/Sublist3r/sublist3r.py -d $DOMAIN -o $OUTPUT_DIR/subs_sublistr.txt) &>/dev/null
}

# Port Scanning
port_scan() {
    echo -e "${CYAN}[+] Port Scanning...${NC}"
    naabu -silent -l $OUTPUT_DIR/subs.txt -rate 3000 -o $OUTPUT_DIR/ports.txt &>/dev/null
}

# HTTP Probing
http_probe() {
    echo -e "${CYAN}[+] HTTP Probing...${NC}"
    httpx -silent -l $OUTPUT_DIR/ports.txt -threads 300 -o $OUTPUT_DIR/alive.txt &>/dev/null
}

# Vulnerability Scanning
vuln_scan() {
    echo -e "${CYAN}[+] Vulnerability Scanning...${NC}"
    nuclei -l $OUTPUT_DIR/alive.txt -t ~/nuclei-templates -es info,unknown -o $OUTPUT_DIR/nuclei.txt &>/dev/null
}

# Parameter Discovery
param_discovery() {
    echo -e "${CYAN}[+] Discovering Parameters...${NC}"
    gospider -S $OUTPUT_DIR/alive.txt --js -t 50 -d 2 --sitemap --robots -o $OUTPUT_DIR/params.txt &>/dev/null
}

# Directory Fuzzing
dir_fuzz() {
    echo -e "${CYAN}[+] Directory Fuzzing...${NC}"
    ffuf -c -w ~/wordlists/dir.txt -u "https://$DOMAIN/FUZZ" -mc 200 -o $OUTPUT_DIR/ffuf_results.txt &>/dev/null
}

# Passive Recon
passive_recon() {
    echo -e "${CYAN}[+] Passive Recon Started...${NC}"
    sub_enum && echo -e "${GREEN}[+] Passive Recon Completed.${NC}"
}

# Active Recon
active_recon() {
    echo -e "${CYAN}[+] Active Recon Started...${NC}"
    sub_enum && port_scan && http_probe && echo -e "${GREEN}[+] Active Recon Completed.${NC}"
}

# Quick Recon
quick_recon() {
    echo -e "${CYAN}[+] Quick Recon Started...${NC}"
    sub_enum && http_probe && vuln_scan && param_discovery && echo -e "${GREEN}[+] Quick Recon Completed.${NC}"
}

# Full Recon
full_recon() {
    echo -e "${CYAN}[+] Full Recon Started...${NC}"
    sub_enum && port_scan && http_probe && vuln_scan && param_discovery && dir_fuzz && echo -e "${GREEN}[+] Full Recon Completed.${NC}"
}

# Additional Feature: Organize Results
organize_results() {
    echo -e "${CYAN}[+] Organizing Results...${NC}"
    cat $OUTPUT_DIR/subs.txt | sort -u > $OUTPUT_DIR/subdomains_final.txt
    cat $OUTPUT_DIR/alive.txt | sort -u > $OUTPUT_DIR/alive_final.txt
    echo -e "${GREEN}[+] Results Organized Successfully.${NC}"
}

# Mode Selection
case $1 in
    --passive-recon) passive_recon ;;
    --active-recon) active_recon ;;
    --quick-recon) quick_recon ;;
    --full-recon) full_recon ;;
    *) echo -e "${RED}[-] Invalid Option. Use --help.${NC}" ;;
esac

# Final Organization
organize_results
echo -e "${GREEN}[+] Script Completed Successfully.${NC}"
