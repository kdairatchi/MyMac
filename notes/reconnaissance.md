# Reconnaissance Guide

A comprehensive collection of reconnaissance techniques, tools, and one-liners for bug bounty hunting and penetration testing.

## Table of Contents
1. [Subdomain Enumeration](#subdomain-enumeration)
2. [Port Scanning](#port-scanning)
3. [DNS Reconnaissance](#dns-reconnaissance)
4. [Shodan/SQRY Queries](#shodansqry-queries)
5. [Asset Discovery](#asset-discovery)
6. [Live Host Detection](#live-host-detection)
7. [Technology Detection](#technology-detection)
8. [Network Analysis](#network-analysis)
9. [Advanced Techniques](#advanced-techniques)

---

## Subdomain Enumeration

### Passive Subdomain Discovery

#### Subfinder
Fast and effective passive subdomain discovery tool.
```bash
# Basic subdomain enumeration
subfinder -d <domain> -o subdomains.txt

# Silent mode with all sources
subfinder -d <domain> -silent -all -o subdomains.txt

# Recursive enumeration
subfinder -d <domain> -all -recursive -o subdomains.txt

# Example with specific domain
subfinder -d vulnweb.com -all -recursive -o vulnweb.com.subfinder.txt
```

#### Assetfinder
Find domains and subdomains related to a given domain.
```bash
# Basic usage
assetfinder <domain>

# Subdomains only
assetfinder --subs-only <domain>

# Example with output
assetfinder -subs-only vulnweb.com | tee vulnweb.com.assetfinder.txt
```

#### Amass
Advanced subdomain enumeration and OSINT tool.
```bash
# Passive enumeration
amass enum -passive -d <domain> -o subdomains.txt

# Brute force subdomains
amass enum -d <domain> -brute -o subdomains.txt

# DNS information visualization
amass viz -i <subdomains_file> -o graph.png

# Example
amass enum -passive -d "vulnweb.com" -o vulnweb.com.amass.txt
```

#### Sublist3r
```bash
sublist3r -d "vulnweb.com" -t 20 -v -o vulnweb.com.sublist3r.txt
```

### Active Subdomain Discovery

#### FFUF (Host Header Fuzzing)
```bash
# Basic host header fuzzing
ffuf -u "http://<domain>" -H "Host: FUZZ.<domain>" -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -c

# With HTML output
ffuf -u "http://vulnweb.com" -H "Host: FUZZ.vulnweb.com" -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -c -of html -o vulnweb.com.ffuf.html

# Custom wordlist bruteforcing
ffuf -u https://FUZZ.HOST -w FILE.txt -v | grep "| URL |" | awk '{print $4}'
```

#### Dnsx
```bash
dnsx -d "vulnweb.com" -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -o vulnweb.com.dnsx.txt
```

#### Knockpy
```bash
knockpy -d "vulnweb.com" --recon --save vulnweb.com
```

### API-Based Subdomain Discovery

#### RapidDNS.io
```bash
export host="HOST" ; curl -s "https://rapiddns.io/subdomain/$host?full=1#result" | grep -e "<td>.*$host</td>" | grep -oP '(?<=<td>)[^<]+' | sort -u
```

#### BufferOver.run
```bash
curl -s https://dns.bufferover.run/dns?q=.HOST.com | jq -r .FDNS_A[] | cut -d',' -f2 | sort -u

# Alternative method
export domain="HOST"; curl "https://tls.bufferover.run/dns?q=$domain" | jq -r .Results'[]' | rev | cut -d ',' -f1 | rev | sort -u | grep "\.$domain"
```

#### VirusTotal
```bash
curl -s "https://www.virustotal.com/ui/domains/HOST/subdomains?limit=40" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u
```

#### CertSpotter
```bash
curl -s "https://certspotter.com/api/v1/issuances?domain=HOST&include_subdomains=true&expand=dns_names" | jq .[].dns_names | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u
```

#### crt.sh
```bash
curl -s "https://crt.sh/?q=%25.HOST&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u
```

#### JLDC
```bash
curl -s "https://jldc.me/anubis/subdomains/HOST" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u
```

#### Sonar.omnisint.io
```bash
curl --silent https://sonar.omnisint.io/subdomains/HOST | grep -oE "[a-zA-Z0-9._-]+\.HOST" | sort -u
```

#### Archive.org
```bash
curl -s "http://web.archive.org/cdx/search/cdx?url=*.HOST/*&output=text&fl=original&collapse=urlkey" | sed -e 's_https*://__' -e "s/\/.*//" | sort -u
```

### Subdomain Takeover Detection

#### Multiple Tools Chain
```bash
subfinder -d HOST >> FILE; assetfinder --subs-only HOST >> FILE; amass enum -norecursive -noalts -d HOST >> FILE; subjack -w FILE -t 100 -timeout 30 -ssl -c $GOPATH/src/github.com/haccer/subjack/fingerprints.json -v 3 >> takeover
```

#### Subzy
```bash
subzy run --targets subdomains.txt --concurrency 100 --hide_fails --verify_ssl
```

#### Nuclei for Subdomain Takeover
```bash
subfinder -d $domain | httpx -silent > subdomains.txt
nuclei -t /root/nuclei-templates/http/takeovers -l subdomains.txt
```

---

## Port Scanning

### Nmap
Essential tool for detailed port scanning and service enumeration.

#### Basic Scans
```bash
# Basic service version scan
nmap -sV <target_ip>

# Aggressive scan with OS detection
nmap -A <target_ip>

# Ping scan for live hosts
nmap -sP <target_range>

# Full port scan with service detection
nmap -p- --min-rate 1000 -T4 -A target.com -oA fullscan

# Vulnerability scanning
nmap --script=http-enum,vuln/scanners/http-title-fingerprinting 192.168.1.*

# SSL certificate information
nmap --script ssl-cert -p 443 <IP Address>
```

#### Nmap with Httpx Integration
```bash
nmap -v0 HOST -oX /dev/stdout | jc --xml -p | jq -r '.nmaprun.host | (.address["@addr"] + ":" + .ports.port[]["@portid"])' | httpx --silent
```

### Masscan
TCP port scanner for high-speed scanning.
```bash
# Basic masscan usage
masscan -p0-65535 target.com --rate 100000 -oG masscan-results.txt

# Scan specific ports at high speed
masscan -p80,443,8080,8443 target.com --rate 10000
```

### Naabu
Fast port scanner written in Go.
```bash
# Basic port scan
naabu -host target.com

# Scan from file with nmap integration
naabu -list ip.txt -c 50 -nmap-cli 'nmap -sV -SC' -o naabu-full.txt

# High-speed scan with CloudFlare bypass
subfinder -silent -d HOST | filter-resolved | cf-check | sort -u | naabu -rate 40000 -silent -verify | httprobe
```

---

## DNS Reconnaissance

### Basic DNS Queries with dig

#### A Records (IP Addresses)
```bash
# Basic A record lookup
dig <domain> A +short

# Example
dig google.com A +short
```

#### Reverse DNS Lookups
```bash
# Reverse DNS lookup
dig -x <ip_address> +short

# Example
dig -x 8.8.8.8 +short
```

#### MX Records (Mail Servers)
```bash
# Mail exchange records
dig <domain> MX +short

# Example
dig google.com MX +short
```

#### Advanced DNS Queries
```bash
# All DNS records
dig <domain> ANY

# Name servers
dig <domain> NS +short

# TXT records
dig <domain> TXT +short

# CNAME records
dig <domain> CNAME +short
```

### DNS Over HTTPS Bruteforcing
```bash
while read sub; do echo "https://dns.google.com/resolve?name=$sub.HOST&type=A&cd=true" | parallel -j100 -q curl -s -L --silent  | grep -Po '[{\[]{1}([,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]|".*?")+[}\]]{1}' | jq | grep "name" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep ".HOST" | sort -u ; done < FILE.txt
```

---

## Shodan/SQRY Queries

SQRY is a command-line tool for Shodan queries. Here are powerful queries for reconnaissance:

### Basic Service Discovery

#### Web Services
```bash
# HTTP services (port 80)
sqry -q "port:80" --json --limit 50

# HTTPS services (port 443)
sqry -q "port:443" --json --limit 50

# Non-standard web ports
sqry -q "port:8080" --json --limit 50
```

#### Database Services
```bash
# MySQL databases
sqry -q "port:3306" --json --limit 50

# MongoDB instances
sqry -q "port:27017" --json --limit 50

# Redis instances
sqry -q "port:6379" --json --limit 50

# Elasticsearch
sqry -q "port:9200" --json --limit 50
```

#### Remote Access Services
```bash
# SSH services
sqry -q "port:22" --json --limit 50

# FTP servers
sqry -q "port:21" --json --limit 50

# RDP services
sqry -q "port:3389" --json --limit 50

# VNC services
sqry -q "port:5900" --json --limit 50

# Telnet services
sqry -q "port:23" --json --limit 50
```

### Application-Specific Queries

#### Development Tools
```bash
# Jenkins instances
sqry -q "Jenkins" --json --limit 50

# PhpMyAdmin
sqry -q "phpmyadmin" --json --limit 50

# WordPress sites
sqry -q "product:WordPress" --json --limit 10
sqry -q "wp-admin" --json --limit 50
```

#### Infrastructure
```bash
# Apache servers
sqry -q "apache" --country US --json --limit 10
sqry -q "product:Apache" --json --limit 50

# Nginx servers
sqry -q "nginx" --json --country US --limit 5

# Kubernetes API
sqry -q "port:6443" --json --limit 50
```

### Advanced Shodan Queries

#### CVE and Vulnerability Searching
```bash
# Specific CVE lookup
sqry --cve CVE-2016-10087 --cve-json --pretty

# High CVSS score vulnerabilities
sqry --min-cvss 9.0 --max-cvss 10.0 --json

# Critical severity vulnerabilities
sqry --severity critical --json --limit 10

# Known Exploited Vulnerabilities
sqry --kev --json --limit 10

# MySQL with high CVSS
sqry -q "product:mysql" --min-cvss 7 --json
```

#### Geographic and Network Filtering
```bash
# Country-specific results
sqry -q "http" --country US --limit 10

# ASN-specific queries
sqry -q "ssl:true" --asn 12345 --json --limit 10

# Geographic location
sqry -q "http" --geo --country US --limit 10
```

#### SSL and Certificate Analysis
```bash
# SSL-enabled hosts
sqry -q "ssl:true" --domains --with-domains

# SSL certificate domain search
shodan search Ssl.cert.subject.CN:"<DOMAIN>" 200 --fields ip_str | httpx-toolkit -sc -title -server -td
```

### Specialized Reconnaissance Queries

#### Subdomain Takeover Targets
```bash
# CNAME records for takeover
sqry -q "CNAME" --json --limit 50
```

#### S3 Buckets and Storage
```bash
# S3 bucket discovery
sqry -q "bucket" --json --limit 10
```

#### Webcams and IoT
```bash
# IP cameras on port 554
sqry -q "port:554" --json --limit 50

# Webcams on port 80
sqry -q "port:80" "webcam" --json --limit 50
```

#### Domain and IP Analysis
```bash
# Specific IP analysis
sqry -q "ip:<target_ip>" --ports --json

# Domains with HTTP
sqry -q "http" --has-domain --json

# Screenshots of web services
sqry -q "http" --httpx --screenshot --limit 20
```

---

## Asset Discovery

### URL Discovery

#### GAU (Get All URLs)
```bash
# Basic GAU usage
gau <domain>

# With threading
gau <domain> --threads 5

# Filter out static files
gau <domain> | egrep -v '(.css|.png|.jpeg|.jpg|.svg|.gif|.wolf)'

# Piping to other tools
echo "test.vulnweb.com" | gau -t 50 | uro | gf sqli > sql.txt
```

#### Waybackurls
```bash
# Fetch URLs from Wayback Machine
waybackurls <domain>

# Chain with other tools
waybackurls <domain> | gf xss | sed 's/=.*/=/' | sort -u
```

#### Katana (Web Crawler)
```bash
# Basic crawling
katana -u <url>

# Passive crawling with multiple sources
echo "testphp.vulnweb.com" | katana -passive -pss waybackarchive,commoncrawl,alienvault -f qurl

# JavaScript file discovery
echo ferrari.com | katana -d 5 | grep -E '\.js$' | nuclei -t /Users/anom/tools/Scripts/community-templates -c 30
```

### Asset Enumeration from APIs

#### AlienVault OTX
```bash
# Extract IPs from OTX
curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/<DOMAIN>/url_list?limit=500&page=1" | jq -r '.url_list[]?.result?.urlworker?.ip // empty' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'
```

#### Bug Bounty Program Assets
```bash
# Chaos bug bounty list
curl -sL https://github.com/projectdiscovery/public-bugbounty-programs/raw/master/chaos-bugbounty-list.json | jq -r '.programs[].domains | to_entries | .[].value'

# HackerOne programs
curl -sL https://github.com/arkadiyt/bounty-targets-data/blob/master/data/hackerone_data.json?raw=true | jq -r '.[].targets.in_scope[] | [.asset_identifier, .asset_type] | @tsv'

# BugCrowd programs
curl -sL https://github.com/arkadiyt/bounty-targets-data/raw/master/data/bugcrowd_data.json | jq -r '.[].targets.in_scope[] | [.target, .type] | @tsv'
```

### JavaScript Analysis

#### Endpoint Extraction
```bash
# Extract endpoints from JavaScript
cat FILE.js | grep -oh "\"\/[a-zA-Z0-9_/?=&]*\"" | sed -e 's/^"//' -e 's/"$//' | sort -u

# LinkFinder alternative
curl -s $1 | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort | uniq | grep ".js" > FILE.txt; while IFS= read link; do python linkfinder.py -i "$link" -o cli; done < FILE.txt | grep $2 | grep -v $3 | sort -n | uniq; rm -rf FILE.txt
```

### Sitemap Extraction
```bash
curl -s http://HOST/sitemap.xml | xmllint --format - | grep -e 'loc' | sed -r 's|</?loc>||g'
```

---

## Live Host Detection

### Httpx
Fast HTTP toolkit for probing live hosts.

#### Basic Usage
```bash
# Probe live hosts
httpx -l subdomains.txt

# With status codes and titles
httpx -l subdomains.txt -sc -title

# Follow redirects and filter 200 status
subfinder -d HOST -silent | httpx -silent -follow-redirects -mc 200 | cut -d '/' -f3 | sort -u

# Technology detection
cat nba_subs.txt | httpx-toolkit -title -sc -tech -threads 200 | tee live_nba_subs2.txt | grep -I "200" > live_nba_subs.txt
```

#### Advanced Httpx Usage
```bash
# With custom headers and paths
echo 'https://example.com/index.php?page=' | httpx-toolkit -paths payloads/lfi.txt -threads 50 -random-agent -mc 200 -mr 'root:(x|\*|\$[^\:]*):0:0:'

# Pipeline with other tools
subfinder -d HOST | httpx | nuclei -tags exposure -o output.txt
```

### Httprobe
```bash
# Basic probing
httprobe < subdomains.txt

# Chain with other tools
cat domains.txt | assetfinder --subs-only | httprobe
```

### Parallel Probing
```bash
# Using GNU parallel with curl
cat HOSTS.txt | parallel -j50 -q curl -w 'Status:%{http_code}\t  Size:%{size_download}\t %{url_effective}\n' -o /dev/null -sk
```

---

## Technology Detection

### HTTP Header Analysis

#### Content Security Policy
```bash
curl -vs URL --stderr - | awk '/^content-security-policy:/' | grep -Eo "[a-zA-Z0-9./?=_-]*" |  sed -e '/\./!d' -e '/[^A-Za-z0-9._-]/d' -e 's/^\.//' | sort -u
```

### Web Technology Fingerprinting

#### Nuclei for Technology Detection
```bash
# Basic technology detection templates
nuclei -u <target> -t nuclei-templates/http/technologies/

# Exposure detection
nuclei -l urls.txt -t nuclei-templates/http/exposures/
```

### Screenshot Capture

#### Gowitness
```bash
# Single target screenshot
gowitness single -u http://<target_domain> -s screenshot.png

# Batch screenshot capture
gowitness file -f urls.txt --threads 10

# With status updates
gowitness capture -u http://<target_domain> --status
```

---

## Network Analysis

### IP and Network Information

#### WHOIS Analysis
```bash
# CIDR and organization information
for HOST in $(cat HOSTS.txt);do echo $(for ip in $(dig a $HOST +short); do whois $ip | grep -e "CIDR\|Organization" | tr -s " " | paste - -; done | uniq); done
```

#### ASN Lookup
```bash
# Find allocated IP ranges for ASN
whois -h whois.radb.net -i origin -T route $(whois -h whois.radb.net IP | grep origin: | awk '{print $NF}' | head -1) | grep -w "route:" | awk '{print $NF}' | sort -n
```

#### IP Extraction
```bash
# Extract IPs from files
grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' file.txt
```

### CloudFlare Detection and Bypass

#### CloudFlare Check
```bash
subfinder -silent -d HOST | filter-resolved | cf-check | sort -u | naabu -rate 40000 -silent -verify | httprobe
```

---

## Advanced Techniques

### LazyHunter Integration
LazyHunter (hunter.py) for CVE analysis and port enumeration.

#### Basic Usage
```bash
# CVE and port analysis
hunter.py --cve+ports --target <target_ip> --json-output results.json

# Multiple targets
hunter.py --cve+ports --target targets.txt --json-output bulk_scan.json

# Quick hostname and port scan
hunter.py --host --ports --target <target_ip> --json-output quick_scan.json

# Example with threading and timeout
hunter.py --cve+ports --target <target_ip> --threads 20 --timeout 60
```

### Custom Wordlist Creation

#### URL-based Wordlists
```bash
# Extract keys and paths from URLs
gau HOST | unfurl -u keys | tee -a FILE1.txt; gau HOST | unfurl -u paths | tee -a FILE2.txt; sed 's#/#\n#g' FILE2.txt | sort -u | tee -a FILE1.txt | sort -u; rm FILE2.txt  | sed -i -e 's/\.css\|\.png\|\.jpeg\|\.jpg\|\.svg\|\.gif\|\.wolf\|\.bmp//g' FILE1.txt

# Token-based wordlists
cat HOSTS.txt | httprobe | xargs curl | tok | tr '[:upper:]' '[:lower:]' | sort -u | tee -a FILE.txt
```

### Automation Chains

#### Complete Recon Pipeline
```bash
# Step 1: Subdomain discovery
subfinder -d example.com -all -silent | gau -t 50 | uro | gf sqli > sql.txt

# Step 2: Live host detection with technology detection
cat subdomains.txt | httpx -silent -threads 300 | anew -q live.txt

# Step 3: Port scanning
naabu -list live.txt -c 50 -nmap-cli 'nmap -sV -SC' -o ports.txt

# Step 4: Vulnerability scanning
nuclei -l live.txt -t nuclei-templates/ -o vulnerabilities.txt
```

#### One-liner Recon Chains
```bash
# Comprehensive XSS discovery
subfinder -d example.com | gau | gf xss | uro | Gxss | kxss | tee xss_output.txt

# SQL injection discovery
echo "test.vulnweb.com" | gau -t 50 | uro | gf sqli > sql.txt; ghauri -m sql.txt --batch --dbs --level 3 --confirm

# LFI discovery with FFUF
waymore -i "" -n -mode U | gf lfi | sed 's/=.*/=/' | qsreplace "FUZZ" | sort -u | while read urls; do ffuf -u $urls -w payloads/lfi.txt -c -mr "root:" -v; done
```

### CORS Misconfiguration Testing
```bash
python3 corsy.py -i subdomains_alive.txt -t 10 --headers 'User-Agent: GoogleBot\nCookie: SESSION=Hacked'

# Alternative one-liner
site="URL"; gau "$site" | while read url; do target=$(curl -sIH "Origin: https://evil.com" -X GET $url) | if grep 'https://evil.com'; then [Potentional CORS Found] echo $url; else echo Nothing on "$url"; fi; done
```

### Hidden Servers and Admin Panel Discovery
```bash
ffuf -c -u URL -H "Host: FUZZ" -w FILE.txt
```

---

## Tool Installation and Setup

### Essential Tools List
```
airixss           gospider          puredns
amass             gotator           qsreplace
anew              gron              shuffledns
asnmap            Gxss              simplehttpserver
assetfinder       hakrawler         sqry
cariddi           httprobe          subfinder
chaos             httpx             subjack
comb              interactsh-client subjs
crlfuzz           katana            tlsx
dalfox            kxss              uncover
dnsx              mapcidr           unfurl
ffuf              nuclei            waybackurls
gau               naabu             
```

### Quick Installation
```bash
# Install sqry
go install github.com/kdairatchi/sqry@latest

# Verify installation
sqry -q "apache" > apache_ips.txt
```

---

## Tips and Best Practices

1. **Always combine multiple tools** - Different tools may discover different subdomains or services
2. **Use threading wisely** - Balance speed with accuracy and avoid overwhelming targets
3. **Filter results** - Remove false positives and irrelevant results early in the pipeline
4. **Document findings** - Keep organized notes of discovered assets and vulnerabilities
5. **Respect rate limits** - Many APIs have rate limits; use appropriate delays
6. **Validate results** - Always verify findings before reporting
7. **Stay updated** - Keep tools updated for best results and latest features

---

*This guide is for educational and authorized testing purposes only. Always obtain proper authorization before testing any systems you don't own.*