#!/usr/bin/env python3
"""
publish.py — stage 3 of refresh-latest.

Reads compressed/<source>/<date>/*.md, extracts YAML frontmatter (from
kdai_tag_extract pattern run), enforces taxonomy, clusters duplicates,
ranks, files into MyMac/ by class+tag, updates tag index.

Items that fail validation get quarantined to cache/quarantine/<date>/
with a reason — never silently dropped.
"""
import os, re, sys, json, hashlib, shutil
from pathlib import Path
from datetime import datetime, timezone
from collections import defaultdict

try:
    import yaml
except ImportError:
    print("install pyyaml: pip install --user pyyaml", file=sys.stderr)
    sys.exit(1)

SKILL = Path(os.environ.get("SKILL_DIR", Path.home() / ".claude/skills/refresh-latest"))
CACHE = SKILL / "cache"
COMPRESSED = CACHE / "compressed"
QUARANTINE = CACHE / "quarantine"
REPO = Path(os.environ.get("REPO", Path.home() / "MyMac"))
TAXONOMY = yaml.safe_load((SKILL / "taxonomy.yaml").read_text())
STATE_PATH = SKILL / "state.json"
TODAY = datetime.now(timezone.utc).strftime("%Y-%m-%d")

REQUIRED = TAXONOMY["required_fields"]
SEV_SCORE = TAXONOMY["severity_score"]
VOCAB = {t for group in TAXONOMY["tag_vocab"].values() for t in group}

FM_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n?(.*)$", re.DOTALL)
FENCE_RE = re.compile(r"^```(?:yaml|yml)?\s*\n(.*?)\n```\s*", re.DOTALL)


def parse_item(path: Path):
    """Return (frontmatter_dict, body_text) or (None, reason)."""
    text = path.read_text(errors="ignore").lstrip()
    # Defensively strip ```yaml fences if model emitted them
    fence = FENCE_RE.match(text)
    if fence:
        text = "---\n" + fence.group(1).strip() + "\n---\n" + text[fence.end():]
    m = FM_RE.match(text)
    if not m:
        return None, "no-frontmatter"
    try:
        raw_fm = m.group(1)
        # Fix 1: unquoted scalar values with ': ' (title/vendor/product with colons).
        raw_fm = re.sub(
            r'^(\w[\w_-]*): ([^\n\'"[{|>!&*].+:.+)$',
            lambda mo: f'{mo.group(1)}: "{mo.group(2).replace(chr(34), chr(39))}"',
            raw_fm, flags=re.MULTILINE
        )
        # Fix 2: inline flow sequences with URLs containing ? or & (YAML special chars).
        # Convert  key: [url1, url2]  →  block list so YAML doesn't choke on query strings.
        def _flow_to_block(mo):
            key = mo.group(1)
            items = [u.strip().strip('"\'') for u in mo.group(2).split(',') if u.strip()]
            if not items:
                return f'{key}: []'
            lines = [f'{key}:'] + [f'  - "{u}"' if any(c in u for c in '?&:') else f'  - {u}' for u in items]
            return '\n'.join(lines)
        raw_fm = re.sub(
            r'^([\w_-]+): \[([^\]]*[?&:][^\]]*)\]$',
            _flow_to_block, raw_fm, flags=re.MULTILINE
        )
        fm = yaml.safe_load(raw_fm) or {}
    except yaml.YAMLError as e:
        return None, f"yaml-parse: {e}"
    if not isinstance(fm, dict):
        return None, "frontmatter-not-dict"
    body = m.group(2).strip()
    return (fm, body), None


def _coerce_int(v, default=None):
    if isinstance(v, int):
        return v
    if isinstance(v, str):
        m = re.search(r"-?\d+", v)
        if m:
            try:
                return int(m.group(0))
            except ValueError:
                pass
    return default


def validate(fm: dict):
    # Coerce numeric strings before checking
    if "hunt_value" in fm:
        fm["hunt_value"] = _coerce_int(fm["hunt_value"], fm["hunt_value"])
    if "freshness_days" in fm:
        fm["freshness_days"] = _coerce_int(fm["freshness_days"], 30)
    # Coerce single-string tags into a list
    if isinstance(fm.get("tags"), str):
        fm["tags"] = [t.strip() for t in re.split(r"[,\s]+", fm["tags"]) if t.strip()]

    missing = [f for f in REQUIRED if f not in fm or fm[f] in (None, "")]
    if missing:
        return f"missing: {','.join(missing)}"
    tags = fm.get("tags") or []
    if not isinstance(tags, list) or not tags:
        return "tags-empty"
    if not any(t in VOCAB for t in tags):
        return "no-vocab-tag"
    if fm.get("class") not in {"cve", "technique", "writeup", "tool", "reading"}:
        return "bad-class"
    hv = fm.get("hunt_value")
    if not isinstance(hv, int) or not 1 <= hv <= 5:
        return "bad-hunt_value"
    return None


