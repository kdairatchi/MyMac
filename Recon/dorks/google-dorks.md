# Google Dorks

## Core Operators

```
site:example.com                    # limit to domain
filetype:pdf / ext:pdf              # file type filter
inurl:admin                        # text in URL
intitle:"admin panel"              # text in page title
intext:"password"                  # text in page body
cache:example.com                  # cached version
related:example.com                # related sites
info:example.com                   # domain info
allinurl:admin login               # all terms in URL
allintitle:admin panel login       # all terms in title
allintext:username password        # all terms in body
"exact phrase"                     # exact match
-exclude                           # exclude term
"keyword" OR "alternative"         # boolean OR
*                                  # wildcard
```

---

## Exposed Files and Configurations

### Configuration Files
```
site:example.com filetype:env
site:example.com filetype:config
site:example.com filetype:ini
site:example.com filetype:yaml
site:example.com filetype:yml
site:example.com filetype:json
site:example.com filetype:xml
site:example.com filetype:conf
site:example.com filetype:cnf
site:example.com inurl:config
site:example.com "database" | "db_user" | "db_pass"
site:example.com "DB_PASSWORD" | "DB_USER"
site:example.com "AWS_ACCESS_KEY_ID" | "AWS_SECRET_ACCESS_KEY"
```

### Backup Files
```
site:example.com filetype:bak
site:example.com filetype:old
site:example.com filetype:orig
site:example.com filetype:backup
site:example.com filetype:swp
site:example.com filetype:~
site:example.com "backup" | "restore" | "archive"
site:example.com intitle:"index of" "backup"
site:example.com inurl:backup
```

### Log Files
```
filetype:log
filetype:syslog
site:example.com filetype:log
allintext:username filetype:log
inurl:error filetype:log
inurl:nginx filetype:log
filetype:log "PHP Parse error" | "PHP Warning" | "PHP Error"
filetype:log intext:"ConnectionManager2"
filetype:log inurl:"password.log"
intitle:index.of cleanup.log
intitle:index.of filetype:log
```

### Sensitive Document Extensions
```
site:example.com (ext:doc OR ext:docx OR ext:odt OR ext:pdf OR ext:rtf OR ext:ppt OR ext:pptx OR ext:csv OR ext:xls OR ext:xlsx OR ext:txt OR ext:xml OR ext:json OR ext:zip OR ext:rar OR ext:md OR ext:log OR ext:bak OR ext:conf OR ext:sql)

site:example.com ext:txt | ext:pdf | ext:xml | ext:xls | ext:xlsx | ext:ppt | ext:pptx | ext:doc | ext:docx
```

### Source Code Files
```
site:example.com ext:log | ext:txt | ext:conf | ext:cnf | ext:ini | ext:env | ext:sh | ext:bak | ext:backup | ext:swp | ext:old | ext:~ | ext:git | ext:svn | ext:htpasswd | ext:htaccess | ext:json

site:example.com filetype:php | filetype:js | filetype:asp "password"
site:example.com intitle:"index of" "source code"
```

---

## Login Pages and Admin Panels

```
site:example.com inurl:admin
site:example.com inurl:login
site:example.com inurl:signin
site:example.com intitle:login
site:example.com intitle:signin
site:example.com inurl:secure
site:example.com "admin" | "login" | "dashboard"
site:example.com inurl:administrator
site:example.com inurl:wp-login
site:example.com inurl:user-login
site:example.com inurl:phpmyadmin
site:example.com "phpMyAdmin"
site:example.com inurl:wp-admin
site:example.com inurl:/administrator/index.php
site:example.com "Joomla! Administration Login"
intitle:"grafana" inurl:"/grafana/login"
inurl:webvpn.html "login" "Please enter your"
inurl:"/carbon/admin/login.jsp"
intext:"HostingAccelerator" intitle:"login" +"Username"
inurl:"/phpmyadmin/user_password.php"
inurl:"/?q=user/password/"
"phpMyAdmin" "Welcome to phpMyAdmin"
```

---

## API Keys and Credentials

```
site:example.com "API key" | "API_key" | "API_token"
site:example.com "apikey" | "api_key"
site:example.com "Authorization: Bearer"
site:example.com "Authorization: Basic"
site:example.com "client_secret" | "client_id"
site:example.com "access_token"
site:example.com inurl:key=
site:example.com inurl:api_key=
site:example.com inurl:token=
site:example.com inurl:auth=
site:example.com filetype:js "token" | "key" | "secret"
site:example.com filetype:js inurl:config
site:example.com filetype:js "password"
```

