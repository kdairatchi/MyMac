# shopware-cves


## 2026-08-30

### Open Redirect via Referer Fallback in Shopware SSO Entry Point — `CVE-2026-48012`
- **Tags:** `#auth-bypass` `#web` `#api` `#oauth`
- **Severity:** medium · **Hunt:** 3/5 · **Score:** 22.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-48012)

- **What:** Unauthenticated open redirect at `GET /api/oauth/sso/auth` where the app falls back to the request's `Referer` header as the redirect target when no SSO session state exists, with no same-origin restriction, no relative-path requirement, and no scheme filtering — `javascript:` URLs are reflected into both the `Location` header and an HTML meta-refresh/body link.
- **Why it matters:** The `/api/oauth/` origin gives the redirect a trustworthy application-controlled authority, making it a strong phishing and OAuth/SSO abuse primitive; the `javascript:` reflection in the HTML body also pushes this beyond a standard open redirect into XSS territory.
- **Hunt signal:** `curl -sI -H "Referer: https://evil.example" "https://target/api/oauth/sso/auth" | grep -i "^location"` — any 302 reflecting the Referer value confirms the class of bug; also test `Referer: javascript:alert(1)` for scheme-less reflection.
- **Evidence:** [NVD] Unauthenticated redirect to attacker.example/poc and reflection of `javascript:alert(1)` into Location + HTML body confirmed in validated PoC · [opinion] The Referer-fallback-to-redirect pattern is a recurring class bug in SSO/OAuth entrypoints — audit other platforms for similar stateless redirect fallbacks, especially where session state is missing or malformed.

---
### Shopware linkURL SSRF — authenticated admin HEAD requests to internal IPs — `CVE-2026-48013`
- **Tags:** `#ssrf` `#api` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-48013)

- **What:** The `/api/_action/media/external-link` endpoint in Shopware <6.6.10.18 / <6.7.10.1 accepts an admin-provided URL and issues a server-side HTTP HEAD request without validating the target against private/reserved IP ranges, unlike the parallel `uploadFromURL` flow which uses `FileUrlValidator`.
- **Why it matters:** Authenticated admins can reach internal network services and cloud metadata endpoints (e.g., AWS IMDSv1 at 169.254.169.254), enabling cloud credential theft and internal service enumeration — a high-impact chain pivot despite the admin auth requirement.
- **Hunt signal:** POST `/api/_action/media/external-link` with `url: http://169.254.169.254/latest/meta-data/iam/security-credentials/` as an authenticated admin; observe response timing/error differences vs external URLs.
- **Evidence:** [source] NVD entry confirms missing IP validation on `linkURL` flow while `uploadFromURL` is properly restricted · [opinion] Solid chain candidate if you can obtain admin creds or chain from a lower-privilege flaw to admin; otherwise limited by the auth gate.

---