def rank_score(fm: dict) -> float:
    sev = SEV_SCORE.get(fm.get("severity", "unknown"), 4)
    hv = fm.get("hunt_value", 1)
    fresh = max(0, 30 - fm.get("freshness_days", 30)) / 30  # 1.0 today, 0 at 30d+
    poc_boost = 1.5 if fm.get("exploit_status") == "poc" else 1.0
    return round(sev * hv * (0.5 + 0.5 * fresh) * poc_boost, 2)


def cluster_key(fm: dict) -> str:
    """Items with same CVE OR same (vendor,product,primary_tag) cluster together."""
    cve = (fm.get("cve") or "").strip().upper()
    if cve:
        return f"cve:{cve}"
    vendor = (fm.get("vendor") or "").lower()
    product = (fm.get("product") or "").lower()
    tags = fm.get("tags") or []
    primary = next((t for t in tags if t in VOCAB), tags[0] if tags else "misc")
    return f"vp:{vendor}:{product}:{primary}"


def class_path(fm: dict) -> Path:
    cls = fm["class"]
    tags = fm.get("tags", [])
    if cls == "cve":
        # File by vendor or primary vuln-class
        vendor = (fm.get("vendor") or "").lower()
        if vendor:
            return REPO / "Latest-2026" / f"{vendor}-cves.md"
        primary = next((t for t in tags if t in TAXONOMY["tag_vocab"]["vuln_class"]), "misc")
        return REPO / "Latest-2026" / f"{primary}-cves.md"
    if cls == "technique":
        primary = next((t for t in tags if t in TAXONOMY["tag_vocab"]["vuln_class"]), "misc")
        return REPO / "Latest-2026" / f"{primary}-techniques.md"
    if cls == "writeup":
        return REPO / "Notes" / "writeups-2026.md"
    if cls == "tool":
        return REPO / "Cheatsheets" / "tools-index.md"
    return REPO / "Notes" / "daily" / f"{TODAY}.md"


def render_block(fm: dict, body: str, score: float, sources: list) -> str:
    title = fm.get("title", "(untitled)")
    cve = fm.get("cve") or ""
    cve_str = f" — `{cve}`" if cve else ""
    tags_str = " ".join(f"`#{t}`" for t in fm.get("tags", []))
    src_links = " · ".join(f"[{i+1}]({u})" for i, u in enumerate(sources[:5]))
    # Strip leading ### title line from body — kdai_item pattern includes it for some classes
    # but render_block already adds the title as the first line.
    body_clean = re.sub(r'^###[^\n]*\n', '', body.lstrip(), count=1)
    return f"""### {title}{cve_str}
- **Tags:** {tags_str}
- **Severity:** {fm.get('severity')} · **Hunt:** {fm.get('hunt_value')}/5 · **Score:** {score} · **Status:** {fm.get('exploit_status')} · **Age:** {fm.get('freshness_days')}d
- **Sources:** {src_links}

{body_clean.strip()}

---
"""


