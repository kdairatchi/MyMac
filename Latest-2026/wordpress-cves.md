# wordpress-cves


## 2026-04-19

### WP Customer Area Arbitrary File Read/Delete — `CVE-2026-3464`
- **Tags:** `#lfi` `#rce` `#web`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-3464)

- **What:** Insufficient path validation in the `ajax_attach_file` function allows authenticated users to read or delete arbitrary files.
- **Why it matters:** Attackers with low privileges (e.g., Subscriber) can delete `wp-config.php` to trigger RCE.
- **Hunt signal:** Identify WP Customer Area versions <= 8.3.4 and send path traversal payloads (e.g., `../../wp-config.php`) to the file attachment endpoint.
- **Evidence:** [source] NVD details vulnerability in versions up to 8.3.4 · [opinion] Significant privilege escalation risk due to the ability to destroy system integrity via file deletion.

---
### Pz-LinkCard Stored XSS via 'blogcard' Shortcode — `CVE-2026-2434`
- **Tags:** `#xss` `#web`
- **Severity:** medium · **Hunt:** 3/5 · **Score:** 15.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-2434)

- **What:** Stored Cross-Site Scripting in the Pz-LinkCard WordPress plugin via 'blogcard' shortcode attributes due to insufficient sanitization.
- **Why it matters:** Authenticated attackers with Contributor-level access can inject persistent scripts to hijack higher-privileged sessions.
- **Hunt signal:** Inspect page source for `[blogcard]` shortcodes; inject `"><script>alert(1)</script>` into attribute parameters.
- **Evidence:** [source] NVD confirms the flaw affects versions up to 2.5.8.1. · [opinion] A reliable pivot for privilege escalation in environments where user registration is enabled.

---

## 2026-04-20

### EMC Calendly Plugin Stored XSS via Shortcode — `CVE-2026-0868`
- **Tags:** `#xss` `#web`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-0868)

- **What:** Authenticated contributors can inject malicious scripts via the `calendly` shortcode attributes due to insufficient input sanitization.
- **Why it matters:** Allows lower-privileged users to hijack administrator sessions or perform actions on their behalf upon viewing the page.
- **Hunt signal:** Audit `emc-easily-embed-calendly` for `add_shortcode` and test HTML attribute injection in shortcode parameters.
- **Evidence:** [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-0868) confirms the vulnerability affects all versions up to and including 4.4 via user-supplied attributes.

---
