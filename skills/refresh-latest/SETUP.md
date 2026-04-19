# Setup — one-time

The skill works the moment fabric has a provider configured.

## 1. Pick a provider

**Claude (voice match):**
```bash
cp ~/.config/fabric/.env.example ~/.config/fabric/.env
# edit ~/.config/fabric/.env — set ANTHROPIC_API_KEY
~/go/bin/fabric --listmodels | head   # sanity check
```

**Ollama (free, offline, recommended for daily runs to keep cost at $0):**
```bash
ollama pull qwen2.5:14b
cat > ~/.config/fabric/.env <<EOF
OLLAMA_API_URL=http://localhost:11434
DEFAULT_VENDOR=Ollama
DEFAULT_MODEL=qwen2.5:14b
EOF
```

**Interactive alternative:**
```bash
~/go/bin/fabric --setup
```

## 2. Smoke test

```bash
echo "CVE-2025-29927 Next.js middleware auth bypass via x-middleware-subrequest header. Affects Next.js 11.1.4-15.2.3. Disclosed March 2025 by Assetnote." | \
  ~/go/bin/fabric -p kdai_cve_brief
```

Should output a 5-line CVE block in your voice.

## 3. Run the skill

```bash
# Stage 1: fetch
~/.claude/skills/refresh-latest/refresh.sh

# Stage 2: compress via fabric
~/.claude/skills/refresh-latest/fabric-compress.sh

# Stage 3: Claude polishes + files into MyMac/ (do via /refresh-latest in CC)
```

Or all at once inside Claude Code:
```
/refresh-latest
```

## 4. Schedule daily

```
/schedule
# name: refresh-latest
# cron: 0 13 * * *
# skill: refresh-latest
```

## Tuning cost

- Daily run on Ollama: **$0**
- Daily run on Claude Sonnet (~30 items × 500 tokens avg): **~$0.05/day, $1.50/mo**

Default to Ollama. Upgrade to Claude only for the weekly rollup (kdai_hunt_summary) where voice matters most.