def main():
    QUARANTINE.mkdir(parents=True, exist_ok=True)
    quarantine_dir = QUARANTINE / TODAY
    quarantine_dir.mkdir(exist_ok=True)

    items = []  # (fm, body, source_url, source_name, path)
    rejected = 0

    for src_dir in COMPRESSED.iterdir():
        if not src_dir.is_dir():
            continue
        date_dir = src_dir / TODAY
        if not date_dir.exists():
            continue
        for md in date_dir.glob("*.md"):
            parsed, err = parse_item(md)
            if err:
                shutil.copy(md, quarantine_dir / f"{src_dir.name}-{md.name}")
                (quarantine_dir / f"{src_dir.name}-{md.name}.reason").write_text(err)
                rejected += 1
                continue
            fm, body = parsed
            err = validate(fm)
            if err:
                shutil.copy(md, quarantine_dir / f"{src_dir.name}-{md.name}")
                (quarantine_dir / f"{src_dir.name}-{md.name}.reason").write_text(err)
                rejected += 1
                continue
            refs = fm.get("references") or []
            url = refs[0] if refs else ""
            items.append((fm, body, url, src_dir.name, md))

    # URL-dedup first: same canonical URL from multiple sources → keep highest-scoring copy
    url_seen: dict = {}
    deduped = []
    for it in items:
        fm, body, url, src, md = it
        canon = re.sub(r'\?.*$', '', url).rstrip('/')  # strip query params for Medium etc.
        if canon and canon in url_seen:
            # Keep the one with the higher hunt_value; ties go to first seen
            existing_idx = url_seen[canon]
            if fm.get("hunt_value", 0) > deduped[existing_idx][0].get("hunt_value", 0):
                deduped[existing_idx] = it
        else:
            if canon:
                url_seen[canon] = len(deduped)
            deduped.append(it)
    items = deduped

    # Cluster
    clusters = defaultdict(list)
    for it in items:
        clusters[cluster_key(it[0])].append(it)

    # Pick best item per cluster (highest score), aggregate source URLs
    published = []
    for key, members in clusters.items():
        scored = [(rank_score(fm), fm, body, url, src, path) for (fm, body, url, src, path) in members]
        scored.sort(key=lambda x: x[0], reverse=True)
        best_score, best_fm, best_body, _, _, _ = scored[0]
        all_sources = [m[3] for m in scored if m[3]]
        published.append((best_score, best_fm, best_body, all_sources, key, len(members)))

    # Sort overall by score
    published.sort(key=lambda x: x[0], reverse=True)

    # File into MyMac/
    grouped = defaultdict(list)
    for score, fm, body, sources, key, dups in published:
        target = class_path(fm)
        target.parent.mkdir(parents=True, exist_ok=True)
        grouped[target].append((score, fm, body, sources, dups))

    written_files = []
    # Match existing "## YYYY-MM-DD" section so re-runs replace, not duplicate
    today_section_re = re.compile(
        rf"\n## {re.escape(TODAY)}\n.*?(?=\n## \d{{4}}-\d{{2}}-\d{{2}}\n|\Z)",
        re.DOTALL,
    )
    for target, blocks in grouped.items():
        existing = target.read_text() if target.exists() else f"# {target.stem}\n\n"
        new_section = f"\n## {TODAY}\n\n"
        for score, fm, body, sources, dups in blocks:
            new_section += render_block(fm, body, score, sources)
            if dups > 1:
                new_section += f"*Clustered {dups} sources for this item.*\n\n"
        if today_section_re.search(existing):
            existing = today_section_re.sub(new_section.rstrip() + "\n", existing, count=1)
            target.write_text(existing)
        else:
            target.write_text(existing + new_section)
        written_files.append(str(target.relative_to(REPO)))

    # Update tag index
    tag_index = REPO / "Latest-2026" / "_tags.md"
    tag_index.parent.mkdir(parents=True, exist_ok=True)
    tag_counts = defaultdict(int)
    for _, fm, _, _, _, _ in published:
        for t in fm.get("tags", []):
            tag_counts[t] += 1
    tag_lines = ["# Tag Index", f"Updated {TODAY}.", ""]
    for tag, count in sorted(tag_counts.items(), key=lambda x: -x[1]):
        tag_lines.append(f"- `#{tag}` — {count}")
    tag_index.write_text("\n".join(tag_lines))

    # Update state stats + cement hashes for items that successfully published.
    # (Quarantined items do NOT get hashed, so they retry next run.)
    state = json.loads(STATE_PATH.read_text()) if STATE_PATH.exists() else {}
    state.setdefault("stats", {})
    state.setdefault("seen", [])
    cls_count = defaultdict(int)
    new_hashes = []
    for _, fm, _, sources, _, _ in published:
        cls_count[fm["class"]] += 1
        for url in sources or []:
            if url:
                new_hashes.append(hashlib.sha256(url.encode()).hexdigest())
        for ref in fm.get("references") or []:
            if ref:
                new_hashes.append(hashlib.sha256(str(ref).encode()).hexdigest())
    # FIFO cap at 5000
    seen = list(dict.fromkeys(state["seen"] + new_hashes))[-5000:]
    state["seen"] = seen
    state["last_publish"] = datetime.now(timezone.utc).isoformat()
    state["last_publish_items"] = len(published)
    state["last_publish_rejected"] = rejected
    state["last_publish_class"] = dict(cls_count)
    STATE_PATH.write_text(json.dumps(state, indent=2))

    print(f"published: {len(published)} items ({dict(cls_count)})")
    print(f"rejected:  {rejected} (see {quarantine_dir})")
    print(f"files:     {len(written_files)}")
    for f in written_files:
        print(f"  - {f}")


if __name__ == "__main__":
    main()
