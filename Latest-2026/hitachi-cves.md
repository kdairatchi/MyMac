# hitachi-cves


## 2026-07-01

### Improper Authorization in Hitachi VSP Maintenance Utility — `CVE-2025-2902`
- **Tags:** `#auth-bypass` `#appliance`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2025-2902)

- **What:** Improper authorization in the maintenance utility of Hitachi Virtual Storage Platform allows unauthorized access to maintenance functions across multiple VSP hardware generations (E-series, 5000-series, G/F-series).
- **Why it matters:** Maintenance utilities on storage arrays typically expose powerful diagnostic and configuration capabilities; unauthorized access could lead to data integrity or availability impact on enterprise storage.
- **Hunt signal:** Check exposed Hitachi VSP management interfaces for maintenance utility endpoints accessible without proper auth; look for DKCMAIN/GUM versions below patched thresholds.
- **Evidence:** [source] NVD entry with patched firmware versions specified per model line · [opinion] Patched and appliance-scoped — limited bug bounty surface unless target runs unpatched firmware with exposed management.

---
### Hitachi VSP One Block Firmware Update Validation Bypass — `CVE-2025-0824`
- **Tags:** `#rce` `#appliance`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2025-0824)

- **What:** Lack of validation for firmware updates in Hitachi Virtual Storage Platform One Block allows uploading malicious firmware.
- **Why it matters:** An attacker with access to the management interface could compromise the storage appliance by supplying a crafted firmware image.
- **Hunt signal:** pass
- **Evidence:** [NVD] Lack of validation for firmware update in Hitachi VSP One Block before DKCMAIN A3-04-21-40/00 · [opinion] Patched appliance vulnerability, limited external hunt value.

---
