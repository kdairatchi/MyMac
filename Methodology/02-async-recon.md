# Async Recon Funnel

Passive → active → deep. Never hammer when a passive source answers.

## Stage 1 — Passive (no packets to target)

```bash
# Domain → subdomains (sources: crt.sh, CT logs, WHOIS, scrape APIs)
subfinder -d target.com -all -silent -o subs-passive.txt
amass enum -passive -d target.com -o subs-amass.txt
assetfinder --subs-only target.com >> subs-passive.txt

# CT logs
curl -s "https://crt.sh/?q=%25.target.com&output=json" \
  | jq -r '.[].name_value' | tr ',' '\n' | sort -u

# Archive.org
curl -s "http://web.archive.org/cdx/search/cdx?url=*.target.com/*&output=text&fl=original&collapse=urlkey" \
  | sort -u > wayback.txt

# GitHub — trufflehog/gitleaks for leaked creds (only OSINT-scope)
trufflehog github --org=target --only-verified

# Merge and dedupe
cat subs-*.txt | anew all-subs.txt
```

## Stage 2 — Resolve + probe (low-touch active)

```bash
# Resolve live hosts
dnsx -l all-subs.txt -resp-only -a -silent -o resolved.txt

# HTTP probe
httpx -l resolved.txt -sc -title -tech-detect -cdn -json -o httpx.json

# Extract interesting by tech
jq -r 'select(.tech | tostring | test("WordPress|Jenkins|GitLab|Jira")) | .url' httpx.json
```

## Stage 3 — Deep crawl (scope-aware, rate-limited)

```bash
# Crawl + collect JS/endpoints
katana -list live.txt -jc -kf all -d 3 -c 10 -rl 50 -o katana.txt

# Historical URLs from wayback/commoncrawl/otx
gau --subs target.com | tee gau.txt
waybackurls target.com | tee wayback-urls.txt

# Param discovery
cat gau.txt katana.txt | unfurl format '%s://%d%p?%q' | qsreplace FUZZ | sort -u > params.txt
```

## Stage 4 — Surface-class routing

| Output                     | Route to                            |
|----------------------------|-------------------------------------|
| `*.js`                     | `Recon/js-analysis.md` (secrets, endpoints) |
| URLs with query strings    | gf patterns → xss/ssrf/sqli/lfi queues |
| Admin / login endpoints    | auth checklist                      |
| `/api/`, `/graphql`, `/v1/`| `Checklists/API/`                   |
| S3/GCS buckets             | `Checklists/Cloud/`                 |
| Open dirs / `.git/` / `.env`| content-discovery follow-up        |

## Rate / etiquette

- Default `-rl 50` (50 rps) or lower. Programs watch for scraping.
- Honor `robots.txt` for scope hints (not access control).
- Identify via `X-Bug-Bounty` header (see `01-scope-review.md`).
- Pause on 429 / Cloudflare challenge.

## References

- projectdiscovery — https://github.com/projectdiscovery
- tomnomnom — https://github.com/tomnomnom
- Jason Haddix TBHM — https://github.com/jhaddix/tbhm
