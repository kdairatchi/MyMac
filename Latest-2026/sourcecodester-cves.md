# sourcecodester-cves


## 2026-04-16

### SourceCodester Patient Scheduler RCE — `CVE-2026-37598`
- **Tags:** `#rce` `#web`
- **Severity:** critical · **Hunt:** 3/5 · **Score:** 40.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37598)

- **What:** Arbitrary code execution in SourceCodester Patient Appointment Scheduler v1.0 via SystemSettings.php.
- **Why it matters:** Unrestricted RCE allows complete server takeover of healthcare scheduling infrastructure.
- **Hunt signal:** POST to `/scheduler/classes/SystemSettings.php?f=update_settings` with malicious PHP payload.
- **Evidence:** [NVD] Confirms vulnerability in v1.0 allows code execution.

---
### SQLi in SourceCodester Storage Unit Rental — `CVE-2026-37589`
- **Tags:** `#sqli`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37589)

- **What:** SQL injection vulnerability in the `manage_storage_unit.php` endpoint of v1.0.
- **Why it matters:** Enables arbitrary SQL query execution, risking full database compromise.
- **Hunt signal:** `grep -R "manage_storage_unit.php" /var/www/html`
- **Evidence:** [source] NVD disclosure identifies the specific vulnerable file path and parameter handling.

---
### SourceCodester Scheduler SQLi — `CVE-2026-37600`
- **Tags:** `#sqli`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37600)

- **What:** SQL Injection vulnerability in the `view_details.php` id parameter of SourceCodester Patient Appointment Scheduler System v1.0.
- **Why it matters:** Allows attackers to extract sensitive database data, potentially leading to authentication bypass or full system compromise.
- **Hunt signal:** Probe `scheduler/admin/appointments/view_details.php?id=1' OR '1'='1`.
- **Evidence:** [source] NVD detail page · [opinion] Common failure to sanitize input in legacy PHP management systems.

---
### SourceCodester WFH Attendance System SQLi — `CVE-2026-37593`
- **Tags:** `#sqli` `#web`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37593)

- **What:** SQL Injection vulnerability in `/wfh_attendance/admin/view_att.php` in SourceCodester Online Employees Work From Home Attendance System v1.0.
- **Why it matters:** Allows attackers to interfere with database queries, potentially exfiltrating sensitive employee data or bypassing authentication.
- **Hunt signal:** pass
- **Evidence:** [NVD] Vulnerability disclosed in view_att.php · Likely requires auth due to /admin/ path.

---
### Sourcecodester Storage Unit Rental SQLi — `CVE-2026-37592`
- **Tags:** `#sqli` `#web`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37592)

- **What:** SQL injection vulnerability in the manage_pricing.php endpoint of the Sourcecodester Storage Unit Rental Management System v1.0.
- **Why it matters:** Successful exploitation allows attackers to manipulate database queries, leading to data leakage or potential server compromise.
- **Hunt signal:** Fuzz the `id` parameter in `/storage/admin/maintenance/manage_pricing.php` with `' OR 1=1--` or `sleep(5)`.
- **Evidence:** [source] NVD disclosure points to the vulnerable file · [opinion] Likely a failure to sanitize user input in a SQL query.

---
### SQLi in SourceCodester WFH Attendance System — `CVE-2026-37597`
- **Tags:** `#sqli` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 21.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37597)

- **What:** SQL Injection vulnerability in the admin attendance list endpoint allows database manipulation.
- **Why it matters:** Admin-level SQLi can lead to full database compromise, credential extraction, or potentially Remote Code Execution.
- **Hunt signal:** Fuzz `attendance_list.php` parameters for quote-based syntax errors or timing delays.
- **Evidence:** [nvd] Confirms vulnerability in `/wfh_attendance/admin/attendance_list.php` for v1.0.

---
### SQLi in Storage Unit Rental Management System v1.0 — `CVE-2026-37591`
- **Tags:** `#sqli`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 21.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37591)

- **What:** SQL injection vulnerability in the `/storage/admin/tenants/view_details.php` file.
- **Why it matters:** Allows attackers to manipulate database queries, potentially leading to data exfiltration or authentication bypass.
- **Hunt signal:** pass
- **Evidence:** [NVD] Confirms the vulnerability exists via the `view_details.php` endpoint in version 1.0.

---
### SourceCodester WFH Attendance v1.0 SQLi — `CVE-2026-37594`
- **Tags:** `#sqli`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37594)

- **What:** SQL injection vulnerability in the `view_employee.php` endpoint of the SourceCodester Online Employees Work From Home Attendance System v1.0.
- **Why it matters:** Allows authenticated attackers (likely admin) to manipulate database queries, leading to data exfiltration or potential administrative takeover.
- **Hunt signal:** pass
- **Evidence:** [source] NVD entry confirms vulnerability in /admin/view_employee.php · [opinion] Path implies authentication is required, reducing immediate internet-facing impact.

---
### SourceCodester Storage Unit Rental Management System SQLi — `CVE-2026-37590`
- **Tags:** `#sqli` `#web` `#api`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37590)

- **What:** SQL Injection vulnerability in admin rent management page of SourceCodester Storage Unit Rental Management System v1.0.
- **Why it matters:** Could allow unauthorized data manipulation, administrative compromise, and exposure of sensitive rental/financial data via parameter manipulation.
- **Hunt signal:** `SELECT payload OR "pass"` targeting search/filter parameters in `/admin/rents/manage_rent.php`
- **Evidence:** [nvd_recent] Confirmed in admin interface · [opinion] High impact due to access to backend functionality and potential credential theft.

---
### SQLi in SourceCodester WFH Attendance System v1.0 — `CVE-2026-37595`
- **Tags:** `#sqli`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37595)

- **What:** SourceCodester Online Employees Work From Home Attendance System v1.0 contains a SQL injection vulnerability in the `/wfh_attendance/admin/manage_employee.php` endpoint.
- **Why it matters:** This flaw allows attackers to interfere with database queries, potentially leading to unauthorized access to sensitive employee data or administrative takeover.
- **Hunt signal:** Test parameters in `manage_employee.php` with boolean-based SQLi payloads like `' OR 1=1-- -`.
- **Evidence:** [source] NVD vulnerability disclosure confirms the vulnerable file path and injection type.

---
### SourceCodester WFH Attendance System SQLi — `CVE-2026-37596`
- **Tags:** `#sqli`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-37596)

- **What:** SQL Injection vulnerability in `/admin/manage_department.php` allows unauthorized database manipulation.
- **Why it matters:** Attackers can exfiltrate sensitive employee data or bypass administrative controls via the vulnerable department ID parameter.
- **Hunt signal:** Probe the `id` parameter with `' OR 1=1-- -` to test for unhandled database syntax errors.
- **Evidence:** [nvd] Vulnerability confirmed in v1.0 affecting the department management endpoint.

---
