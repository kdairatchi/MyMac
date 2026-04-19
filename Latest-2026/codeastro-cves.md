# codeastro-cves


## 2026-04-19

### CodeAstro Attendance SQLi Auth Bypass — `CVE-2026-37749`
- **Tags:** `#sqli` `#auth-bypass`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37749)

- **What:** Unauthenticated SQL injection in the username parameter of index.php allows authentication bypass.
- **Why it matters:** Enables remote attackers to gain full administrative access to the system without credentials.
- **Hunt signal:** `' OR 1=1-- -` in username field.
- **Evidence:** [NVD] Confirmed vector in v1.0 · [analysis] Classic boolean-based injection.

---
