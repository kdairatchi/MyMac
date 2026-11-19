# Barracuda CVEs

> Tracked CVEs for Barracuda appliances. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-11-19 · Items: 1_

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-116606 / CVE-2026-111560 | 2026-11-05 | Barracuda ESG Pre-Auth Remote Root RCE | critical | poc | [src](https://labs.watchtowr.com/barracuda-networks-is-your-new-best-friend-barracuda-email-security-gateway-pre-auth-remote-root-rce-cve-2026-116606-cve-2026-111560/) |

---

## 2026-11-05 — Barracuda ESG Pre-Auth Root RCE (CVE-2026-116606 / CVE-2026-111560)

- **Date:** 2026-11-05 · **Source:** [watchTowr](https://labs.watchtowr.com/barracuda-networks-is-your-new-best-friend-barracuda-email-security-gateway-pre-auth-remote-root-rce-cve-2026-116606-cve-2026-111560/) · **Class:** cve
- **What:** Two chained pre-auth vulns in Barracuda Email Security Gateway give remote root. No creds needed.
- **Why it matters:** Barracuda ESG sits at the email perimeter. Pre-auth root is full compromise of all inbound/outbound email.
- **Hunt signal:** Shodan dork for Barracuda ESG. `nuclei -t cves/2026/CVE-2026-116606.yaml` once template drops. Variant hunt: shared codebase across other Barracuda appliances.
- **Evidence:** [source](https://labs.watchtowr.com/barracuda-networks-is-your-new-best-friend-barracuda-email-security-gateway-pre-auth-remote-root-rce-cve-2026-116606-cve-2026-111560/)

---

## Probes

- Shodan: `Barracuda "Email Security Gateway"`
- Wait for nuclei template, then: `nuclei -t cves/2026/CVE-2026-116606.yaml`
