# protobufjs-cves


## 2026-04-20

### CVE-2026-41242 protobufjs code injection — `CVE-2026-41242`
- **Tags:** `#rce` `#deserialization` `#web`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-41242)

- **What:** Remote code injection through arbitrary code execution in protobufjs's type fields during object decoding.
- **Why it matters:** Allows attackers to execute arbitrary code in applications using vulnerable protobufjs versions.
- **Hunt signal:** Applications using protobufjs versions prior to 8.0.1 and 7.5.5.
- **Evidence:** [source] NVD ... · [opinion] Critical vulnerability in widely used JS library with straightforward exploitation.

---
