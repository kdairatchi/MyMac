# itsourcecode-cves


## 2026-07-01

### itsourcecode Hospital Management System 1.0 SQL Injection in /appointmentdetail.php — `CVE-2026-13530`
- **Tags:** `#sqli` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13530)

- **What:** Unauthenticated SQL injection via the `editid` parameter in `/appointmentdetail.php` (Appointment Handler component).
- **Why it matters:** Remote, unauth SQLi with a public exploit in a healthcare management system — data exfiltration or auth bypass is trivial.
- **Hunt signal:** `curl -s "https://target/appointmentdetail.php?editid=1'+OR+1%3d1--+-" | grep -iE "sql|error|syntax|mysql"`
- **Evidence:** [NVD] Public exploit available, remotely exploitable SQLi in itsourcecode HMS 1.0. · [opinion] Classic unauth SQLi on healthcare app — high-value target, likely many exposed instances.

---
### SQLi in Hospital Management System /department.php via editid — `CVE-2026-13531`
- **Tags:** `#sqli` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 21.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13531)

- **What:** Unauthenticated SQL injection in `/department.php` through the `editid` parameter in itsourcecode Hospital Management System 1.0.
- **Why it matters:** Public exploit is available and the attack can be performed remotely, making active exploitation likely against exposed instances.
- **Hunt signal:** `inurl:"/department.php" + "Hospital Management System"` or fingerprint itsourcecode HMS and test `editid=1'` on `/department.php`.
- **Evidence:** [nvd] Remote SQL injection with public PoC · [opinion] low-value bug bounty target (itsourcecode CMS), but good for mass-hunting exposed instances.

---
### SQLi in itsourcecode Hospital Management System deptDoctor.php — `CVE-2026-13532`
- **Tags:** `#sqli` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 21.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13532)

- **What:** Unauthenticated SQL injection via the `deptid` parameter in `/departmentDoctor.php` in itsourcecode Hospital Management System 1.0.
- **Why it matters:** Remote exploitation with a public PoC means low-skill attackers can dump the database; medical systems often hold sensitive PII/PHI.
- **Hunt signal:** `inurl:"/departmentDoctor.php" AND "itsourcecode"` — test `deptid=1' OR 1=1--` for error-based or union injection.
- **Evidence:** [source] NVD entry confirms remote attack vector and public exploit availability · [opinion] niche product limits broad targets but any exposed instance is trivially compromisable.

---
