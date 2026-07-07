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

## 2026-07-07

### containerd CDI annotation trust bypass on checkpoint restore — `CVE-2026-53492`
- **Tags:** `#privesc` `#kubernetes` `#docker`
- **Severity:** high · **Hunt:** 4/5 · **Score:** 28.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-53492)

- **What:** containerd's CRI plugin trusts CDI annotations from untrusted checkpoint image metadata during container restoration, allowing injection of arbitrary device nodes and host mounts into the restored container.
- **Why it matters:** A user with pod creation permissions can bypass Kubernetes device plugin enforcement and resource allocation, effectively escalating privileges on the host node by mounting sensitive devices.
- **Hunt signal:** Enumerate clusters where CDI is enabled (check for DeviceClass/CDI resources) and test checkpoint/restore flows for CDI annotation injection — focus on nodes with GPU or specialized device passthrough.
- **Evidence:** [source] NVD CVE-2026-53492 · [opinion] Authenticated but novel attack surface; high impact in GPU/device-heavy environments where CDI is commonly deployed.

---
### containerd CRI checkpoint import allows image cache poisoning via crafted checkpoint — `CVE-2026-50195`
- **Tags:** `#rce` `#privesc` `#kubernetes` `#supply-chain`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-50195)

- **What:** containerd < 2.3.2/2.2.5/2.1.9 fails to validate image references in CRI checkpoint imports, letting a pod-creating attacker poison the node's local image cache with a malicious image tagged as a legitimate one.
- **Why it matters:** Any pod on the same node using `ImagePullPolicy: IfNotPresent` or `Never` will silently execute the attacker's image instead of the intended image — cross-tenant RCE under the victim pod's identity.
- **Hunt signal:** In Kubernetes engagements with pod-creation rights, check node containerd version (`crictl version`) for < 2.3.2/2.2.5/2.1.9, then attempt CRI checkpoint restore with a crafted checkpoint image to inject a tag that collides with a target workload image.
- **Evidence:** [nvd] Patched in 2.3.2, 2.2.5, 2.1.9 · [opinion] Strong cluster-level privesc chain: pod-creation → node image cache poisoning → victim pod RCE; high value in multi-tenant clusters.

---
### containerd CRI symlink path-traversal via checkpoint log restore — `CVE-2026-53489`
- **Tags:** `#path-traversal` `#kubernetes` `#docker`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-53489)

- **What:** containerd CRI plugin restores container.log from a checkpoint image without validating that the path is a symlink, allowing arbitrary host file read via `kubectl logs`.
- **Why it matters:** Host file read through a container runtime primitive — any environment using container checkpoint/restore (CRI) with a malicious or tampered checkpoint image can leak secrets like `/etc/shadow`, cloud IMDS tokens, or kubeconfig files.
- **Hunt signal:** Check if target cluster has `--feature-gates=ContainerCheckpoint=true` enabled; create a pod with a symlinked `/dev/stdout` log path, checkpoint it, restore, then `kubectl logs` to read host files.
- **Evidence:** [source] NVD entry confirms symlink validation missing in CRI plugin log restore path · [opinion] chain-worthy in k8s environments where checkpoint/restore is enabled — pairs well with pod-creation rights to pivot from container to host file reads.

---
