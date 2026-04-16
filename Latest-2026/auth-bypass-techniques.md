# auth-bypass-techniques


## 2026-04-16

### The Fragile Lock: Novel Bypasses For SAML Authentication
- **Tags:** `#auth-bypass` `#web`
- **Severity:** critical · **Hunt:** 5/5 · **Score:** 67.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/the-fragile-lock)

- Exploits parser-level inconsistencies in the Ruby and PHP SAML ecosystems to achieve full authentication bypass.
- Leverages attribute pollution techniques where duplicate or conflicting attributes confuse validation logic while remaining valid XML.
- Utilizes namespace confusion to inject malicious data that the parser processes but security controls fail to detect.
- Demonstrates that differing interpretations of the SAML standard across libraries create exploitable gaps in trust boundaries.

**Practical Takeaways:**
- When auditing SAML implementations, specifically test for attribute pollution by injecting duplicate attributes with different values or namespaces.
- Verify how the application handles SAML responses with ambiguous or conflicting namespace definitions to detect parser inconsistencies.

---
### SAML roulette: chaining attacks for GitLab access
- **Tags:** `#auth-bypass` `#rails`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://portswigger.net/research/saml-roulette-the-hacker-always-wins)

- **Insight**: Combines "round-trip" attacks (manipulating SAML responses during the flow) with XML namespace confusion to bypass security controls.
- **Insight**: Targets the `ruby-saml` library, specifically how it processes XML signatures and namespaces within SAML assertions.
- **Insight**: Achieves unauthenticated administrative access on GitLab Enterprise by tricking the Service Provider (SP) into accepting a maliciously crafted assertion.
- **Insight**: Highlights the risk of complex XML parsing logic in SAML libraries, where namespace prefixes can be spoofed to bypass signature validation.
- **Takeaway**: Audit SAML implementations for namespace confusion by checking if the library correctly verifies canonicalization methods and handles namespace prefixes.
- **Takeaway**: Test SAML flows for "round-trip" vulnerabilities where a response intended for the IdP can be intercepted, modified, and replayed to the SP.

---
### Nginx/Apache Path Confusion to Auth Bypass in PAN-OS (CVE-2025-0108) — `CVE-2025-0108`
- **Tags:** `#auth-bypass` `#web`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 21.0 · **Status:** poc · **Age:** 30d
- **Sources:** [1](https://www.assetnote.io/resources/research/nginx-apache-path-confusion-to-auth-bypass-in-pan-os)

- **What:** Exploits path handling discrepancies between PAN-OS web server and reverse proxies (Nginx/Apache) to bypass authentication.
- **Why it matters:** Allows unauthenticated access to protected resources in high-security appliances, potentially compromising entire network segments.
- **Hunt signal:** Unusual path segment combinations in proxy requests (e.g., double-encoded slashes, mix-case paths)
- **Evidence:** [source] https://www.assetnote.io/resources/research/nginx-apache-path-confusion-to-auth-bypass-in-pan-os · [opinion] Critical due to PAN-OS' role as security perimeter device.

- **Insights:**  
  - PAN-OS path parsing diverges from Nginx/Apache when handling URL normalization and character encoding.  
  - Attackers craft requests with crafted paths that bypass reverse proxy checks but exploit PAN-OS' permissive path resolution.  
  - Affects both direct and reverse-proxy deployment modes.  
  - Demonstrates configuration-dependent mismatches in web server path resolution.  

- **Takeaways:**  
  - Implement path normalization consistency between proxy servers and security appliances.  
  - Audit access logs for path manipulation attempts using regex patterns like `%2f|%2F|%2F%2F`.

---
