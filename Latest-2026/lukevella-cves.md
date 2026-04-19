# lukevella-cves


## 2026-04-19

### Rallly Reset Password RedirectTo XSS — `CVE-2026-6493`
- **Tags:** `#xss` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-6493)

- **What:** Reflected XSS via the `redirectTo` parameter in the Rallly reset password form.
- **Why it matters:** Allows attackers to steal password reset tokens or user sessions during the auth recovery flow.
- **Hunt signal:** Check `reset-password` endpoints for `redirectTo` params reflected unsanitized in the DOM.
- **Evidence:** [source] NVD disclosure confirms XSS in `reset-password-form.tsx` ... · [opinion] Auth flow XSS is a high-value target for account takeover.

---
