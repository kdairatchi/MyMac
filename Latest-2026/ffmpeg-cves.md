# ffmpeg-cves


## 2026-08-30

### FFmpeg vf_swaprect OOB Write via Crafted NV12 Frame — `CVE-2026-65706`
- **Tags:** `#rce`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-65706)

- **What:** Out-of-bounds heap write in FFmpeg's vf_swaprect filter when processing crafted NV12 frames with odd width, caused by a temp row buffer sized for single-byte luma pixels being reused for two-byte interleaved chroma samples.
- **Why it matters:** A single crafted video frame triggers an 18-byte memcpy into a 17-byte heap allocation, yielding heap corruption with potential code execution — exploitable wherever FFmpeg processes user-uploaded media.
- **Hunt signal:** Upload a crafted NV12 video (odd-width, e.g. 17×16) to services that transcode or preview user video via FFmpeg; monitor for crashes or anomalous process behavior.
- **Evidence:** [source] NVD CVE-2026-65706 details the filter_frame() buffer reuse bug across luma/chroma planes · [opinion] strong chain candidate for any bounty program accepting media uploads — the bug is deterministic and the trigger is straightforward to craft

---
### FFmpeg vf_floodfill OOB Write via Reinit Filter Bypass — `CVE-2026-65705`
- **Tags:** `#rce`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-65705)

- **What:** Out-of-bounds write in FFmpeg's vf_floodfill filter when a dynamically sized video stream is processed with `-reinit_filter 0`, causing flood-fill neighbor pushes beyond the originally allocated traversal stack.
- **Why it matters:** Heap corruption from a crafted video can crash the process and potentially achieve code execution depending on heap layout and hardening.
- **Hunt signal:** Look for services that transcode untrusted video with FFmpeg using `-reinit_filter 0` and send a crafted stream with increasing frame dimensions; probe with `ffmpeg -reinit_filter 0 -vf floodfill -i crafted.mkv out.mp4` and monitor for crashes/ASAN reports.
- **Evidence:** [source] NVD entry describes heap corruption via dimension mismatch between config_input() allocation and filter_frame() traversal · [opinion] exploitability hinges on heap layout control but the OOB write primitive is strong — high-value target in any media-processing pipeline

---
### FFmpeg TDSC Decoder OOB Write via Dimension Change in TDSF Frames — `CVE-2026-65703`
- **Tags:** `#rce`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-65703)

- **What:** Out-of-bounds write in FFmpeg 2.7–8.1.2 TDSC video decoder caused by failing to unreference the existing frame before reallocating, allowing a crafted AVI with dimension-changing TDSF frames to trigger heap corruption.
- **Why it matters:** Any service that processes user-uploaded video through FFmpeg is vulnerable to crash and potential remote code execution via a malicious AVI file.
- **Hunt signal:** Upload crafted AVI files with mismatched TDSF frame dimensions to targets running FFmpeg-based media processing pipelines.
- **Evidence:** [NVD] tdsc_parse_tdsf() fails to unreference existing frame before av_frame_get_buffer(), causing tdsc_blit()/tdsc_yuv2rgb() to write attacker-controlled pixel data past buffer bounds · [opinion] strong chain candidate for video-upload endpoints

---
### FFmpeg TY Demuxer OOB Write via Crafted ffconcat — `CVE-2026-65704`
- **Tags:** `#rce` `#cloud`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://nvd.nist.gov/vuln/detail/CVE-2026-65704)

- **What:** Out-of-bounds write in FFmpeg ≤8.1.2 TY demuxer causes heap corruption via a crafted ffconcat file processed with the `-safe 0` flag.
- **Why it matters:** Missing bounds check on packet size decrement produces a negative value that wraps to SIZE_MAX in memcpy inside shorten_decode_frame(), enabling massive out-of-bounds reads and writes far beyond allocated buffers — potential code execution.
- **Hunt signal:** Probe media upload/processing endpoints that invoke FFmpeg transcoding with `-safe 0`; supply crafted ffconcat files and monitor for crashes or anomalous responses.
- **Evidence:** [source] NVD describes TY demuxer's `demux_audio()` decrementing packet size without bounds checking, passing negative size to `memcpy()` via `shorten_decode_frame()` where conversion to `size_t` wraps to near SIZE_MAX · [opinion] High-severity heap corruption in a ubiquitously embedded library; chain-worthy in any pipeline that accepts user-controlled media and passes it through FFmpeg concat processing.

---
