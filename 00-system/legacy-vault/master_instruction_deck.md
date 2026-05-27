---
title: master_instruction_deck
domain: system
type: knowledge
status: active
created: 2026-04-24
updated: 2026-04-24
updated_by: claude
tags: [system, instructions, master]
supersedes: ""
related: ["[[ways_of_working]]", "[[handoff_protocol]]", "[[completion_report_protocol]]", "[[brain_update_protocol]]"]
---

# Master Instruction Deck

This is the first document any AI model should read when working with Valken or the RMM system. It explains what the brain is, how it's structured, and how to operate within it.

## What This System Is

This Obsidian vault is the single source of truth for Valken's business (Run Mad Maps) and personal projects. Every AI model that works with Valken is stateless — it has no memory between sessions. This vault provides continuity. Before doing any work, read the relevant documents from this vault to understand the current state of things.

The vault is connected to AI models via MCP (Model Context Protocol). You can read, search, and write to it directly.

## Who Valken Is

Sole founder of Run Mad Maps (RMM), a hyper-local trail intelligence platform for the Cape Peninsula. Senior Designer and Art Director by background. Based in South Africa. Builds with AI as his workforce — no traditional development team.

## What Run Mad Maps Is

A trail running intelligence platform built on four proprietary formula systems: GPS Stream Processor, Route Grading System V3, Runner Performance Score (RPS), and Race Readiness Engine. The platform is a live interactive map of the Cape Peninsula with trail data, route grading, and athlete performance tracking. The production stack is Vanilla JavaScript frontend (not React), Vercel serverless functions, Supabase (PostgreSQL), and Mapbox GL JS.

For full detail, read documents in `rmm/overview/` and `rmm/product/`.

## Vault Structure

```
brain/
├── _system/              ← You are here. System config, instructions, templates
├── _work/                ← Active tasks, handoffs, inbox
│   ├── _handoffs/        ← Coordination files between AI models
│   ├── _inbox/           ← Quick capture, unsorted
│   └── _tasks/           ← Tracked work items
├── rmm/                  ← Run Mad Maps business
│   ├── overview/         ← What RMM is, brand, founder
│   ├── product/          ← Platform features, formulas, map system
│   ├── decisions/        ← Locked decisions with reasoning
│   ├── operations/       ← Processes, workflows, AI management
│   ├── strategy/         ← Market positioning, revenue, growth
│   ├── finance/          ← Business model, revenue, costs
│   ├── legal/            ← POPIA, IP, OAuth compliance
│   ├── open_questions/   ← Unresolved items
│   └── codebase/         ← Technical documentation of the builds
├── cyberdeck/            ← Hardware builds
├── personal/             ← Personal life
├── ideas/                ← Idea capture
├── finance/              ← Personal finances
├── learning/             ← Study and learning
├── writing/              ← Content and copywriting
├── local_ai/             ← Local LLM and infrastructure notes
└── archive/              ← Superseded documents
```

## Frontmatter Convention

Every file has YAML frontmatter. This is how the system is machine-readable. Always preserve and maintain frontmatter when editing files.

```yaml
---
title: "matches_the_filename_exactly"
domain: "rmm | cyberdeck | personal | system | finance | ideas"
type: "knowledge | decision | task | handoff | idea | log"
status: "active | complete | archived | superseded"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
updated_by: "valken | claude | claude_code | codex | chatgpt | local_llm"
tags: ["hyphenated-tags", "no-ampersands"]
supersedes: ""
related: ["[[properly_linked]]", "[[with_commas]]"]
---
```

Rules: titles match filenames exactly. Filenames are lowercase_with_underscores. Tags use hyphens. Related uses proper YAML array syntax with commas. No self-referencing in related. No duplicate tags. When you edit a file, update the `updated` date and `updated_by` field.

## AI Model Roles

Read `[[ways_of_working]]` for full detail. Summary:

| Model | Role |
|-------|------|
| ChatGPT | Thinking partner, brief writer, idea development |
| Claude (chat) | Strategist, architect, document builder, system design |
| Claude Code | Code executor for large multi-file builds |
| Codex | Code executor for focused scoped tasks |
| Brain Manager GPT | Vault maintainer — ingests reports, manages frontmatter and links |
| Local LLM (8B) | Knowledge search and brain health monitoring (future) |

## How Work Flows

Read `[[handoff_protocol]]` and `[[completion_report_protocol]]` for full detail. Summary:

1. Valken and ChatGPT discuss and develop ideas or identify work
2. ChatGPT produces a handoff brief using brain context
3. The brief goes to the appropriate executor (Claude Code or Codex)
4. The executor does the work and produces a completion report
5. The completion report goes to the Brain Manager GPT
6. The Brain Manager GPT updates the vault — new docs, updated docs, superseded docs
7. The vault is now current for the next cycle

Every chat is a contained event: one conversation, one goal, one result, one report. Nothing lives only in chat history.

## Non-Negotiable Principles

1. **60-second rule.** If any artifact in this system takes longer than 60 seconds to create, the system is too complex.
2. **Self-contained documents.** Every file makes sense on its own. 500-2,000 words optimal.
3. **The brain is the master.** If it's not in the brain, it doesn't exist.
4. **AI models are stateless.** Read the brain for context. Write back to the brain when done.
5. **Nothing is deleted.** Old versions get `status: superseded` with a link to the replacement.
6. **One chat, one goal, one report.** Every session with every AI model produces exactly one output and one report.

## What to Do If You're Unsure

If you cannot find a document in the brain that covers what you need, say so. Do not guess filenames, do not invent context, do not fabricate information. Instead, tell Valken what you found and what's missing. Missing documentation is a gap to be filled, not a gap to be papered over with hallucination.
