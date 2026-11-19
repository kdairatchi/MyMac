# PaperCut CVEs

> Tracked CVEs for PaperCut print management. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-11-19 · Items: 1_

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-82077/82078/81578 | 2026-10-09 | PaperCut Pre-Auth RCE Chain + Patch Bypasses | critical | poc | [src](https://labs.watchtowr.com/death-by-a-thousand-papercuts-papercut-pre-auth-rce-chain-and-patch-bypasses-wt-2026-0141-0144-cve-2026-82077-cve-2026-82078-cve-2026-81578/) |

---

## 2026-10-09 — PaperCut Pre-Auth RCE Chain (CVE-2026-82077/82078/81578)

- **Date:** 2026-10-09 · **Source:** [watchTowr](https://labs.watchtowr.com/death-by-a-thousand-papercuts-papercut-pre-auth-rce-chain-and-patch-bypasses-wt-2026-0141-0144-cve-2026-82077-cve-2026-82078-cve-2026-81578/) · **Class:** cve
- **What:** Pre-auth RCE chain in PaperCut, plus three patch bypasses (WT-2026-0141 through 0144). Prior patches were incomplete.
- **Why it matters:** PaperCut is common in edu/enterprise. The patch bypass pattern means first-party fixes didn't address root cause — variant hunting opportunity.
- **Hunt signal:** Shodan for PaperCut. Patch diff the WT-2026-0141 through 0144 fixes. `nuclei -t cves/2026/CVE-2026-82077.yaml`
- **Evidence:** [source](https://labs.watchtowr.com/death-by-a-thousand-papercuts-papercut-pre-auth-rce-chain-and-patch-bypasses-wt-2026-0141-0144-cve-2026-82077-cve-2026-82078-cve-2026-81578/)
