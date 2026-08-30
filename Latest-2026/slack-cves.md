# slack-cves


## 2026-08-30

### Nebula-mesh SSTI via ListenHost/TunDevice in config generator — `CVE-2026-47722`
- **Tags:** `#ssti` `#web` `#api`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-47722)

- **What:** Operator-supplied `ListenHost` and `TunDevice` fields are interpolated raw into a Go `text/template` that generates the agent's `config.yml`, with only `strings.TrimSpace` for validation.
- **Why it matters:** An authenticated operator can inject Go template directives to manipulate every agent's generated config, potentially achieving config injection or leveraging Go template primitives for data exfiltration across the mesh.
- **Hunt signal:** Pass — patched in 0.3.2 and requires operator-level access.
- **Evidence:** [source] NVD CVE-2026-47722 details unvalidated interpolation at `generator.go:86,108,119` and `advanced.go:20-35` · [opinion] Authenticated SSTI in a control-plane config generator is a meaningful trust-boundary violation but limited by operator prerequisites.

---
