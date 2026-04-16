# trezor-cves


## 2026-04-16

### Side-channel vulnerability in Trezor hardware wallets — `CVE-2025-69893`
- **Tags:** `#auth-bypass` `#physical-access` `#data-exfil` `#hardware` `#wallet`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 10.5 · **Status:** poc · **Age:** 30d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2025-69893)

### CVE-2025-69893 — auth-bypass, physical-access, data-exfil
- **What:** Side-channel vulnerability in Trezor hardware wallets allowing mnemonic recovery via physical access during setup.
- **Why it matters:** Attackers can steal cryptocurrency assets by recovering mnemonic codes through DL-SCA.
- **Hunt signal:** Monitor for side-channel attacks during device initialization sequences.
- **Evidence:** [NVD] ... · [opinion] High-risk physical attack vector against critical infrastructure.

---
