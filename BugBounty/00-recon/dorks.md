---
tags: [bugbounty, recon, dorks, github, google, shodan]
aliases: [Dorks, OSINT Dorks, Search Dorks]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Recon Dorks — GitHub, Google, Shodan, Fofa

> [!tip] Usage
> Replace `TARGET` with the company name, `target.com` with the domain.
> GitHub dorks: paste into GitHub code search. Google dorks: paste into Google.

---

## GitHub Dorks

### Credentials & Secrets
```
# API keys / tokens
org:TARGET "api_key" OR "apikey" OR "api-key"
org:TARGET "secret_key" OR "secret" OR "SECRET"
org:TARGET "access_token" OR "auth_token"
org:TARGET "password" filename:.env
org:TARGET "AWS_SECRET_ACCESS_KEY"
org:TARGET "GITHUB_TOKEN" OR "GH_TOKEN"
org:TARGET "stripe" "key" OR "secret"
org:TARGET "twilio" "token" OR "SID"
org:TARGET "sendgrid" "api_key"
org:TARGET "database_url" OR "DATABASE_URL"

# Private keys
org:TARGET "BEGIN RSA PRIVATE KEY"
org:TARGET "BEGIN OPENSSH PRIVATE KEY"
org:TARGET "BEGIN PGP PRIVATE KEY"

# Config files
org:TARGET filename:.env
org:TARGET filename:config.yml password OR secret OR key
org:TARGET filename:settings.py SECRET_KEY
org:TARGET filename:.htpasswd
org:TARGET filename:id_rsa
org:TARGET filename:credentials
org:TARGET filename:wp-config.php
```

### Endpoints & Structure
```
org:TARGET "staging" OR "preprod" OR "dev" OR "internal"
org:TARGET filename:docker-compose.yml
org:TARGET "localhost" OR "127.0.0.1" filetype:env
org:TARGET filename:.npmrc _auth
org:TARGET "jdbc:" OR "mongodb://" OR "redis://"
```

### Domain-based
```
target.com "api_key" OR "secret"
"@target.com" password
site:github.com target.com "token"
```

---

## Google Dorks

### Admin / Login Panels
```
site:target.com intitle:"admin" OR intitle:"login" OR intitle:"dashboard"
site:target.com inurl:admin OR inurl:login OR inurl:panel
site:target.com inurl:/admin/login
site:target.com "phpMyAdmin" OR "phpmyadmin"
site:target.com inurl:wp-admin
```

### Exposed Files / Configs
```
site:target.com ext:env OR ext:log OR ext:sql
site:target.com ext:xml OR ext:json inurl:config
site:target.com filetype:pdf OR filetype:docx "confidential"
site:target.com intitle:"index of" 
site:target.com "Index of /" "Parent Directory"
site:target.com ext:backup OR ext:bak OR ext:old
site:target.com inurl:.git
```

### Sensitive Data
```
site:target.com "api_key" OR "apikey"
site:target.com "password" OR "passwd" filetype:log
site:target.com "username" "password" filetype:txt
site:target.com intext:"BEGIN RSA PRIVATE KEY"
```

### Subdomains / Endpoints
```
site:*.target.com
site:target.com inurl:api
site:target.com inurl:swagger OR inurl:api-docs
site:target.com inurl:graphql
site:target.com inurl:test OR inurl:staging OR inurl:dev
```

### Error Messages (version disclosure)
```
site:target.com "Warning: mysql_"
site:target.com "ORA-01756" OR "ORA-00921"
site:target.com "SQLSTATE[" 
site:target.com "Microsoft OLE DB"
site:target.com intitle:"Error" "stack trace"
```

---

## Shodan Dorks

```
# Org-based
org:"Target Company Inc"
org:"Target" ssl:"target.com"
org:"Target" http.title:"Login"
org:"Target" port:8080 OR port:8443 OR port:9200 OR port:6379

# Domain-based
ssl.cert.subject.cn:"*.target.com"
ssl:"target.com" 200 "admin"

# Technology-specific
org:"Target" product:"Jenkins"
org:"Target" product:"Elasticsearch"
org:"Target" "MongoDB Server Information"
org:"Target" "Grafana"
org:"Target" product:"GitLab"

# Exposed services
hostname:target.com port:22
hostname:target.com port:3306
hostname:target.com port:5432 "PostgreSQL"
hostname:target.com port:6379 "Redis"
hostname:target.com port:9200 "Elasticsearch"
hostname:target.com port:2375 "Docker Remote API"
hostname:target.com port:8500 "Consul"
```

---

## Fofa Dorks (fofa.info)

```
domain="target.com"
domain="target.com" && title="admin"
domain="target.com" && body="api_key"
domain="target.com" && port="8080"
org="Target Company" && (port="3306" || port="5432" || port="6379")
cert="target.com" && country="US"
```

---

## Wayback / Archive Dorks

```bash
# Historical endpoints
gau target.com | grep -E "(api|admin|login|secret|password|key|token)"

# Wayback API
curl "http://web.archive.org/cdx/search/cdx?url=*.target.com/*&output=text&fl=original&collapse=urlkey&filter=statuscode:200"

# Find old sensitive files
curl "https://web.archive.org/cdx/search/cdx?url=target.com/*.env&output=json&limit=100"
curl "https://web.archive.org/cdx/search/cdx?url=target.com/*.sql&output=json&limit=100"
```

---

## Certificate Transparency (subdomain finding)

```bash
# crt.sh
curl -s "https://crt.sh/?q=%.target.com&output=json" | \
  jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u

# ct.js
ct target.com
```

---

## 2025-2026 Notes

> [!info] New dork targets (2025-2026)
> - **AI/LLM config files:** `org:TARGET filename:openai.yaml`, `org:TARGET "ANTHROPIC_API_KEY"`
> - **GitHub Actions secrets:** `org:TARGET path:.github/workflows "secret"` — workflow files sometimes echo secrets
> - **Docker Hub:** Search for `target` organization images that may contain secrets
> - **Terraform state files:** `org:TARGET filename:*.tfstate` — may contain cloud credentials and IP ranges
> - **Kubernetes configs:** `org:TARGET filename:kubeconfig` OR `org:TARGET filename:*.kubeconfig`

---

## References

- SecLists Google Dorks — https://github.com/danielmiessler/SecLists/tree/master/Miscellaneous/google-dorks
- GitHub Dorks — https://github.com/techgaun/github-dorks
- Shodan Dork List — https://github.com/humblelad/Shodan-Dorks
