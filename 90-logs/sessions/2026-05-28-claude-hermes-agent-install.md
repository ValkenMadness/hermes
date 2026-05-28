---
title: 2026-05-28-claude-hermes-agent-install
date: 2026-05-28
agent: claude_cowork
domain: system
type: session-summary
status: active
created: 2026-05-28
updated: 2026-05-28
updated_by: claude_cowork
tags: [session-summary, hermes-agent, nous-research, install, infrastructure]
supersedes: ""
related: ["[[2026-05-27-claude-post-migration-housekeeping]]", "[[agent-connection-protocol]]", "[[decision-log]]", "[[handoff_hermes_agent_setup_2026_05_28]]"]
---

# Session Summary — Hermes Agent Installation

## What Was Done

### Nous Research Hermes Agent Installed
- Ran the official PowerShell installer from GitHub on Valken's desktop
- Installer auto-provisioned: uv 0.11.16, Python 3.11.15, Node.js v24.14.0, ripgrep, ffmpeg
- Setup wizard completed: Nous Portal (free tier, no models available), local terminal backend, no messaging
- 90 bundled skills synced
- `hermes` command added to PATH
- Install location: `C:\Users\user\AppData\Local\hermes\`

### Architecture Discovery
- Valken has an Alienware 17R4 laptop running as a home lab server
- Ollama 8B is already running on the Alienware (separate machine on local network)
- Hermes Agent was installed on the desktop (primary workstation), not the Alienware
- This creates a split architecture: inference on Alienware, agent on desktop, vault on desktop

### Open Architecture Questions Identified
Three decisions need to be made before completing the connection:
1. Where should Hermes Agent run? (desktop vs Alienware vs both)
2. Where should the Obsidian vault live? (desktop vs Alienware, sync strategy)
3. Which Ollama model? (current generic 8B vs hermes3:8b)

### Previous Session Housekeeping (also this conversation)
- Updated 2026-05-26 session log with full Phase 2-3 migration details
- Ran frontmatter health check (131 notes, 0 violations, 2 minor fixes)
- Updated domain-map.md with completed migration status
- Created CLAUDE.md, agent-connection-protocol.md, chatgpt-session-briefing.md
- Added retrieval_priority: high to 12 notes
- Recorded decisions D-009 through D-012

## Decisions Made

No new decisions recorded this session — three decisions pending Valken's input (documented in handoff).

## Files Created

- `40-operations/handoffs/handoff_hermes_agent_setup_2026_05_28.md` — comprehensive handoff for next session
- `90-logs/sessions/2026-05-28-claude-hermes-agent-install.md` (this file)

## Files Modified

None this session (previous work in same conversation modified multiple files — see 2026-05-27 session log).

## Vault Health Summary

- **Total notes**: 136 (134 + 2 new this session)
- **Frontmatter compliance**: 100%
- **Decisions recorded**: D-001 through D-012
- **Git**: Staged changes still pending commit (index.lock issue from previous session)

## Next Steps

1. **Valken**: Decide on three architecture questions (see handoff)
2. **Valken**: Get Alienware local IP, configure Ollama to listen on 0.0.0.0
3. **Next session**: Configure Hermes Agent config.yaml with Ollama endpoint + vault MCP
4. **Next session**: Pull hermes3 model on Alienware
5. **Next session**: Test full interop loop (Hermes Agent reads/writes vault)
6. **Valken**: Commit pending git changes
