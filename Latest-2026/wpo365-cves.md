# wpo365-cves


## 2026-08-30

### WPO365 WordPress Plugin CSRF Allows Arbitrary Option Overwrite to Admin — `CVE-2026-15212`
- **Tags:** `#csrf` `#auth-bypass` `#web`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-15212)

- **What:** The WPO365 | Login WordPress plugin defaults to skipping nonce verification (enable_nonce_check absent from default options), allowing unauthenticated CSRF that overwrites arbitrary plugin options including role escalation to administrator.
- **Why it matters:** A single link-click by an admin lets an attacker enable the SCIM REST endpoint, plant a known scim_secret_token, and set new_usr_default_role to administrator — achieving full site takeover without any credentials.
- **Hunt signal:** Enumerate WordPress sites running WPO365, craft a CSRF page POSTing to wp_ajax_wpo365_update_settings with base64/JSON settings payload setting enable_scim=true, scim_secret_token=<attacker-known>, new_usr_default_role=administrator; no valid nonce required.
- **Evidence:** [source] NVD entry documents the missing enable_nonce_check default and unrestricted Options_Service::update_options() key merge · [opinion] High-impact CSRF with a fully detailed exploitation path; excellent chain candidate for WordPress bug bounty targets where admin interaction is feasible

---
