# redhat-cves


## 2026-08-30

### Unauth OOM crash in RHCS via repeated TLS requests — `CVE-2026-12353`
- **Tags:** `#web` `#appliance`
- **Severity:** medium · **Hunt:** 3/5 · **Score:** 15.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-12353)

- **What:** An unauthenticated attacker can repeatedly send HTTP requests to the TLS endpoint of Red Hat Certificate System to trigger an Out of Memory condition, crashing the Java process.
- **Why it matters:** Unauthenticated denial-of-service requiring manual restart — low barrier to exploit, no credentials needed, and can take a certificate authority offline in enterprise environments.
- **Hunt signal:** Send high-volume concurrent requests to RHCS TLS endpoints and monitor for process crash/OOM; look for RHCS instances on standard ports (8080/8443) with `server=` or `pki-` indicators.
- **Evidence:** [source] NVD entry describes unauth OOM via repeated HTTP to TLS endpoint · [opinion] straightforward DoS but could chain with HA failover or race windows during restart

---
