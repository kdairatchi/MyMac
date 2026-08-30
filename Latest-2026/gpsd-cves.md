# gpsd-cves


## 2026-08-30

### gpsd gpsprof gnuplot heredoc injection → RCE — `CVE-2026-60122`
- **Tags:** `#rce` `#command-injection`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-60122)

- **What:** The gpsprof utility in gpsd ≤ 3.27.5 inserts unsanitized SKY.satellites[].used values into a gnuplot heredoc data block; an attacker controlling GPS input can inject "EOD" to terminate the heredoc early and append gnuplot system() calls for OS command execution.
- **Why it matters:** Achieves RCE as the user running gpsprof, but requires the attacker to control GPS input data AND gpsprof must process it in polar mode with gnuplot — a narrow but real attack surface in environments that ingest untrusted GPS streams.
- **Hunt signal:** pass — patched and niche trigger conditions; no broad hunt surface.
- **Evidence:** [NVD] Describes heredoc-escape → system() injection path; fixed in commit 4c06658. · [Opinion] Clever heredoc escape technique worth remembering for other gnuplot/script-generation contexts, but low practical hunt value as-is.

---
