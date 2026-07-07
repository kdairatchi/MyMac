# adobe-cves


## 2026-07-07

### Adobe ColdFusion APSB26-68 CVE Bonanza
- **Tags:** `#rce` `#web` `#appliance`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/its-37oc-and-all-we-can-think-about-is-coldfusion-adobe-coldfusion-security-bulletin-apsb26-68-cve-bonanza/)

- **What:** Multiple vulnerabilities patched in Adobe ColdFusion via APSB26-68, analyzed by watchtowr labs.
- **Why it matters:** ColdFusion has a consistent track record of critical unauth RCE bugs; this bulletin fixes several, with hints that some issues weren't fully disclosed by Adobe.
- **Hunt signal:** Scan for unpatched ColdFusion instances exposing /CFIDE/ endpoints; test for deserialization/RCE chains on internet-facing hosts still running pre-patch versions.
- **Evidence:** [source] watchtowr labs analysis of APSB26-68 · [opinion] "bonanza" phrasing and mention of unreported vulns suggests impact beyond Adobe's bulletin — prioritize patch verification and watch for follow-up PoCs.

---
