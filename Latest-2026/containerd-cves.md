# containerd-cves


## 2026-07-01

### containerd OOM Kill via Malicious Container Image — `CVE-2026-47262`
- **Tags:** `#kubernetes` `#docker` `#cloud`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 8.83 · **Status:** patched · **Age:** 7d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-47262)

- **What:** A maliciously crafted container image triggers memory exhaustion in containerd, causing an OOM kill that crashes the runtime and its API
- **Why it matters:** Disrupts the container runtime API for all clients including Docker Engine and Kubernetes control-plane components, enabling cluster-wide DoS from a single image pull
- **Hunt signal:** Identify clusters running unpatched containerd (< 1.7.33, 2.0.10, 2.1.9, 2.2.5, 2.3.2) that permit untrusted image registries; probe containerd version via leaked metrics or API error messages
- **Evidence:** [NVD] DoS via crafted image memory exhaustion · [opinion] high blast radius on multi-tenant K8s clusters but requires ability to push/pull a malicious image, lowering unauth exploitability

---
