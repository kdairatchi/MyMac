# F5 CVEs

> Tracked CVEs for F5 BIG-IP / BIG-IQ. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-11-19 · Items: 1_

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-94127 | 2026-09-23 | F5 BIG-IP Unauth Heap Overflow to RCE | critical | poc | [src](https://labs.watchtowr.com/is-this-a-joke-in-the-auth-header-f5-big-ip-unauth-heap-overflow-to-rce-cve-2026-94127/) |

---

## 2026-09-23 — F5 BIG-IP Unauth Heap Overflow RCE (CVE-2026-94127)

- **Date:** 2026-09-23 · **Source:** [watchTowr](https://labs.watchtowr.com/is-this-a-joke-in-the-auth-header-f5-big-ip-unauth-heap-overflow-to-rce-cve-2026-94127/) · **Class:** cve
- **What:** Unauth heap overflow in the Authorization header handler leads to RCE on F5 BIG-IP. Trivially reachable — just send a crafted Auth header.
- **Why it matters:** BIG-IP is the load balancer for most large enterprises. Unauth heap overflow in the auth header is as easy to reach as it gets.
- **Hunt signal:** Shodan for BIG-IP. `nuclei -t cves/2026/CVE-2026-94127.yaml`. Check if targets' load balancers are F5.
- **Evidence:** [source](https://labs.watchtowr.com/is-this-a-joke-in-the-auth-header-f5-big-ip-unauth-heap-overflow-to-rce-cve-2026-94127/)
