# Exposed API Keys / Tokens

## Recon — Where to Look

- [ ] JS files loaded by the target — open DevTools > Sources, search for `key`, `token`, `secret`, `api_key`
- [ ] Request/response headers — look for `Authorization`, `X-Api-Key`, `X-Token`
- [ ] HTML source — `view-source:https://target.com` and Ctrl+F for `key`, `secret`, `token`
- [ ] `.env`, `config.js`, `settings.py`, `application.properties` exposed on web root
- [ ] GitHub dorking:
  ```
  org:targetname "api_key"
  org:targetname "Authorization: Bearer"
  org:targetname "secret_key"
  ```
- [ ] Wayback Machine JS snapshots:
  ```bash
  waybackurls target.com | grep "\.js$" | sort -u | xargs -I{} curl -s {} | grep -E "api[_-]?key|token|secret"
  ```

## Automated Scanning

- [ ] Run [trufflehog](https://github.com/trufflesecurity/trufflehog) against target's public repos:
  ```bash
  trufflehog github --org=targetorg
  ```
- [ ] Run [Key-Checker](https://github.com/daffainfo/Key-Checker) against any found keys
- [ ] Run [gitleaks](https://github.com/gitleaks/gitleaks) against cloned repos:
  ```bash
  gitleaks detect --source . -v
  ```

## Validate the Key

- [ ] Check [keyhacks](https://github.com/streaak/keyhacks) for the specific service — find the validation curl
- [ ] Check [all-about-apikey](https://github.com/daffainfo/all-about-apikey) for expected response format
- [ ] Test with minimal read-only call first (account info, list endpoints)
  ```bash
  # Example: Stripe key validation
  curl https://api.stripe.com/v1/balance \
    -H "Authorization: Bearer sk_live_FOUND_KEY"
  ```
- [ ] Document scope of the key: read-only vs write vs admin

## Impact Assessment

- [ ] Can the key access PII (names, emails, addresses)?
- [ ] Can the key incur charges (AWS, Stripe, Twilio)?
- [ ] Can the key modify or delete data?
- [ ] Is the key for production vs dev/staging?

## References

- [keyhacks](https://github.com/streaak/keyhacks)
- [all-about-apikey](https://github.com/daffainfo/all-about-apikey)
