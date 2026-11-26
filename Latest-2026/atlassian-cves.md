# Atlassian CVEs

> Tracked CVEs for Atlassian products (Jira, Confluence, Bitbucket). Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-11-26 · Items: 2_

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-90436 | 2026-11-26 | Apache Axis 1.x Unauth RCE in Confluence Data Center | 9.8 | exploited/kev | [src](https://www.rapid7.com/blog/post/etr-rapid7-detected-exploitation-of-cve-2026-90436-against-atlassian-confluence-data-center-n-able-n-central-also-exploited/) |
| CVE-2026-21589 | 2026-10-06 | Atlassian Jira/Confluence Pre-Auth Arbitrary File Read | high | poc | [src](https://labs.watchtowr.com/you-wont-hear-about-these-even-in-myths-atlassian-jira-confluence-and-more-pre-auth-arbitrary-file-read-cve-2026-21589/) |

---

## 2026-10-06 — Atlassian Pre-Auth File Read (CVE-2026-21589)

- **Date:** 2026-10-06 · **Source:** [watchTowr](https://labs.watchtowr.com/you-wont-hear-about-these-even-in-myths-atlassian-jira-confluence-and-more-pre-auth-arbitrary-file-read-cve-2026-21589/) · **Class:** cve
- **What:** Pre-auth arbitrary local file read across Jira, Confluence, and other Atlassian products. Path traversal variant.
- **Why it matters:** Atlassian is everywhere in enterprise. Pre-auth file read leaks `dbconfig.xml`, application secrets, internal configs. Chain to full compromise.
- **Hunt signal:** Check targets for Atlassian stack. Test path traversal per watchTowr writeup. Bug bounty targets running self-hosted Confluence/Jira are highest priority.
- **Evidence:** [source](https://labs.watchtowr.com/you-wont-hear-about-these-even-in-myths-atlassian-jira-confluence-and-more-pre-auth-arbitrary-file-read-cve-2026-21589/)

## 2026-11-26 — Apache Axis 1.x Unauth RCE in Confluence Data Center (CVE-2026-90436)

### CVE-2026-90436: Apache Axis Unauth RCE via SOAP Fault Deserialization
- **Date:** 2026-11-26 · **Source:** [Rapid7 ETR](https://www.rapid7.com/blog/post/etr-rapid7-detected-exploitation-of-cve-2026-90436-against-atlassian-confluence-data-center-n-able-n-central-also-exploited/) · **Class:** cve
- **What:** Unauthenticated RCE in Apache Axis 1.x (embedded in Confluence Data Center) via SOAP fault deserialization — requires Remote API (XML-RPC/SOAP) enabled; affects DC 1.x–9.x; fixed in 9.2.28; v10.x and Cloud unaffected.
- **Why it matters:** 1.2M internet-exposed instances per Cryptika; CISA KEV 2026-11-18; public Metasploit module 2026-11-17; active exploitation confirmed by Rapid7 on 2026-11-13.
- **Hunt signal:** Probe `/_api/rpc/xmlrpc` or `/rpc/xmlrpc` — 200 with XML response = Remote API enabled, test for Axis version. Nuclei tag: `CVE-2026-90436`. Detection-only scanner: `foxcornlab/confluence-axis-scanner`.
- **Evidence:** [Rapid7 ETR](https://www.rapid7.com/blog/post/etr-rapid7-detected-exploitation-of-cve-2026-90436-against-atlassian-confluence-data-center-n-able-n-central-also-exploited/) · [cipherssecurity](https://cipherssecurity.com/apache-axis-cve-2026-90436-confluence-rce/) · [eastbaycyber](https://eastbaycyber.com/content/cve-2026-90436/) · CVSS 9.8 (third-party) / 9.3 Atlassian v4.0 · CISA KEV: YES (2026-11-18, fed deadline 2026-11-21) · PoC: PUBLIC (Metasploit 2026-11-17)
