# imagemagick-cves


## 2026-07-07

### ImageMagick 8BIM Profile Use-After-Free (CVE-2026-55510) — `CVE-2026-55510`
- **Tags:** `#rce` `#web`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-55510)

- **What:** A use-after-free occurs in ImageMagick when identifying an image containing a crafted 8BIM profile with a specific format string, in versions prior to 6.9.13-51 and 7.1.2-26.
- **Why it matters:** Use-after-free bugs in image parsers are reliable primitives for RCE; ImageMagick is ubiquitous in web backends processing user-uploaded images, making the attack surface enormous.
- **Hunt signal:** Upload a crafted image with a malicious 8BIM profile to any endpoint that processes images (avatars, uploads, conversions) and check for crashes or delayed responses; look for ImageMagick version leaks in metadata or error messages to confirm unpatched instances.
- **Evidence:** [source] NVD entry confirms patched in 6.9.13-51 / 7.1.2-26 · [opinion] High-value hunt target — many production systems lag on ImageMagick patches and the 8BIM parsing path is reachable via a simple file upload.

---
### ImageMagick XCF decoder integer overflow OOB read — `CVE-2026-53466`
- **Tags:** `#web`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-53466)

- **What:** Integer overflow in ImageMagick's XCF (GIMP) decoder triggers an out-of-bounds read when processing a crafted image, resulting in a crash.
- **Why it matters:** ImageMagick is ubiquitous in web apps handling user-uploaded images; an attacker who controls image input can cause DoS or potentially leak memory contents via OOB read.
- **Hunt signal:** Upload crafted XCF files to targets running unpatched ImageMagick (< 6.9.13-51 or < 7.1.2-26) and monitor for crashes or abnormal responses.
- **Evidence:** [NVD] CVE-2026-53466 — integer overflow in XCF decoder → OOB read → crash, fixed in 6.9.13-51 and 7.1.2-26 · [opinion] confirmed impact is DoS/OOB read; RCE unlikely unless chained with additional memory corruption primitives

---
### ImageMagick MNG Decoder Heap Info Disclosure (CVE-2026-53467) — `CVE-2026-53467`
- **Tags:** `#data-exfil` `#web`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-53467)

- **What:** ImageMagick's MNG decoder leaves pixel data unchanged, leaking heap memory contents through processed images.
- **Why it matters:** Attackers who can trigger MNG decoding can extract sensitive heap data (credentials, tokens, pointers) from the server's memory via the output image.
- **Hunt signal:** Upload crafted MNG files to image-processing endpoints; inspect output pixels for non-random patterns indicating leaked heap data.
- **Evidence:** [nvd] Uninitialized pixels in MNG decoder prior to 6.9.13-51/7.1.2-26 · [opinion] Chainable with upload/ssrf surfaces but standalone impact limited to info leak

---
