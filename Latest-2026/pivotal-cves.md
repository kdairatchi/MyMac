# pivotal-cves


## 2026-07-07

### Pivotal CRM Deserialization RCE via Incomplete Fix (CVE-2026-51947) — `CVE-2026-51947`
- **Tags:** `#deserialization` `#rce`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 36.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-51947)

- **What:** Incomplete fix for CVE-2026-39253 in Pivotal CRM 6.6.4.08 allows remote attackers to execute arbitrary code via unsafe deserialization in Pivotal.Engine.Client.Services.Conversion.dll.
- **Why it matters:** Orgs that applied the first patch (patch-ghi-15381-cwe-502-20251225.zip) but not the second fix remain fully exposed to unauth RCE — they likely believe they're already remediated.
- **Hunt signal:** Fingerprint Pivotal CRM instances running 6.6.4.08 with only the initial CWE-502 patch; probe Conversion.dll deserialization entry points with type-aware gadgets from the original CVE-2026-39253 exploit chain.
- **Evidence:** [source] NVD confirms CWE-502 deserialization leading to RCE, explicitly noting incomplete fix for CVE-2026-39253 · [opinion] Classic patch-bypass scenario makes this high-value — defenders often stop at the first patch and assume remediation is complete.

---
