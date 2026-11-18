# Cisco CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-17 · Items: 2_

---

## What


---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-20059 | 2026-04-17 | Cisco Unity Connection Reflected XSS | medium | theoretical | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-20059) |
| CVE-2026-20060 | 2026-04-17 | Cisco Unity Connection Open Redirect | low | theoretical | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-20060) |

---

## Probes


---

## PoCs


- **CVE-2026-20059** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-20059)
- **CVE-2026-20060** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-20060)

---

## Reproduction


---

## Defense


---

## References

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-20059)
- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-20060)

---

## Items

## 2026-04-17

### Cisco Unity Connection Reflected XSS — `CVE-2026-20059`

- **Tags:** `#xss` `#web`
- **Severity:** medium · **Hunt:** 5/5 · **Score:** 25.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-20059)

- **What:** Unauthenticated reflected XSS in the web-based management interface due to improper input validation.
- **Why it matters:** Attackers can execute arbitrary script or access sensitive browser-based information by tricking a user into clicking a crafted link.
- **Hunt signal:** Probe Unity Connection management interface parameters for reflection without encoding in HTTP responses.
- **Evidence:** [source] NVD vulnerability detail (2026-04-15).

---

### Cisco Unity Connection Open Redirect — `CVE-2026-20060`

- **Tags:** `#web` `#appliance`
- **Severity:** low · **Hunt:** 2/5 · **Score:** 6.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-20060)

- **What:** Unauthenticated open redirect in the web management interface via improper parameter validation.
- **Why it matters:** Enables phishing attacks by redirecting users from a trusted Cisco domain to malicious sites.
- **Hunt signal:** Fuzz common redirect parameters (e.g., `?url=`, `?target=`) on `/web/` and `/cuadmin/` endpoints.
- **Evidence:** [NVD] states improper input validation of HTTP parameters allows redirection to malicious pages.

---
