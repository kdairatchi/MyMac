# Librenms CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-16 · Items: 1_

---

## What


---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-30480 | 2026-04-16 | LibreNMS LFI in NFSen Module | high | poc | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-30480) |

---

## Probes


---

## PoCs


- **CVE-2026-30480** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-30480)

---

## Reproduction


---

## Defense


---

## References

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-30480)

---

## Items

## 2026-04-16

### LibreNMS LFI in NFSen Module — `CVE-2026-30480`

- **Tags:** `#lfi` `#path-traversal` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 21.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-30480)

- **What:** Authenticated users can include and execute arbitrary PHP files via path traversal in the `nfsen` parameter.
- **Why it matters:** Successful exploitation typically leads to Remote Code Execution (RCE), allowing full server takeover.
- **Hunt signal:** Probe `nfsen.inc.php` with `nfsen=../../../../../etc/passwd` or PHP log inclusion attempts.
- **Evidence:** [source] NVD · [opinion] High impact for internal environments where LibreNMS is often used.

---
