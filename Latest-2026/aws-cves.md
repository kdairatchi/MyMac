# aws-cves


## 2026-07-01

### OS Command Injection in aws-cdk-lib NodejsFunction Docker bundling — `CVE-2026-13760`
- **Tags:** `#command-injection` `#supply-chain` `#docker` `#npm`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-13760)

- **What:** Shell metacharacters in dependency version strings within a project's package.json are passed unsanitized to the OsCommand helper during Docker-based bundling, enabling arbitrary command execution on the host running the CDK toolchain.
- **Why it matters:** An attacker who can influence a package.json (via malicious PR, dependency confusion, or typosquatting) achieves RCE on the CI/CD host — a powerful supply-chain pivot from dependency manipulation to build-system compromise.
- **Hunt signal:** Look for CDK projects where package.json dependency versions come from untrusted sources (e.g., user-supplied config, fork-based PRs); probe with version strings containing `$(cmd)` or backtick payloads in nodeModules bundling paths.
- **Evidence:** [source] CVE-2026-13760 describes OsCommand helper passing version strings to shell without sanitization · [opinion] Patched in v2.260.0 so exposed targets must be unpatched, but the attack vector through dependency version control makes this an excellent chain candidate alongside supply-chain and repo-confusion scenarios.

---
