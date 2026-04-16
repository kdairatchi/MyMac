# deserialization-techniques


## 2026-04-16

### Analysis of CVE-2023-3519 in Citrix ADC and NetScaler Gateway — `CVE-2023-3519`
- **Tags:** `#deserialization` `#appliance`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 27.0 · **Status:** poc · **Age:** 30d
- **Sources:** [1](https://www.assetnote.io/resources/research/analysis-of-cve-2023-3519-in-citrix-adc-and-netscaler-gateway) · [2](https://www.assetnote.io/resources/research/finding-and-exploiting-citrix-netscaler-buffer-overflow-cve-2023-3519-part-3) · [3](https://www.assetnote.io/resources/research/analysis-of-cve-2023-3519-in-citrix-adc-and-netscaler-gateway-part-2)

### Analysis of CVE-2023-3519 in Citrix ADC and NetScaler Gateway

- **Insights:**
  - Unauthenticated deserialization in NetScaler XML API triggers arbitrary command execution
  - Exploitable via crafted HTTP requests to NSCIService or AAA ports
  - Results in full system compromise with persistence capabilities
  - Affects ADC 13.1-13.1-49.16 and NetScaler Gateway 13.1-13.1-49.16
  - Chaining potential with network-level protocol abuses
- **Practical Takeaways:**
  - Immediately patch Citrix Security Bulletin CTX2023-3519 (fixed versions 13.1-49.18+)
  - Implement network segmentation to isolate management interfaces from untrusted networks

---
*Clustered 3 sources for this item.*
