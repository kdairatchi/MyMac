# Microsoft CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-07-06 · Items: 2_

---

## What


---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2026-21709 | 2026-04-19 | Windows Driver Signature Enforcement Bypass | medium | unknown | [src](https://nvd.nist.gov/vuln/detail/CVE-2026-21709) |
| CVE-2026-58289 | 2026-07-06 | Microsoft Edge V8 Type Confusion RCE | 9.0 critical | unpatched-in-wild | [src](https://x.com/CVEnew/status/2073269630244921708) |

---

## Probes


---

## PoCs


- **CVE-2026-21709** — [source](https://nvd.nist.gov/vuln/detail/CVE-2026-21709)
- **CVE-2026-58289** — no public PoC confirmed as of 2026-07-06

---

## Reproduction


---

## Defense


---

## References

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-21709)
- [CVEnew/Twitter — CVE-2026-58289](https://x.com/CVEnew/status/2073269630244921708)
- [sherlockforensics analysis](https://www.sherlockforensics.com/blog/2026-07-03-cve-2026-58289.html)

---

## Items

## 2026-07-06

### Microsoft Edge V8 Type Confusion RCE — `CVE-2026-58289`

- **Tags:** `#rce` `#browser` `#type-confusion` `#v8` `#chromium`
- **Severity:** critical · **CVSS:** 9.0 · **Hunt:** 3/5 · **Status:** patch-available · **KEV:** no
- **Sources:** [1](https://x.com/CVEnew/status/2073269630244921708) [2](https://www.sherlockforensics.com/blog/2026-07-03-cve-2026-58289.html)

- **What:** Type confusion in V8 JavaScript engine (Microsoft Edge Chromium-based, <150.0.4078.48) allows unauthenticated network attacker to execute code — attacker serves a crafted webpage, no interaction beyond the page visit required.
- **Why it matters:** CVSS 9.0, no auth, no interaction — "browse and owned." Stored XSS on any high-traffic target becomes a platform for this chain while patch saturation is low. In scope for Microsoft MSRC and Google/Chromium Security Rewards programs; Electron-based dev tools share the same engine.
- **Hunt signal:** `curl -si https://target/ | grep -i content-security-policy` — weak/absent CSP on stored-XSS endpoints amplifies this class. Check Electron app version: `cat node_modules/electron/package.json | grep '"version"'` vs patched Chromium baseline.
- **Evidence:** [CVEnew](https://x.com/CVEnew/status/2073269630244921708) · [Sherlock Forensics](https://www.sherlockforensics.com/blog/2026-07-03-cve-2026-58289.html) · [Windows News](https://windowsnews.ai/article/update-microsoft-edge-immediately-to-patch-critical-remote-code-execution-bug.434446)

---

## 2026-04-19

### Windows Driver Signature Enforcement Bypass — `CVE-2026-21709`
- **Tags:** `#privesc` `#auth-bypass`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-21709)

- **What:** A local administrator can bypass Windows Driver Signature Enforcement (DSE) to load unsigned drivers.
- **Why it matters:** Enables attackers to load malicious kernel-mode code (rootkits/BYOVD) for persistence or defense evasion after gaining admin access.
- **Hunt signal:** pass
- **Evidence:** [source] NVD listing confirms the bypass capability. [opinion] Critical for post-exploitation phases but limited by the requirement for existing admin privileges.

---