### Government/Corporate Credential Dorks
```
"*.gov" send_keys
"*.gov" password
"*.gov" api_key
"*.gov" apikey
"*.gov" jira_password
"*.gov" root_password
"*.gov" access_token
"*.gov" config
"*.gov" client_secret
"*.gov" user_auth
```

---

## Vulnerable Parameter Hunting

### XSS-Prone Parameters
```
inurl:q= | inurl:s= | inurl:search= | inurl:query= | inurl:keyword= | inurl:lang= inurl:& site:example.com
inurl:& inurl:test
inurl:& inurl:quiz
inurl:& inurl:survey
inurl:& inurl:form
inurl:& inurl:search
```

### SQLi-Prone Parameters
```
inurl:id= | inurl:pid= | inurl:category= | inurl:cat= | inurl:action= | inurl:sid= | inurl:dir= inurl:& site:example.com
site:example.com ext:php inurl:?
.php?module=
?action=
?page=
?pid=
?search=
```

### SQL Error Messages
```
intext:"sql syntax near"
intext:"syntax error"
intext:"unexpected end of SQL"
intext:"Warning: mysql_"
intext:"pg_connect()"
intext:"error in your SQL syntax"
intext:"OLE DB Provider for SQL Server"
```

### Open Redirect-Prone Parameters
```
inurl:url= | inurl:return= | inurl:next= | inurl:redirect= | inurl:redir= | inurl:ret= | inurl:r2= | inurl:page= inurl:& inurl:http site:example.com
inurl:url OR inurl:continue OR inurl:returnto OR inurl:redirect OR inurl:return OR inurl:target
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

## Documentation and Debug Pages

### API Documentation
```
site:example.com inurl:docs | inurl:documentation
site:example.com inurl:apidocs | inurl:api-docs
site:example.com inurl:swagger | inurl:api-explorer
site:example.com inurl:endpoint | inurl:api
site:example.com inurl:swagger | inurl:openapi
```

### Debug and Error Pages
```
site:example.com "debug" | "test" | "staging"
site:example.com "syntax error" | "fatal error"
site:example.com "Warning:" | "Deprecated:"
site:example.com "Fatal error" | "syntax error" | "deprecated"
site:example.com "error" | "debug" | "trace"
site:example.com "exception" | "stack trace"
inurl:"error" | intitle:"exception" | intitle:"failure" | intitle:"server at" site:example.com
```

### Development Environments
```
site:example.com inurl:test | inurl:env | inurl:dev | inurl:staging | inurl:sandbox | inurl:debug | inurl:temp | inurl:internal | inurl:demo
site:example.com inurl:staging | inurl:dev | inurl:test
site:example.com inurl:qa | "Quality Assurance"
site:example.com "development only" | "testing environment"
```

---

## Exposed Databases and Directories

### Database Exposure
```
site:example.com filetype:sql | filetype:db | filetype:bak
site:example.com "backup" | "database" | "dump"
site:example.com "index of" "database"
```

### Directory Listings
```
intitle:"index of"
intitle:"index of" site:example.com
site:example.com intitle:"index of" "admin"
site:example.com intitle:"index of" "uploads" | "downloads" | "backups"
site:example.com intitle:"index of" "private" | "confidential"
site:example.com intitle:"index of" "restricted" | "internal"
site:example.com inurl:private | inurl:secret
site:example.com inurl:internal
site:example.com inurl:.git | inurl:.svn | inurl:.env
intext:"Index of /" +.htaccess
```

---

## Site-Specific Dorks

### Government Domains
```
site:*.gov ext:asp
site:*.gov ext:jsp
site:*.gov ext:aspx
site:*.gov ext:php
site:*.gov inurl:admin | inurl:login | inurl:secure
site:*.gov ext:pdf | ext:doc | ext:docx | ext:xls | ext:xlsx
site:*.gov "server error" | "database error" | "error occurred"
```

### WordPress
```
site:example.com inurl:wp- | inurl:wp-content | inurl:wp-config
site:example.com inurl:wp-login
site:example.com inurl:"/wp-login.php?action=lostpassword"
```

### Joomla
```
"Joomla! Administration Login" inurl:"/index.php"
intext:Joomla 1.6 inurl:index.php/login
```

### Adobe Experience Manager (AEM)
```
inurl:/content/usergenerated | inurl:/content/dam | inurl:/jcr:content | inurl:/libs/granite | inurl:/etc/clientlibs | inurl:/content/geometrixx | inurl:/bin/wcm | inurl:/crx/de site:example.com
```

---

## Advanced Combinations

```
site:example.com -www -shop -share -ir -mfa
site:example.com ext:php inurl:?
inurl:conf | inurl:env | inurl:cgi | inurl:bin | inurl:etc | inurl:root | inurl:sql | inurl:backup | inurl:admin | inurl:php site:example.com
intext:"confidential" | intext:"Not for Public Release" | intext:"internal use only" | intext:"do not distribute"
site:example.com "internal use only" | "not for distribution"
site:example.com filetype:pdf | filetype:xls | filetype:csv "confidential"
site:example.com "choose file"
site:example.com inurl:upload
site:example.com "file upload"
inurl:email= | inurl:phone= | inurl:password= | inurl:secret= inurl:& site:example.com
site:example.com "username" "password" filetype:xls | filetype:csv | filetype:doc
```

---

## Cloud Storage

### Amazon S3
```
site:s3.amazonaws.com "example.com"
site:amazonaws.com inurl:.s3.amazonaws.com
site:s3.amazonaws.com intitle:index.of.bucket
intitle:index.of.bucket
site:amazonaws.com inurl:index.html
```

### Google Cloud
```
site:googleapis.com "example.com"
site:drive.google.com "example.com"
site:docs.google.com inurl:"/d/" "example.com"
```

### Microsoft Azure
```
site:blob.core.windows.net "example.com"
site:onedrive.live.com "example.com"
site:sharepoint.com "example.com"
site:dev.azure.com "example.com"
```

### Other Cloud
```
site:digitaloceanspaces.com "example.com"
site:dropbox.com/s "example.com"
site:box.com/s "example.com"
site:pastebin.com "example.com"
site:jsfiddle.net "example.com"
site:codebeautify.org "example.com"
site:codepen.io "example.com"
site:github.com "example.com"
site:gitlab.com "example.com"
site:firebaseio.com "example.com"
site:jfrog.io "example.com"
```

---

## Bug Bounty Program Discovery

```
"responsible disclosure"
"vulnerability disclosure program"
"security reporting"
"bug bounty"
intext:"we take security very seriously"
inurl:/.well-known/security ext:txt
inurl:/security ext:txt "contact"
inurl:security.txt
inurl:security-policy.txt ext:txt
"powered by bugcrowd" -site:bugcrowd.com
"powered by synack"
"powered by hackerone"
inurl:/.well-known/security ext:txt intext:hackerone
"If you find a security issue" "reward"
"Report a Vulnerability"
"vulnerability reporting policy"
"submit vulnerability report"
responsible disclosure bounty
intext:"BugBounty" and intext:"BTC" and intext:"reward"
site:*.eu responsible disclosure
site:*.nl responsible disclosure
site:*.uk responsible disclosure
responsible disclosure reward r=h:eu
responsible disclosure reward r=h:nl
responsible disclosure reward r=h:uk
```

---

## Tool Integration

```bash
# Wayback URLs for sensitive files
waybackurls example.com | grep -E "\.xls|\.tar\.gz|\.bak|\.xml|\.xlsx|\.json|\.rar|\.pdf|\.sql|\.doc|\.docx|\.pptx|\.txt|\.zip|\.tgz|\.7z"

