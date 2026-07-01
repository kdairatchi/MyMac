# linux-cves


## 2026-07-01

### Linux kernel AMD64 AGP NULL deref from broken error check — `CVE-2026-53325`
- **Tags:** `#cloud`
- **Severity:** medium · **Hunt:** 1/5 · **Score:** 5.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-53325)

- **What:** NULL pointer dereference in `amd64_fetch_size()` caused by `agp_amd64_probe()` checking `cache_nbs()` return against exactly `-1` instead of `< 0`, masking `-ENODEV` when no AMD northbridge exists.
- **Why it matters:** Triggers a General Protection Fault / kernel crash in virtualized environments (QEMU/KVM) lacking physical AMD northbridge hardware — a local DoS vector on misconfigured or nested-virt guests.
- **Hunt signal:** pass
- **Evidence:** [nvd] Error-propagation flaw in agp_amd64_probe masks -ENODEV, leading to NULL deref from node_to_amd_nb(0) · [opinion] Patched kernel driver bug with no realistic bug-bounty attack surface; reading-only value as a pattern reminder to always check `< 0` not `== -1`.

---
