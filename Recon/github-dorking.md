# GitHub Dorking

Code search > web search for leaks. Slice by time to catch fresh commits before vendors rotate.

## Query syntax

```
org:target        # limit to an org
user:ex-dev       # specific user
repo:org/repo     # specific repo
path:.env         # specific filename/path
extension:sql     # file extension
filename:id_rsa   # filename
language:python   # filter by lang
"api_key"         # literal string
created:>2026-01  # date range
pushed:>2026-04-01
```

Combine:

```
org:target "DB_PASSWORD" extension:env
org:target filename:config.json "password"
org:target "BEGIN RSA PRIVATE KEY"
"target.com" "apikey"
"target.com" extension:env
"api.target.com" extension:js
```

## High-signal dorks

```
# Secrets by service
"target" "AWS_SECRET_ACCESS_KEY"
"target" "stripe" "sk_live_"
"target" "SENDGRID_API_KEY"
"target.com" "slack" "xoxb-"
"target.com" "twilio" "AC"

# Config leaks
"target" filename:.env
"target" filename:wp-config.php
"target" filename:docker-compose.yml
"target" filename:.npmrc _authToken
"target" path:.circleci/config.yml

# Internal infra
"target.com" filename:id_rsa
"target.com" filename:known_hosts
"target.com" "jenkins" "token"
"target.com" "vpn" password
"target.com" "jira" password

# API surface
"api.target.com" language:json
"api.target.com" extension:postman_collection
"api.target.com" "x-api-key"
```

## Time-range slicing

GitHub search caps at 1000 results per query. Slice by `pushed:`:

```
org:target "password" pushed:2024-01-01..2024-06-30
org:target "password" pushed:2024-07-01..2024-12-31
org:target "password" pushed:2025-01-01..2025-06-30
```

Iterate monthly when a term is noisy.

## Automation

```bash
# trufflehog — org-wide, only verified
trufflehog github --org=target --only-verified --json > tf.json

# gitleaks on cloned repos
for r in $(gh repo list target --limit 1000 --json nameWithOwner -q '.[].nameWithOwner'); do
  gh repo clone "$r" "/tmp/$r" -- --depth 200
  gitleaks detect --source "/tmp/$r" -r "leaks-$(basename $r).json"
done

# gwen001/github-search — mature dork runner
python3 github-code.py -t <gh_pat> -q "org:target password"
```

## Gists + forks

```
# Gists (separate from repos)
"target.com" site:gist.github.com

# Ex-employee / personal accounts
"target.com" user:<ex-dev>
```

Check fork graph — sometimes secrets deleted from main repo survive in a fork.

## Validation before reporting

- **Verify the key works** — use `Cheatsheets/keyhacks.md` methods. Expired / revoked keys = NA.
- Confirm it belongs to the target (not a third-party integration key that happened to be named similarly).
- Check if commit is in a deleted / archived repo — still live in clone history.

## Responsible behavior

- Don't clone private repos obtained through leaked tokens.
- Don't use leaked creds beyond `aws sts get-caller-identity` / `whoami` validation.
- Report and move on.

## References

- trufflehog — https://github.com/trufflesecurity/trufflehog
- gitleaks — https://github.com/gitleaks/gitleaks
- github-search — https://github.com/gwen001/github-search
- Keyhacks — https://github.com/streaak/keyhacks
