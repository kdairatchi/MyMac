# giskard-cves


## 2026-04-19

### CVE-2026-40320 - Giskard Jinja2 RCE — `CVE-2026-40320`
- **Tags:** `#ssti` `#rce` `#ai`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-40320)

- **What:** Jinja2 template injection in ConformityCheck class allowing arbitrary code execution
- **Why it matters:** Allows RCE if attackers can control check definitions
- **Hunt signal:** Search for rule parameters containing Jinja2 expressions in test definitions
- **Evidence:** [source] NVD ... · [opinion] Chain with file upload flaws in giskard environments

---
### Giskard Regex Catastrophic Backtracking DoS — `CVE-2026-40319`
- **Tags:** `#llm` `#api`
- **Severity:** low · **Hunt:** 2/5 · **Score:** 6.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-40319)

- **What:** User-supplied regex patterns in the RegexMatching check trigger catastrophic backtracking.
- **Why it matters:** Users with check write access can cause indefinite hangs, halting the AI testing pipeline.
- **Hunt signal:** pass (requires internal write access to check definitions)
- **Evidence:** [source] NVD details lack of timeout guards on re.search() leading to DoS.

---
