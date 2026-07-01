# tenda-cves


## 2026-07-01

### Tenda AC18 Unauth Command Injection via fast_setting_internet_set — `CVE-2026-38142`
- **Tags:** `#command-injection` `#rce` `#appliance`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-38142)

- **What:** Unauthenticated attackers can inject arbitrary OS commands through the `mac` parameter on the `/goform/fast_setting_internet_set` endpoint in Tenda AC18 v15.03.05.05.
- **Why it matters:** Full unauthenticated RCE on a widely-deployed consumer router — no auth, no chain needed, single POST request.
- **Hunt signal:** `POST /goform/fast_setting_internet_set` with `mac=;id` or backtick-wrapped commands; look for root-level command output in the response or blind via DNS callback.
- **Evidence:** [source] NVD entry confirms unauth command injection via crafted mac parameter · [opinion] trivially exploitable — Tenda /goform endpoints are well-known for missing auth checks and input validation.

---
