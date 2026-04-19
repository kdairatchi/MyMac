# Supply Chain

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: — · Items: 5_

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2024-3094 | — | Maintainer compromise / account takeover | — | — | — |

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

_No PoCs in items yet._

---

## Reproduction

_Step-by-step repro steps per CVE. Populated as items arrive with enough detail._
_pending enrichment_

---

## Defense

_Patch guidance and detection rules. Populated from vendor advisories._
_pending enrichment_

---

## References

_Populated by daily refresh-latest pipeline._

---

## Items

> Dated: **2026-04-15**

Post-SolarWinds, post-XZ, supply chain is no longer exotic. In 2025-2026 the attacker economy normalized around:

## Attack classes

### Typosquatting + Slopsquatting

- **Slopsquatting** (Lasso Security, Mar 2025) — LLMs hallucinate package names; attacker registers them. Confirmed hits on `langchain`, `llama-index`, `openai-python` near-misses.
- Standard typos: `reqeusts`, `urllib` (real but abandoned), `python-dateutil` vs `dateutil`

### Maintainer compromise / account takeover

- **XZ backdoor (CVE-2024-3094)** — still the playbook. Long-term social engineering → maintainer status → backdoor.
- **npm token leaks** from public CI logs — scan commits with gitleaks/trufflehog.

### Lockfile injection

- Attacker controls one transitive dep, pins a malicious version in lockfile
- `package-lock.json` and `yarn.lock` integrity hashes are last line

### Manifest confusion

- npm (Darcy Clarke research) — `package.json` vs tarball contents differ; registry trusts manifest
- PyPI wheel confusion — name in METADATA vs filename

### Build system abuse

- **GitHub Actions pwn requests** — `pull_request_target` + checkout of PR code → token leak
- **npm install scripts** — `postinstall` hook, classic
- **PyPI attestations** — adoption slow, most packages unsigned

## 2025-2026 notable incidents

- **`@solana/web3.js`** — Dec 2024 npm account compromise, credential theft via malicious version
- **`tj-actions/changed-files`** — Mar 2025 GitHub Action compromise, >23k repos leaked secrets to workflow logs
- **`ultralytics`** (Dec 2024) — compromised build, XMRig crypto miner shipped to users
- **`rspack`** — Dec 2024 npm, crypto stealer injection
- **PyPI `fabrice`** — Oct 2024, AWS credential theft (typosquat of `fabric`)
- **VS Code extension marketplace** — recurring issue, ongoing

## Defenses

- **Pin exact versions**, no `^` or `~`
- **Lockfile in CI** — fail if lockfile changes without PR review
- **npm:** `npm install --ignore-scripts` by default in CI
- **pip:** use `--require-hashes` + `pip-audit`
- **Socket.dev / Snyk / Semgrep Supply Chain** — automated monitoring
- **SBOM** — CycloneDX or SPDX; required by US EO 14028 downstream
- **Sigstore** — cosign sign artifacts; sigstore-python for PyPI

## Hunting for bounties

- Check scope — many programs now explicitly include dependency confusion
- **Dependency confusion** (Birsan 2021, still valid in 2025) — leaked internal pkg names in JS bundles → register on public registry
- **GitHub Actions injection** in bug bounty-in-scope workflows
- Look for `ghcr.io/<org>/...` private images referenced in public configs

## Tooling

- **trufflehog** — secrets scanning incl. git history
- **gitleaks** — similar, fast
- **pypi-confusion** / **npm-confusion** scanners
- **dep-scan** (OWASP) — SBOM + vuln
- **guarddog** (DataDog) — PyPI/npm malicious package heuristics
- **Socket.dev CLI**

---

*Evidence:* incident names/CVEs verified pre-Apr 2026. Defense recommendations are stable; incident timeline rots — confirm with NVD or vendor advisory before reporting.
