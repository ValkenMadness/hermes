---
title: ai_resource_management
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [operations, ai, workflow]
supersedes: ""
related: ["[[claude_project_structure]]", "[[session_protocol]]", "[[workforce_model]]", "[[automation_architecture]]", "[[development_workflow]]"]
---

Claude Pro has daily usage limits. The type of work RMM requires — deep technical conversations with large context — burns through limits fast. This is the most critical operational constraint.

**Rule 1 — Classify before starting.** Heavy (formula, architecture, analysis) vs medium (content, email, research) vs Claude Code (separate pool) vs no AI.

**Rule 2 — Compress context documents.** Maintain condensed "Current State" documents. Full logs stay as archives.

**Rule 3 — Claude Code has a separate usage pool.** Use it for well-defined implementation tasks.

**Rule 4 — Batch heavy work.** Plan before opening a conversation. Get everything in one go.

**Rule 5 — Build templates aggressively.** Save every repeatable output as a template.

**Rule 6 — "Claude unavailable" plan for each workstream.** Queue: photography, route running, community engagement, content editing, financial tracking, partnership research.

### Local AI (Ollama) — Assessment `[FUTURE]`

Do not invest before launch. Revisit when: (a) a specific high-volume, low-complexity task is consuming Claude capacity, and (b) hardware can run a model at acceptable speed. Use Ollama with Mistral 7B or Llama 3 8B for structured generation only. Never for quality-critical work.
