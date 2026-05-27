---
title: ways_of_working
domain: system
type: knowledge
status: active
created: 2026-04-24
updated: 2026-04-24
updated_by: claude
tags: [system, process, roles, workflow]
supersedes: ""
related: ["[[master_instruction_deck]]", "[[handoff_protocol]]", "[[completion_report_protocol]]", "[[brain_update_protocol]]"]
---

# Ways of Working

This document defines how Valken works with AI models, how they work with each other, and the rules that keep the system functional.

## The Operating Model

Valken runs a one-person company powered by an AI workforce. There is no development team. Every AI model is a specialist employee with a defined role. The Obsidian brain is the shared knowledge base that all models read from and write back to.

The system is designed to minimise token burn on paid platforms by ensuring that every interaction starts with precise context rather than re-explanation. The brain provides this context.

## Model Roles in Detail

### ChatGPT — The Thinking Partner

ChatGPT is Valken's primary conversational partner for ideation, strategy, business planning, and brief development. ChatGPT has access to the brain via MCP and should read relevant documents before engaging on any topic.

ChatGPT's responsibilities:
- Idea exploration and development
- Strategy conversations
- Writing handoff briefs for Claude Code and Codex (see `[[handoff_protocol]]`)
- Processing raw thoughts into structured ideas
- Reviewing completion reports and helping formulate brain updates

ChatGPT does NOT execute code builds. If a conversation leads to a build requirement, ChatGPT's job is to produce a handoff brief, not to attempt the build.

### Claude (Chat) — The Strategist and Architect

Claude handles complex reasoning, system architecture, document creation, and strategic analysis. Claude also builds non-code deliverables: documents, spreadsheets, presentations, research, and system design.

Claude's responsibilities:
- System architecture and design decisions
- Document creation (Word docs, spreadsheets, markdown)
- Brain audits and structural work
- Complex analysis and reasoning
- Strategic planning when depth is needed beyond conversation

### Claude Code — The Heavy Lifter

Claude Code executes large code builds: multi-file implementations, architecture changes, codebase documentation, and anything that requires working across many files simultaneously.

Claude Code's responsibilities:
- Multi-file code implementations
- Architecture builds and refactors
- Codebase scanning and documentation
- Any build task that touches more than 3 files

Claude Code receives handoff briefs, executes, and produces completion reports. It does not make strategic decisions — those are made upstream by Valken with ChatGPT or Claude.

### Codex — The Precision Tool

Codex handles focused, well-scoped code tasks: single-file edits, small implementations, bug fixes, and any work where the scope is clearly defined and contained.

Codex's responsibilities:
- Single-file or few-file code edits
- Bug fixes with known location
- Small feature implementations
- Well-defined, scoped tasks

Same protocol as Claude Code: receives a brief, executes, produces a completion report.

### Brain Manager GPT — The Librarian

A custom GPT whose sole job is maintaining the vault. It ingests completion reports and produces brain updates: new documents, updated documents, superseded documents, and verified links.

The Brain Manager GPT's responsibilities:
- Processing completion reports into brain documents
- Maintaining frontmatter consistency
- Managing related links and bidirectional linking
- Flagging orphaned or stale documents
- Ensuring every output from every model gets captured in the brain

See `[[brain_update_protocol]]` for its full operating instructions.

### Local LLM (8B) — The Watchman (Future)

Currently a knowledge search tool and future brain health monitor. The local LLM has RAG access to the brain and can answer queries about what exists in the vault. It does not generate briefs, make decisions, or route work. Its role expands when hardware upgrades allow running larger models.

## The Rules

### One Chat, One Goal, One Report

Every conversation with every AI model is a contained event. One conversation has one clear objective. When the objective is met, the conversation produces one output (the work) and one report (the documentation of what was done). The report goes to the Brain Manager GPT for processing into the vault.

This rule exists to prevent knowledge from being trapped in chat logs. If it's not in the brain, it doesn't exist.

### Granularity Over Batching

Tasks sent to executors (Claude Code, Codex) should be granular — one thing to accomplish per session. This produces clean completion reports, clean brain updates, and makes it easy to track what changed. Batching five changes into one session produces messy reports and unclear brain updates.

### The Brain Is Always Current

Every state change produces a document. An idea becomes an idea report. A developed concept becomes a knowledge document. A build produces a completion report. A decision produces a decision document. If something changed and the brain doesn't reflect it, the system is failing.

### No Re-Explanation

The brain exists so that Valken never has to re-explain context. If a model asks Valken to explain something that should be in the brain, either the model hasn't read the brain properly or there's a gap in the documentation. Both are problems to fix, not acceptable states.

### Gate on Uncertainty

Every AI model follows this rule: if you cannot find the information you need in the brain, say so. State what you found and what's missing. Do not guess, do not fabricate, do not infer from incomplete data. Missing information is a signal to pause and fill the gap, not to proceed with assumptions.

## How Valken Communicates

Valken thinks out loud and refines as he goes. He values collaborators who track evolving decisions without requiring re-explanation. He prefers structured deliverables: Word documents, Google Sheets, markdown files — not React apps or complex interactive tools. He wants push-back on overly complex solutions. He breaks work into phased builds gated by revenue milestones.

## Preferred Output Formats

- Business documents: Word (.docx) or markdown (.md)
- Data and tracking: Google Sheets or Excel (.xlsx)
- Code: Direct implementation in the repo
- System design: Markdown documents in the brain
- Never: React applications for non-product deliverables
