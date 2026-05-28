---
title: handoff_hermes_agent_setup_2026_05_28
domain: system
type: handoff
status: active
created: 2026-05-28
updated: 2026-05-28
updated_by: claude_cowork
tags: [handoff, hermes-agent, nous-research, ollama, local-llm, infrastructure]
supersedes: ""
related: ["[[agent-connection-protocol]]", "[[decision-log]]", "[[domain-map]]", "[[2026-05-28-claude-hermes-agent-install]]"]
---

# Handoff — Hermes Agent Installation & Vault Connection

## Context

Valken is building a sovereign AI infrastructure using the Nous Research Hermes Agent framework (https://github.com/NousResearch/hermes-agent) connected to his Obsidian knowledge vault (Project Hermes at `E:\20 - Project Hermes`). The vault migration (Phases 1-3 from the cold-start doc) is complete — 134+ notes, 100% frontmatter compliance, git-tracked. This handoff covers the work done to install Hermes Agent and the open decisions for completing the connection.

## What Was Done

### Hermes Agent Installed on Desktop
- Ran the PowerShell installer: `irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1 | iex`
- Installer completed successfully — installed uv, Python 3.11.15, Node.js v24.14.0, ripgrep, ffmpeg
- Setup wizard completed with these choices:
  - Provider: Nous Portal (free tier) — logged in successfully but **no free models currently available**
  - Terminal backend: Local (default)
  - Messaging platforms: None configured (skipped)
- 90 bundled skills synced to `~/.hermes/skills/`
- Config location: `C:\Users\user\AppData\Local\hermes\config.yaml`
- API keys: `C:\Users\user\AppData\Local\hermes\.env`
- Code: `C:\Users\user\AppData\Local\hermes\hermes-agent\`
- `hermes` command available after terminal restart (added to user PATH)

### No LLM Provider Active Yet
- Nous Portal free tier has zero models available
- Valken has no API keys for OpenRouter, Anthropic, or OpenAI (only subscriptions)
- Decision: use local Ollama for inference — free, sovereign, no API dependency

### Previous Session Work (2026-05-27)
- Created `CLAUDE.md` in vault root (Claude Code auto-discovery)
- Created `00-system/agent-connection-protocol.md` (master connection protocol)
- Created `30-agents/chatgpt-session-briefing.md` (pasteable context for ChatGPT)
- Added `retrieval_priority: high` to 12 most-referenced notes
- Decisions D-009 through D-012 recorded

## What Still Needs to Be Done

### 1. Connect Hermes Agent to Ollama (CRITICAL PATH)
- Valken has an **Alienware 17R4 laptop** running as a home lab with **Ollama 8B already running**
- The Alienware is a **separate machine on the local network** (not the desktop where Hermes Agent is installed)
- Need to: find the Alienware's local IP, configure Ollama to listen on `0.0.0.0` (not just localhost), update Hermes Agent `config.yaml` to point at `http://<alienware-ip>:11434`
- Model: currently running 8B, may want to switch to `hermes3` (Nous Research's model built for this agent)

### 2. Open Architecture Decisions (NOT YET DECIDED)

**Decision A: Where should Hermes Agent run?**
- Currently installed on the **desktop** (Valken's primary workstation)
- Valken raised the question of whether it should run on the **Alienware laptop** instead, since the laptop is "more always-on"
- Trade-offs: Desktop is where Valken works (lower latency to vault), Alienware is always-on (better for gateway/cron/messaging)
- Could also run Hermes Agent on both — desktop for interactive use, Alienware for gateway/background tasks
- **Needs Valken's decision**

**Decision B: Where should the Obsidian vault live?**
- Currently at `E:\20 - Project Hermes` on the **desktop**
- Valken asked: "Should we also move the Obsidian Vault to the laptop?"
- If vault moves to Alienware: Hermes Agent + Ollama + vault all co-located (simplest), but desktop loses direct filesystem access
- If vault stays on desktop: need network share or sync mechanism for Alienware access
- Could use git as the sync layer — both machines clone the repo, push/pull to stay in sync
- **Needs Valken's decision**

**Decision C: Model selection**
- Currently running generic 8B on Alienware
- `hermes3` (Nous Research) is purpose-built for Hermes Agent — available in 8B and 70B
- Alienware 17R4 likely has a GTX 1070/1080 (6-8GB VRAM) — 8B is the right size class
- Run: `ollama pull hermes3` on the Alienware to get the optimized model
- **Recommend hermes3:8b but Valken should confirm GPU specs**

### 3. Configure Hermes Agent config.yaml
Once decisions A and B are made, edit `C:\Users\user\AppData\Local\hermes\config.yaml`:

```yaml
# Point at Ollama on Alienware
provider: custom
model: hermes3
api_base: "http://<alienware-ip>:11434/v1"

# Connect to Obsidian vault via MCP
mcp_servers:
  obsidian:
    command: "npx"
    args: ["-y", "obsidian-mcp", "--vault", "E:\\20 - Project Hermes"]
```

Note: The exact MCP config syntax may differ — check Hermes Agent docs for `mcp_servers` format. The Obsidian MCP server package name may be `@anthropic/obsidian-mcp` or similar.

### 4. Test the Interop Loop
From `agent-connection-protocol.md`, the test is:
1. Hermes Agent reads decision log + INDEX + latest session log
2. Hermes Agent does work, writes session summary back to vault
3. A different agent reads that summary and continues work
4. Decision log is the shared state

### 5. Future: Messaging Gateways
Hermes Agent supports Telegram, Discord, WhatsApp, Slack, Signal, and more. Once core is working, Valken can wire up messaging so he can talk to Hermes from his phone. Run `hermes setup gateway` when ready.

### 6. Git Commit Pending
From previous session — staged changes need committing:
```powershell
# On desktop, in E:\20 - Project Hermes
del .git\index.lock   # if it still exists
git add -A
git commit -m "[agent:claude-cowork] [domain:system] Agent connection infrastructure and Hermes Agent install"
```

## Key File Locations

| What | Where | Machine |
|------|-------|---------|
| Hermes Agent install | `C:\Users\user\AppData\Local\hermes\` | Desktop |
| Hermes Agent config | `C:\Users\user\AppData\Local\hermes\config.yaml` | Desktop |
| Hermes Agent .env | `C:\Users\user\AppData\Local\hermes\.env` | Desktop |
| Obsidian vault | `E:\20 - Project Hermes` | Desktop |
| Ollama | Running on port 11434 | Alienware (laptop) |
| CLAUDE.md | `E:\20 - Project Hermes\CLAUDE.md` | Desktop |
| Decision log | `E:\20 - Project Hermes\00-system\decision-log.md` | Desktop |
| This handoff | `E:\20 - Project Hermes\40-operations\handoffs\handoff_hermes_agent_setup_2026_05_28.md` | Desktop |

## Decision Log Status

- D-001 through D-012: All approved (see `00-system/decision-log.md`)
- D-013 through D-015: Pending (architecture decisions A, B, C above)

## For the Next Agent

1. Read this handoff + `00-system/decision-log.md` + `00-system/agent-connection-protocol.md`
2. Ask Valken to decide on the three open architecture questions (where to run Hermes Agent, where to keep the vault, which model)
3. Get the Alienware's local IP (`ipconfig` on the laptop or check router)
4. Configure Ollama on the Alienware to listen on all interfaces: set `OLLAMA_HOST=0.0.0.0` environment variable
5. Update Hermes Agent config.yaml with the provider endpoint and MCP server
6. Pull `hermes3` model on the Alienware: `ollama pull hermes3`
7. Test: run `hermes` on the desktop, ask it to read the decision log
8. Update `agent-connection-protocol.md` with the new Hermes Agent entry
