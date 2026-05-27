---
title: handoff_protocol
domain: system
type: knowledge
status: active
created: 2026-04-24
updated: 2026-04-24
updated_by: claude
tags: [system, process, handoff]
supersedes: ""
related: ["[[master_instruction_deck]]", "[[ways_of_working]]", "[[completion_report_protocol]]", "[[brain_update_protocol]]"]
---

# Handoff Protocol

This document defines exactly how work moves from ideation to execution across AI models.

## The Flow

```
Valken + ChatGPT (or Claude)
        │
        ▼
   Develop the idea or identify the work
        │
        ▼
   ChatGPT writes a handoff brief
   (using brain context via MCP)
        │
        ▼
   Valken reviews the brief
        │
        ▼
   Brief goes to the executor
   (Claude Code or Codex)
        │
        ▼
   Executor does the work
        │
        ▼
   Executor produces a completion report
        │
        ▼
   Completion report goes to Brain Manager GPT
        │
        ▼
   Brain Manager GPT updates the vault
```

## The Handoff Brief

When ChatGPT (or Claude) determines that a piece of work needs to go to an executor, it produces a handoff brief. The brief must contain everything the executor needs to do the work without asking questions.

### Brief Structure

```
# Handoff Brief: [Clear descriptive title]

## Objective
One sentence. What needs to happen.

## Background
Why this work is being done. What led to this decision. 2-3 sentences maximum.

## Executor
Who should do this work: Claude Code or Codex.
Include reasoning: "Claude Code because this touches 5+ files" or "Codex because this is a single-file edit with clear scope."

## Brain Context Files
List every brain document the executor should read before starting:
- [[document_one]] — why it's relevant
- [[document_two]] — why it's relevant

## Repo Files
List specific files in the codebase the executor needs to examine or edit:
- `path/to/file.js` — what to look at or change
- `path/to/another.js` — what to look at or change

## Specifications
Detailed requirements for the work. Be precise:
- What the current behaviour is
- What the desired behaviour is
- Any constraints or rules to follow
- Any decisions that are locked and must not be changed (reference decision docs)

## Acceptance Criteria
How do we know this is done? List specific, verifiable outcomes.

## Do NOT
Anything the executor must avoid. Locked decisions, files not to touch, patterns not to break.
```

### Brief Quality Rules

1. The brief must be self-contained. The executor should not need to ask Valken for clarification.
2. Every brain document referenced must exist in the vault.
3. Every repo file referenced should include the actual file path.
4. Acceptance criteria must be specific and testable, not vague ("works well" is not a criterion).
5. If the brief writer cannot determine all the context needed, they should state what's missing rather than guessing.

## Routing: Claude Code vs Codex

| Route to Claude Code when... | Route to Codex when... |
|------------------------------|------------------------|
| Task touches 4+ files | Task is 1-3 files |
| Architecture change needed | Implementation within existing architecture |
| New feature spanning multiple systems | Bug fix or small feature in known location |
| Codebase documentation needed | Styling or copy changes |
| Refactoring across components | Well-scoped, clearly defined edit |

When in doubt, route to Claude Code. Overscoping to Claude Code wastes some capacity. Underscoping to Codex risks a failed session when it discovers the task is bigger than briefed.

## What the Executor Does

1. Reads the handoff brief completely before starting.
2. Reads all referenced brain context files.
3. Examines all referenced repo files.
4. If anything in the brief is unclear or contradictory, asks Valken before proceeding — do not assume.
5. Executes the work.
6. Produces a completion report (see `[[completion_report_protocol]]`).

## Saving the Handoff

Handoff briefs that are actively in progress should be saved to `_work/_handoffs/` in the brain with the following frontmatter:

```yaml
---
title: "handoff_[descriptive_name]"
domain: "rmm"
type: "handoff"
status: "active"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
updated_by: "chatgpt"
tags: ["handoff"]
supersedes: ""
related: ["[[relevant_docs]]"]
from_model: "chatgpt"
to_model: "claude_code"
---
```

When the work is complete and the completion report is processed, set the handoff's status to `complete`.
