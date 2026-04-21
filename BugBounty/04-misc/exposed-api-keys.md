---
tags: [bugbounty, misc/api-keys, cheatsheet, p2, p3]
aliases: [Exposed API Keys, Secret Keys, Credential Leaks]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Exposed API Keys & Secrets

> [!tldr] Hunter Summary
> **What:** Find leaked credentials in JS files, git history, response headers, mobile apps.
> **Impact:** Varies by service — S3 access, Stripe charges, email blast, AWS takeover.
> **Best targets:** JS-heavy apps, mobile apps, any app with third-party integrations.
> **Time to triage:** 10 min JS grep. Use trufflehog/gitleaks on repos.

---

## Where to Find

| Location | How to find |
|----------|-------------|
| JS files | Grep for key patterns in all loaded `.js` files |
| HTML source | `view-source:` + search for common patterns |
| HTTP response headers | Some backends leak keys in custom headers |
| API responses | Verbose API responses may include internal config |
| Git history | `git log -p` / trufflehog on exposed `.git` |
| Mobile apps | Decompile APK/IPA, grep for secrets |
| Environment vars | If `/proc/self/environ` or error pages show env |

---

## Step-by-Step Hunt

### Step 1 — Collect all JS files
```bash
# gau + httpx to get all JS URLs
gau target.com | grep "\.js$" | httpx -mc 200 -o js_files.txt

# Or katana
katana -u https://target.com -jc -d 5 | grep "\.js$" | sort -u > js_urls.txt

# Download all JS
while read url; do
  curl -s "$url" >> all_js.txt
done < js_urls.txt
```

### Step 2 — Grep for secret patterns
```bash
# Regex patterns for common secrets
grep -Ei \
  "(api_key|apikey|api-key|access_key|secret_key|auth_token|client_secret|private_key)" \
  all_js.txt

# AWS
grep -E "AKIA[0-9A-Z]{16}" all_js.txt
grep -E "aws_secret|AWS_SECRET" all_js.txt

# Stripe
grep -E "sk_(live|test)_[0-9a-zA-Z]{24}" all_js.txt

# GitHub
grep -E "ghp_[a-zA-Z0-9]{36}" all_js.txt
grep -E "github_pat_[a-zA-Z0-9]{82}" all_js.txt

# Google
grep -E "AIza[0-9A-Za-z\-_]{35}" all_js.txt

# Twilio
grep -E "SK[0-9a-fA-F]{32}" all_js.txt
grep -E "AC[a-zA-Z0-9]{32}" all_js.txt

# JWT
grep -E "eyJ[a-zA-Z0-9_-]{10,}" all_js.txt

# Slack
grep -E "xox[baprs]-[0-9a-zA-Z]{10,}" all_js.txt
```

### Step 3 — Run automated secret scanners
```bash
# trufflehog (git history and JS)
trufflehog git https://github.com/target-org/target-repo

# gitleaks (local or remote)
gitleaks detect --source . -v
gitleaks detect --source /path/to/cloned-repo

# secretfinder (JS-focused)
python3 secretfinder.py -i https://target.com/main.js -o cli

# nuclei exposure templates
nuclei -u https://target.com -t exposures/tokens/
```

### Step 4 — Validate found keys
```bash
# AWS key validation
aws sts get-caller-identity --access-key-id AKID --secret-access-key SECRET

# GitHub token
curl -H "Authorization: token GITHUB_TOKEN" https://api.github.com/user

# Stripe
curl https://api.stripe.com/v1/charges -u "sk_live_XXX:"

# SendGrid
curl -H "Authorization: Bearer TOKEN" https://api.sendgrid.com/v3/user/profile

# Use keyhacks for all supported services:
# https://github.com/streaak/keyhacks
```

### Step 5 — Check source maps
```bash
# Source maps may contain original source code with secrets
# Look for .js.map files
curl https://target.com/main.js.map 2>/dev/null | jq '.sources[]' | head -20
```

### Step 6 — Check git history (if /.git exposed)
```bash
# If /.git is exposed:
mkdir -p stolen_git && cd stolen_git
wget -r -np https://target.com/.git/

# Reconstruct and search history
git log --all --oneline
git show --stat HEAD
trufflehog git file:///path/to/stolen_git
```

---

## Common Services to Validate

| Service | Test endpoint |
|---------|--------------|
| AWS | `aws sts get-caller-identity` |
| GitHub | `GET /user` with token |
| Stripe | `GET /v1/balance` |
| Twilio | `GET /2010-04-01/Accounts.json` |
| SendGrid | `GET /v3/user/profile` |
| Slack | `GET /api/auth.test` |
| Google Maps | Make a Maps API request |
| Firebase | Try RTDB read: `.json?auth=TOKEN` |

---

## 2025-2026 Notes

> [!info] New secret exposure surface (2025-2026)
> - **AI provider keys:** `OPENAI_API_KEY`, `ANTHROPIC_API_KEY` — often in JS for demo apps
> - **GitHub Actions artifacts:** Build artifacts may contain debug outputs with secrets
> - **Terraform state:** If app has public S3 bucket, check for `*.tfstate` files containing infra secrets
> - **Docker image layers:** `docker history image:tag` reveals build steps that may include secrets

---

## References

- keyhacks — https://github.com/streaak/keyhacks
- trufflehog — https://github.com/trufflesecurity/trufflehog
- secretfinder — https://github.com/m4ll0k/SecretFinder
- all-about-apikey — https://github.com/daffainfo/all-about-apikey
