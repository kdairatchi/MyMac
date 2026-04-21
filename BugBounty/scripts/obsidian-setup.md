---
tags: [setup, obsidian]
---

# Obsidian Setup for BugBounty Hub

## Step 1 — Add vault path to Obsidian

Open Obsidian → Open folder as vault → select:
```
/mnt/c/Users/Dr34d/OneDrive/Documents/Obsidian Vault
```
Or sync first, then open the vault you already have.

## Step 2 — Install recommended community plugins

Settings → Community plugins → Browse:

| Plugin | Why |
|--------|-----|
| **Dataview** | Required — enables the table queries in INDEX.md |
| **Obsidian Git** | Auto-commit/push notes changes |
| **Kanban** | Hunt board management |
| **Templater** | Hunt log templates |
| **Minimal Theme Settings** | Cleaner reading view |

## Step 3 — CSS snippet for hunter layout

Settings → Appearance → CSS Snippets → Create `bb-hunter.css`:

```css
/* BugBounty hunter view — two-column callout layout */
.bb-hunter .callout {
  margin-bottom: 0.5rem;
}

/* Wider reading line for code blocks */
.bb-hunter .markdown-reading-view {
  max-width: 900px;
}

/* Better code block contrast */
.bb-hunter pre code {
  font-size: 0.85em;
}

/* Quick scan — make TL;DR callout stand out */
.callout[data-callout="tldr"] {
  background-color: rgba(0, 200, 100, 0.08);
  border-left-color: #00c864;
}

.callout[data-callout="info"] {
  background-color: rgba(0, 150, 255, 0.08);
}

/* Step numbers */
.markdown-reading-view h3 {
  color: var(--color-accent);
  font-size: 1em;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
```

Enable the snippet after saving.

## Step 4 — Sync workflow

```bash
# Run from WSL any time you update notes
bash /home/anon/MyMac/BugBounty/scripts/obsidian-sync.sh

# Or set up a cron (every 30 min)
crontab -e
# Add:
# */30 * * * * bash /home/anon/MyMac/BugBounty/scripts/obsidian-sync.sh >> /tmp/obsidian-sync.log 2>&1
```

## Step 5 — Split pane hunting setup

In Obsidian:
1. Open `BugBounty/INDEX.md`
2. Click the vuln file you need (e.g., XSS)
3. Right-click → Open in new pane (left pane = notes, right pane = terminal/Burp)
4. Pin the left pane

This gives you the step-by-step + payloads visible while working in Burp on the right.

## Dataview Queries

Add these to any note to auto-index:

````dataview
TABLE updated, tags
FROM "06 - Knowledge Base/BugBounty/01-vuln"
SORT updated DESC
````

````dataview
LIST
FROM "06 - Knowledge Base/BugBounty"
WHERE contains(tags, "p1")
````
