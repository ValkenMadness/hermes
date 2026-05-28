---
title: agent-connection-protocol
domain: system
type: knowledge
status: active
created: 2026-05-27
updated: 2026-05-28
updated_by: claude_cowork
tags: [system, agents, protocol, connection, hermes-agent]
supersedes: ""
related: ["[[handoff-protocol]]", "[[claude]]", "[[chatgpt]]", "[[claude-code]]", "[[claude-cowork]]", "[[brain-manager-gpt]]"]
---

# Agent Connection Protocol

How each AI agent connects to Hermes. This is the operational bridge between "Hermes exists as files" and "agents actually use it."

---

## Connection Matrix

| Agent | Access Method | Reads From | Writes To | Connection Mechanism |
|-------|-------------|------------|-----------|---------------------|
| Claude Cowork | Filesystem + Obsidian MCP | Everything | Domain content, logs, handoffs | Cowork folder mount + MCP |
| Claude Desktop | Obsidian MCP | Everything | Domain content, logs, handoffs | MCP plugin in Obsidian |
| Claude Browser | No filesystem | Memory only | Nothing (relay through human) | Claude memory sync |
| Claude Code | Direct filesystem | Everything | 60-automation/, 70-telemetry/, code | CLAUDE.md in vault root |
| ChatGPT | Paste/upload | What human provides | Handoff briefs (via human relay) | Session briefing doc |
| Brain Manager GPT | Obsidian MCP | Everything | Domain content, frontmatter | Custom GPT + MCP plugin |
| Hermes Agent (desktop) | Obsidian MCP + filesystem | Everything | Session logs, automation, vault content | MCP servers in config.yaml + CLAUDE.md |
| Hermes Agent (Alienware) | Obsidian MCP + filesystem | Everything (git-synced clone) | Session logs, automation, vault content | MCP servers in config.yaml + git sync |

---

## Pre-Work Read Protocol

Every agent, before starting work, reads:

1. **`00-system/decision-log.md`** — What has been decided
2. **Relevant `INDEX.md`** — What exists in the domain you're touching
3. **Latest session log in `90-logs/sessions/`** — Where work left off
4. **Own manifest in `30-agents/`** — Your permissions and rules

Agents with filesystem access do this automatically. Agents without (ChatGPT, Claude Browser) receive this via paste from the human.

---

## Post-Work Write Protocol

After producing actionable output:

1. **Session summary** → `90-logs/sessions/YYYY-MM-DD-[agent]-[topic].md`
2. **Decisions** → Append to `00-system/decision-log.md`
3. **Handoff briefs** → `40-operations/handoffs/[name].md`
4. **Git commit** → `[agent:name] [domain:name] Brief description`

Agents without write access (ChatGPT, Claude Browser) produce output in conversation. The human commits it to Hermes.

---

## Agent-Specific Setup

### Claude Cowork
- **Setup**: Mount `E:\20 - Project Hermes` as Cowork folder
- **Obsidian**: Open Hermes as vault → MCP auto-connects
- **Status**: CONNECTED (filesystem), PENDING (MCP — needs vault switch)

### Claude Desktop (non-Cowork)
- **Setup**: Open Hermes as vault in Obsidian → MCP plugin provides read/write
- **Status**: PENDING (needs vault switch)

### Claude Browser
- **Setup**: Sync key state to Claude's memory periodically
- **What to sync**: Current phase, active decisions, domain structure overview
- **Frequency**: After each major session or decision
- **Status**: NOT YET CONFIGURED

### Claude Code
- **Setup**: `CLAUDE.md` exists in vault root — reads automatically
- **Additional**: Each project repo should reference Hermes in its own CLAUDE.md
- **Status**: READY (CLAUDE.md created 2026-05-27)

### ChatGPT
- **Setup**: Paste `30-agents/chatgpt-session-briefing.md` at session start
- **Update**: Refresh the "Current State" block before each session
- **Status**: READY (briefing doc created 2026-05-27)

### Brain Manager GPT
- **Setup**: Custom GPT with Obsidian MCP access pointing to Hermes vault
- **Prerequisite**: Hermes must be the active vault in Obsidian
- **Status**: PENDING (needs vault switch)

### Hermes Agent (Nous Research)
- **Framework**: [github.com/NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
- **Model**: hermes3:8b via Ollama on Alienware (192.168.8.21:11434)
- **Runs on**: Both desktop and Alienware (D-013)
- **Vault access**: Obsidian MCP server (`obsidian-mcp` npm package) + filesystem MCP
- **Config**: `~/.hermes/config.yaml` — see `60-automation/hermes-config-template.yaml`
- **Vault sync**: Git clone on both machines (D-014), push/pull to shared remote
- **Setup (desktop)**: Copy `60-automation/hermes-config-template.yaml` to `C:\Users\user\AppData\Local\hermes\config.yaml`
- **Setup (Alienware)**: Run `60-automation/alienware-setup.ps1`, then copy config template with Alienware variant values
- **Status**: INSTALLED (desktop), PENDING CONFIG (needs config.yaml update + Alienware Ollama setup)

---

## Remaining Blockers

### Obsidian MCP vault path (Claude agents)
Three agents (Claude Cowork MCP, Claude Desktop, Brain Manager GPT) depend on the Obsidian MCP being pointed at the Hermes vault. The MCP server's vault path must be updated in the Claude Desktop config (`%APPDATA%\Claude\claude_desktop_config.json`) to `E:\20 - Project Hermes`. Simply switching vaults in Obsidian's UI is not sufficient — the MCP server config holds a fixed path.

### Ollama network access (Hermes Agent)
Hermes Agent on the desktop needs Ollama on the Alienware (192.168.8.21:11434) to be listening on all interfaces with 64K context. Run `60-automation/alienware-setup.ps1` on the Alienware to configure this.

---

## Interoperability Test

The agents are properly connected when this loop works:

1. Agent A reads decision log + INDEX + latest session log
2. Agent A does work, writes session summary back to Hermes
3. Agent B (different agent) reads Agent A's session summary
4. Agent B continues the work without needing anything from chat history
5. The decision log is the shared state, not conversation memory

This is the swappability test from Phase 5. If it passes, the architecture is correct.