# Katana for crawling and filtering
katana -u example.com -d 5 waybackarchive,commoncrawl,alienvault -kf -jc -fx -em xls,xml,xlsx,json,pdf,sql,doc,docx,pptx,txt,zip,tar,gz,tgz,bak.7z,rar,log,cache,secret,db,backup,yml,gz,config,csv,yaml,md,md5

# Arjun + kxss parameter chain
arjun -q -u $url -oT arjun.txt && cat arjun.txt | awk -F'[?&]' '{baseUrl=$1; for (i=2; i<=NF; i++) {split($i, param, "="); print baseUrl "?" param[1] "="}}' | kxss

# Shodan with httpx
shodan search Ssl.cert.subject.CN:"example.com" 200 --fields ip_str,port

# Go-Dork automated dorking
go-dork -q "site:example.com filetype:pdf" -p 10
```

---

## Common File Extensions Reference

```
Executable: exe, msi, dmg, deb, rpm
Archive:    zip, rar, tar, gz, 7z, bz2
Document:   pdf, doc, docx, xls, xlsx, ppt, pptx
Database:   sql, db, sqlite, mdb
Config:     conf, config, cfg, ini, yaml, yml, json, xml
Backup:     bak, backup, old, orig, save, copy
Log:        log, logs, txt
Source:     php, asp, aspx, jsp, py, rb, js
Certificate: crt, pem, key, p12, pfx
```
