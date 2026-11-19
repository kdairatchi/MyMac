# Atlassian CVEs

> Tracked CVEs for Atlassian products (Jira, Confluence, Bitbucket). Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-11-19 · Items: 1_

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-21589 | 2026-10-06 | Atlassian Jira/Confluence Pre-Auth Arbitrary File Read | high | poc | [src](https://labs.watchtowr.com/you-wont-hear-about-these-even-in-myths-atlassian-jira-confluence-and-more-pre-auth-arbitrary-file-read-cve-2026-21589/) |

---

## 2026-10-06 — Atlassian Pre-Auth File Read (CVE-2026-21589)

- **Date:** 2026-10-06 · **Source:** [watchTowr](https://labs.watchtowr.com/you-wont-hear-about-these-even-in-myths-atlassian-jira-confluence-and-more-pre-auth-arbitrary-file-read-cve-2026-21589/) · **Class:** cve
- **What:** Pre-auth arbitrary local file read across Jira, Confluence, and other Atlassian products. Path traversal variant.
- **Why it matters:** Atlassian is everywhere in enterprise. Pre-auth file read leaks `dbconfig.xml`, application secrets, internal configs. Chain to full compromise.
- **Hunt signal:** Check targets for Atlassian stack. Test path traversal per watchTowr writeup. Bug bounty targets running self-hosted Confluence/Jira are highest priority.
- **Evidence:** [source](https://labs.watchtowr.com/you-wont-hear-about-these-even-in-myths-atlassian-jira-confluence-and-more-pre-auth-arbitrary-file-read-cve-2026-21589/)
