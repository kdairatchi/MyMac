# Leaflet CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-16 · Items: 1_

---

## What


---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2025-69993 | 2026-04-16 | Leaflet <= 1.9.4 XSS via bindPopup() | high | poc | [src](https://nvd.nist.gov/vuln/detail/CVE-2025-69993) |

---

## Probes


---

## PoCs


- **CVE-2025-69993** — [source](https://nvd.nist.gov/vuln/detail/CVE-2025-69993)

---

## Reproduction


---

## Defense


---

## References

- [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2025-69993)

---

## Items

## 2026-04-16

### Leaflet <= 1.9.4 XSS via bindPopup() — `CVE-2025-69993`

- **Tags:** `#xss` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 42.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2025-69993)

- **What:** The `bindPopup()` method in Leaflet renders user-supplied input as raw HTML without sanitization, allowing arbitrary JavaScript injection.
- **Why it matters:** Attackers can execute malicious scripts in the context of a victim's session by injecting payloads into map popups, leading to account takeover or data exfiltration.
- **Hunt signal:** Test map features with payload `<img src=x onerror=alert(1)>` inside popup content parameters.
- **Evidence:** [NVD](https://nvd.nist.gov/vuln/detail/CVE-2025-69993) confirms the vulnerability exists in versions up to 1.9.4 due to lack of output encoding.

---
