# Broken Link Hijacking

## Scope — What to Target

- [ ] Social media profile links in footers/about pages (Twitter, LinkedIn, Facebook, GitHub)
- [ ] External library/CDN links that may have expired
- [ ] Old partner/sponsor links
- [ ] Documentation links pointing to third-party domains

## Discovery

- [ ] Crawl the target and extract all external links:
  ```bash
  # Using katana
  katana -u https://target.com -d 3 -jc | grep -oP 'https?://[^\s"<>]+' | grep -v target.com

  # Using waybackurls for historical links
  waybackurls target.com | grep -oP 'https?://[^\s"<>]+' | grep -v target.com | sort -u
  ```
- [ ] Run [broken-link-checker](https://github.com/stevenvachon/broken-link-checker):
  ```bash
  blc https://target.com -ro --exclude target.com
  ```
- [ ] Install and use [Check My Links](https://chrome.google.com/webstore/detail/check-my-links/ojkcdipcgfaekbeaelaapakgnjflfglf) Chrome extension

## Verify a Link is Claimable

- [ ] Confirm the external domain resolves (NXDOMAIN = expired/available):
  ```bash
  dig +short expired-domain.com
  # No response = available
  ```
- [ ] Check domain availability:
  ```bash
  whois expired-domain.com | grep -i "no match\|not found\|available"
  ```
- [ ] Check if a GitHub/npm/social handle linked on target is unclaimed:
  ```bash
  curl -s -o /dev/null -w "%{http_code}" https://github.com/unclaimed-org
  # 404 = claimable
  ```

## Claim and Document (PoC)

- [ ] Register the expired domain or unclaimed handle (check program rules first — some prohibit actual registration)
- [ ] Set up a benign PoC page at the claimed URL showing the takeover (no phishing content)
- [ ] Screenshot: target page linking to your controlled domain
- [ ] Screenshot: your controlled page loading from that link

## References

- [Broken Link Hijacking by edoverflow](https://edoverflow.com/2017/broken-link-hijacking/)
- [HackerOne #1466889](https://hackerone.com/reports/1466889)
- [How I was able to takeover the company's LinkedIn Page](https://medium.com/@bathinivijaysimhareddy/how-i-takeover-the-companys-linkedin-page-790c9ed2b04d)
