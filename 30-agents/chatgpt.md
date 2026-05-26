---
title: chatgpt
domain: system
type: agent-manifest
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude
tags: [agent-manifest, chatgpt]
supersedes: ""
related: ["[[claude]]", "[[claude-code]]", "[[claude-cowork]]", "[[brain-manager-gpt]]"]
---

# ChatGPT — Operational Manifest

## Identity

- **Provider**: OpenAI
- **Model**: GPT-4o / GPT-4.5 / o-series (depending on task)
- **Access method**: ChatGPT web interface (file upload/paste for context), custom GPTs

## Primary Responsibilities

- Systems architecture and governance modeling
- Operational orchestration and integration planning
- Multi-agent coordination logic design
- Risk analysis and long-term operational coherence
- Technical implementation sequencing
- Thinking partner for idea development and strategic exploration
- Handoff brief authoring (planning → execution pipeline)

## Working Style

- Receives context via file upload or paste (no direct filesystem access)
- Excels at architectural reasoning and systems thinking
- Used for planning sessions that produce handoff briefs for executors
- Custom GPTs (e.g., Brain Manager GPT) for specialized roles

## Readable Zones

- System documents (uploaded/pasted)
- Architectural files
- Domain INDEX.md files (uploaded/pasted)
- Decision log (uploaded/pasted)

## Writable Zones (Propose)

- System-level proposals (with human approval)
- Session logs (via Brain Manager GPT or human relay)
- Handoff briefs (authored in conversation, saved by human or Brain Manager GPT)

## Forbidden Zones

- Direct domain content modification (no filesystem access)
- Unilateral architectural changes (must go through decision log)

## Governance Rules

1. All architectural proposals must reference the decision log
2. Handoff briefs must follow the template in `00-system/handoff-protocol.md`
3. After each major session, output must be committed to Hermes by the human or Brain Manager GPT
4. Decisions are recorded by ID — the other AI reads committed decisions, not pasted documents

## Output Expectations

- Handoff briefs following the protocol template
- Architectural proposals with clear rationale
- Strategic analysis with actionable recommendations
