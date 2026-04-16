# Cloud Native — K8s, Containers, eBPF — 2025/2026

> Dated: **2026-04-15**

## Kubernetes

### Pay classes in 2025-2026

| Class | Example |
|---|---|
| Dashboard / API server exposure | Kubelet :10250 open, kube-apiserver anon allowed |
| RBAC misconfig | ServiceAccount bound to `cluster-admin` unnecessarily |
| Pod escape | `privileged: true`, `hostPID`, `hostNetwork`, hostPath mounts |
| Admission bypass | PSA/PSP gaps, OPA Gatekeeper misconfig |
| Secret leak | Secrets as envvars in manifests pushed to public repos |
| Sidecar / init abuse | Shared PID, capability bleed |

### Notable CVEs

- **CVE-2025-1974** — ingress-nginx RCE ("IngressNightmare", Wiz, Mar 2025). Admission controller exposure → cluster takeover. Patched 1.12.1 / 1.11.5.
- **CVE-2024-10220** — Kubernetes gitRepo volume cmd injection
- **CVE-2024-9486 / 9594** — Image Builder default creds

### Recon

```bash
# Kubelet API
curl -k https://target:10250/pods  # anon access
curl -k https://target:10250/runningpods

# API server
kubectl --insecure-skip-tls-verify get --raw /api/v1/namespaces/default/pods

# Metadata endpoints (from inside pod)
curl http://169.254.169.254/latest/meta-data/  # AWS
curl -H "Metadata-Flavor: Google" http://metadata.google.internal/  # GCP
```

### Tools

- **kubeaudit**, **kube-hunter**, **kube-bench**
- **peirates** (InGuardians) — post-exploitation in pods
- **botb** (Break Out The Box) — container escape attempts
- **BadPods** — privilege-escalation pod manifests by class

## Container Escape

- **runc CVE-2024-21626 "Leaky Vessels"** — file descriptor leak → escape; patched but legacy clusters linger
- **Docker socket mount** `/var/run/docker.sock` → root on host
- **Capabilities** — `SYS_ADMIN`, `SYS_PTRACE`, `DAC_READ_SEARCH` all dangerous
- **User namespace** misconfig — rootless promises broken if shared

## eBPF — offense + defense

2025: eBPF is everywhere (Cilium, Tetragon, Falco). Attack surface grows.

- **CVE-2025-21756** — Linux kernel eBPF verifier bypass (bounded by distro patch cycle)
- Rootkits using eBPF for stealthy syscall hooking (BPFDoor style) — detection lag
- Defense: kernel ≥6.6, Tetragon policy audits, seccomp denylist for `bpf()` where possible

## Service mesh

- Istio / Linkerd mTLS gaps — `PeerAuthentication` STRICT vs PERMISSIVE
- Envoy header stripping bypass (track CVEs)

## Serverless / CI

- **AWS Lambda** — token via `/proc/self/environ` in non-isolated runtimes
- **GitHub Actions OIDC** — overly broad `sub` claim in trust policy → cross-account assume
- **Vercel / Netlify functions** — env leaks via custom error pages

## Defenses (study to reverse)

- **OPA Gatekeeper / Kyverno** — admission policy
- **Falco / Tetragon** — runtime detection
- **Cosign** — signed images only
- **Kyverno** policies require `runAsNonRoot`, drop all caps, readOnlyRootFilesystem
- **Network policies** default-deny

## What pays in bug bounty

- Exposed kubelet / dashboard → critical
- SSRF to metadata → critical (AWS/GCP creds)
- Pod escape from hostile tenant → critical
- Admission controller RCE → critical
- RBAC over-permissive ServiceAccount on public repo → high

---

*CVE IDs verified pre-Apr 2026. Cluster misconfig patterns are stable.*
