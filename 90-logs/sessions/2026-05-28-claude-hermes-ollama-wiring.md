---
title: 2026-05-28-claude-hermes-ollama-wiring
date: 2026-05-28
agent: claude_cowork
domain: system
type: session-summary
status: active
created: 2026-05-28
updated: 2026-05-28
updated_by: claude_cowork
tags: [session-summary, hermes-agent, ollama, mcp, infrastructure, configuration]
supersedes: ""
related: ["[[2026-05-28-claude-hermes-agent-install]]", "[[handoff_hermes_agent_setup_2026_05_28]]", "[[agent-connection-protocol]]", "[[decision-log]]"]
---

# Session Summary — Hermes Agent Ollama Wiring & MCP Config

## What Was Done

### Architecture Decisions Resolved (D-013, D-014, D-015)
Three pending architecture decisions from the previous session were resolved with Valken:

- **D-013**: Hermes Agent runs on both machines — desktop for interactive use, Alienware for gateway/background tasks
- **D-014**: Vault synced via git on both machines — both get a clone, push/pull to shared remote
- **D-015**: hermes3:8b selected as Ollama model — Nous Research's purpose-built model for Hermes Agent

All three recorded in `00-system/decision-log.md`.

### Obsidian MCP Diagnosis
- Tested the Obsidian MCP connection — it's active but pointing at the **legacy vault**, not Hermes
- Vault switch in Obsidian UI did not change the MCP path (it's configured with a fixed path)
- Restarting Obsidian had no effect
- Root cause: the MCP server config (likely in `%APPDATA%\Claude\claude_desktop_config.json`) holds a hardcoded vault path
- Fix: update the vault path in the Claude Desktop MCP config to `E:\20 - Project Hermes`
- Documented in updated `agent-connection-protocol.md` under "Remaining Blockers"

### Alienware Setup Script Created
- `60-automation/alienware-setup.ps1` — PowerShell script to run on the Alienware
- Configures `OLLAMA_HOST=0.0.0.0` (network access) and `OLLAMA_CONTEXT_LENGTH=64000` (Hermes minimum)
- Pulls hermes3 model
- Guides vault git clone setup
- Optional Hermes Agent installation on Alienware
- Includes firewall rule and verification commands

### Hermes Agent Config Template Created
- `60-automation/hermes-config-template.yaml` — ready-to-copy config
- Points at Ollama on Alienware (192.168.8.21:11434)
- Wires up two MCP servers: `obsidian-mcp` for vault access, `@modelcontextprotocol/server-filesystem` for raw file access
- Includes Alienware variant instructions (when running agent on the Alienware itself)
- Sets context_length to 64000 (Hermes Agent minimum for tool use)

### Agent Connection Protocol Updated
- Added Hermes Agent entries to connection matrix (desktop and Alienware variants)
- Replaced "Local LLM (future) — NOT STARTED" with detailed Hermes Agent config
- Updated blockers section with specific MCP vault path fix instructions and Ollama setup reference
- Added hermes-agent tag

## Decisions Made

- D-013: Hermes Agent on both machines (approved)
- D-014: Git sync vault on both machines (approved)
- D-015: hermes3:8b model (approved)

## Files Created

- `60-automation/alienware-setup.ps1` — Alienware configuration script
- `60-automation/hermes-config-template.yaml` — Hermes Agent config template
- `90-logs/sessions/2026-05-28-claude-hermes-ollama-wiring.md` (this file)

## Files Modified

- `00-system/decision-log.md` — added D-013, D-014, D-015
- `00-system/agent-connection-protocol.md` — added Hermes Agent entries, updated blockers

## Next Steps (ordered by priority)

1. **Alienware setup**: Run `alienware-setup.ps1` on the Alienware to configure Ollama and pull hermes3
2. **Verify connectivity**: From desktop, run `curl http://192.168.8.21:11434/api/tags` to confirm Ollama is reachable
3. **Apply config**: Copy `hermes-config-template.yaml` to `C:\Users\user\AppData\Local\hermes\config.yaml`
4. **Test Hermes Agent**: Run `hermes` on desktop, ask it to read the decision log via MCP
5. **Fix Claude MCP**: Update vault path in Claude Desktop MCP config to `E:\20 - Project Hermes`
6. **Git remote**: Set up a shared git remote (GitHub/Gitea) for vault sync between machines
7. **Alienware clone**: Clone vault to Alienware, install Hermes Agent there too
8. **Interop test**: Full loop — Hermes Agent reads vault, does work, writes back, Claude reads the result
9. **Git commit**: Commit all pending changes from this and previous sessions
