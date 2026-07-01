# checkpoint-cves


## 2026-07-01

### Check Point VPN IKEv1 Auth Bypass (CVE-2026-50751) — `CVE-2026-50751`
- **Tags:** `#auth-bypass` `#appliance`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/marking-your-own-homework-check-point-remote-access-vpn-ikev1-authentication-bypass-cve-2026-50751/)

- **What:** IKEv1 authentication bypass in Check Point Remote Access VPN allows unauthenticated attackers to circumvent VPN authentication entirely.
- **Why it matters:** Perimeter VPN appliances are internet-exposed by design; an auth bypass on the front door effectively grants network access without credentials, turning the security gateway into the intrusion vector.
- **Hunt signal:** Probe IKEv1 endpoints on Check Point VPN gateways for handshake responses that indicate bypass — look for successful SA negotiation without valid credentials.
- **Evidence:** [watchtowr_labs] Detailed writeup with PoC demonstrating IKEv1 auth bypass · [opinion] Classic "marking your own homework" pattern where the VPN validates its own auth in a flawed way — high-value target given Check Point's enterprise deployment footprint.

---
