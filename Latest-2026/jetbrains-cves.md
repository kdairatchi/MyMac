# Jetbrains CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-19 · Items: 1_

---

## What


---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-41153 | 2026-04-19 | JetBrains Junie RCE via Project File | critical | poc | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-41153) |

---

## Probes


---

## PoCs


- **CVE-2026-41153** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-41153)

---

## Reproduction


---

## Defense


---

## References

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-41153)

---

## Items

## 2026-04-19

### JetBrains Junie RCE via Project File — `CVE-2026-41153`
- **Tags:** `#rce`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-41153)

- **What:** JetBrains Junie before build 252.549.29 allows arbitrary command execution when loading a malicious project file.
- **Why it matters:** Developers can be compromised simply by opening a shared or downloaded project, leading to host takeover.
- **Hunt signal:** pass (file-based interaction required).
- **Evidence:** [NVD] confirms RCE via project file manipulation.

---
