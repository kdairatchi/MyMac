# firebird-cves


## 2026-04-19

### CVE-2025-65104 Firebird Client Information Leak — `CVE-2025-65104`
- **Tags:** `#data-exfil` `#api`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2025-65104)

- **What:** Firebird v3 client library incorrectly sets data lengths in XSQLDA fields when communicating with FB4+ servers, causing information leakage.
- **Why it matters:** Compromised data length fields may expose sensitive data from server responses to attackers during database operations.
- **Hunt signal:** Check Firebird client version; if <4, monitor protocol traces for unexpected length fields in responses.
- **Evidence:** [nvd_recent] · [opinion] Protocol-level vulnerability requires client-side validation to exploit.

---
