# Path Traversal / LFI Techniques

## 2026-10-17 — CVE-2026-21589: Atlassian Data Center Unauthenticated Arbitrary File Read

### CVE-2026-21589 — Atlassian Data Center Unauthenticated Arbitrary File Read

- **Date:** 2026-10-05 · **Source:** [cycognito.com](https://www.cycognito.com/blog/emerging-threat-cve-2026-21589-atlassian-data-center-arbitrary-file-access-via-path-traversal/) · **Class:** cve
- **What:** Unauthenticated path traversal across eight self-hosted Atlassian Data Center products (Jira, Confluence, Bitbucket, Bamboo, Crowd, Crucible, Fisheye, Jira Service Management) allows reading arbitrary files from the host filesystem; CVSS 9.3, CISA KEV added 2026-10-15, patch deadline 2026-10-18.
- **Why it matters:** Any self-hosted Atlassian stack in bug bounty scope is immediately exploitable with no credentials; default config paths (database.yml, server.xml) are predictable and expose credentials for further pivot.
- **Hunt signal:** `GET /<product>/rest/api/latest/../../../../../../etc/passwd` — WAF regex: `\.\.\/` on Atlassian REST paths; check access logs for two-dot traversal sequences; nuclei tag `CVE-2026-21589`
- **Evidence:** [securityaffairs] https://securityaffairs.com/201086/hacking/u-s-cisa-adds-atlassian-flaw-to-its-known-exploited-vulnerabilities-catalog.html · [cycognito] https://www.cycognito.com/blog/emerging-threat-cve-2026-21589-atlassian-data-center-arbitrary-file-access-via-path-traversal/ · [inceptionsecurity hunt guide] https://www.inceptionsecurity.com/post/atlassian-cve-2026-21589-arbitrary-file-read-hunt

---
