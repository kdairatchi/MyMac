# misc-cves


## 2026-05-17 — CVE-2026-42945

### CVE-2026-42945 — NGINX Rift: 18-Year-Old Flaw Actively Exploited [unverified]

- **Date:** 2026-05-17 · **Source:** [medium.com](https://medium.com/@saikiran9459/nginx-rift-cve-2026-42945-is-now-being-exploited-an-18-year-old-flaw-in-the-worlds-most-deployed-5005b5534721) · **Class:** cve
- **Severity:** unknown (no NVD entry at time of writing) · **Hunt:** hold · **Status:** claimed active exploitation, unverified
- **Tags:** `#nginx` `#web-server` `#unverified`

- **What:** Medium blog claims CVE-2026-42945 is an 18-year-old bug in NGINX now being actively exploited. No NVD entry, no PortSwigger/watchTowr corroboration in today's feeds.
- **Why it matters:** [inference] NGINX is the most-deployed web server globally — if real, this is extremely high-value. But Medium-only claims without an official advisory are often inaccurate or embellished. Track, don't act.
- **Hunt signal:** hold — monitor nginx.org/en/security_advisories.html and PortSwigger/watchTowr for corroboration. If confirmed, every nginx-fronted web app in scope becomes a target.
- **Evidence:** [source] https://medium.com/@saikiran9459/nginx-rift-cve-2026-42945 [title-only, unverified — check NVD before acting]

---

## 2026-04-23

### Firefox 150 — Seven High/Critical CVEs (CVE-2026-6748, -6750, -6760, -6761, -6768, -6769, -6771)

- **Date:** 2026-04-21 · **Source:** [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-6748) · **Class:** cve
- **Severity:** CRITICAL (9.8 × 5, 8.8 × 2) · **Hunt:** 2/5 · **Status:** patched (Firefox 150 / ESR 140.10)
- **Tags:** `#browser` `#firefox` `#gecko` `#electron`

- **What:** Mozilla patched seven CVEs in Firefox 150 / ESR 140.10 / Thunderbird 150 on 2026-04-21 — uninitialized memory in WebCodecs, privilege escalation in WebRender+Networking+Debugger, and three mitigation bypasses in Networking:Cookies and DOM:Security.
- **Why it matters:** For bug bounty: check Electron apps shipping outdated Chromium/Gecko; for variant hunting, the cookie mitigation bypass pattern (CVE-2026-6760/6768) may recur in Gecko-derived libs outside browser context. [opinion] Low direct bounty surface — most programs don't ship Gecko. Worth checking Electron targets for outdated Firefox ESR embeds.
- **Hunt signal:** `grep -ri "gecko\|firefox\|electron" package.json` on targets; `nuclei -t technologies/electron.yaml` on Electron apps; check `navigator.userAgent` for old Firefox/ESR versions in web targets. Pass for pure web apps.
- **Evidence:** [source] NVD published 2026-04-21 · [source] Mozilla security advisory mfsa2026-xx

| CVE | Score | Description |
|---|---|---|
| CVE-2026-6748 | 9.8 CRITICAL | Uninitialized memory in Audio/Video: Web Codecs |
| CVE-2026-6750 | 9.8 CRITICAL | Privilege escalation in Graphics: WebRender |
| CVE-2026-6760 | 9.8 CRITICAL | Mitigation bypass in Networking: Cookies |
| CVE-2026-6768 | 9.8 CRITICAL | Mitigation bypass in Networking: Cookies |
| CVE-2026-6771 | 9.8 CRITICAL | Mitigation bypass in DOM: Security |
| CVE-2026-6761 | 8.8 HIGH | Privilege escalation in Networking |
| CVE-2026-6769 | 8.8 HIGH | Privilege escalation in Debugger |

---

## 2026-04-20

### Auto Update 2026/04/20 00:50:21
- **Tags:** `#web`
- **Severity:** unknown · **Hunt:** 1/5 · **Score:** 4.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://github.com/nomi-sec/PoC-in-GitHub/commit/7e5e0d66440d0de3bb21776eacc191ad35da61d5) · [2](https://github.com/nomi-sec/PoC-in-GitHub/commit/4ff8a4fa9b7e06c186089bf6626279a2333184b3) · [3](https://github.com/trickest/cve/commit/53db6e956a7fb9cddc69014f419f43a91e27e6e8) · [4](https://github.com/trickest/cve/commit/7ebbf3d8590db6e2c0afb51257985d8f09d428db) · [5](https://github.com/projectdiscovery/nuclei-templates/commit/fdd6bad7719cb0179997031b31eb0d5659e1f1b3)

- **What:** Automated repository metadata update log entry without specific vulnerability details.
- **Why it matters:** This is a procedural commit message containing no actionable CVE intelligence or exploit data.
- **Hunt signal:** pass
- **Evidence:** [source] https://github.com/nomi-sec/PoC-in-GitHub/commit/7e5e0d66440d0de3bb21776eacc191ad35da61d5

---
*Clustered 8 sources for this item.*


## 2026-07-01

### PoC-in-GitHub Auto Update 2026/06/30
- **Tags:** `#web`
- **Severity:** unknown · **Hunt:** 1/5 · **Score:** 6.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://github.com/nomi-sec/PoC-in-GitHub/commit/09eaa5539fe5d7dfa9ac5ab0bff8284f556d31b4) · [2](https://github.com/nomi-sec/PoC-in-GitHub/commit/a2edb85f07b975d45fa19caec36a73d301c4401d) · [3](https://github.com/nomi-sec/PoC-in-GitHub/commit/a40903d2d0b28f691cfe7f156c5c2b9c1bbb3bf3) · [4](https://github.com/nomi-sec/PoC-in-GitHub/commit/a8f2d7107c739e988386bee5b6ebba9b4f3a4665) · [5](https://github.com/nomi-sec/PoC-in-GitHub/commit/ffa1b608891d18fbdacd507a1560aac363d1f558)

- **What:** Automated commit to the PoC-in-GitHub repository adding new proof-of-concept exploits; no specific CVE details provided in the payload.
- **Why it matters:** Signals that one or more CVE PoCs were freshly indexed; worth checking the commit diff to identify which CVEs gained public exploits.
- **Hunt signal:** Inspect the commit diff for newly added CVE directories, then cross-reference against your target scope for fresh exploitability.
- **Evidence:** [source] Auto-update commit from nomi-sec/PoC-in-GitHub tracker · [opinion] Low signal without diff context — prioritize reviewing the actual CVE entries added.

---
*Clustered 19 sources for this item.*
