---
title: handoff-protocol
domain: system
type: knowledge
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude
tags: [system, process, handoff, protocol]
supersedes: ""
related: ["[[decision-log]]", "[[git-governance]]", "[[metadata-schema]]"]
---

# Hermes Handoff Protocol

This document defines how work moves between AI sessions, between AI models, and between planning and execution. It merges the existing vault's handoff protocol (proven in production across RMM build sessions) with Hermes governance additions.

---

## Core Principle

Every AI session is a contained event: one conversation, one goal, one result, one report. Nothing lives only in chat history. If it's not in Hermes, it doesn't exist.

---

## 1. Session Summary Protocol

Every AI session producing actionable output generates a session summary committed to `90-logs/sessions/`.

### Naming Convention

```
YYYY-MM-DD-[agent]-[topic].md
```

Examples:
- `2026-05-26-claude-hermes-viability-assessment.md`
- `2026-05-27-chatgpt-rmm-architecture-review.md`
- `2026-05-28-claude-code-automation-script.md`

### Session Summary Template

```yaml
---
date: YYYY-MM-DD
agent: "claude | chatgpt | claude_code | claude_cowork | brain_manager_gpt | local_llm"
domain: "domain worked on"
type: session-summary
status: active
created: YYYY-MM-DD
updated: YYYY-MM-DD
updated_by: "agent name"
tags: [session-summary]
supersedes: ""
related: []
---
```

```markdown
# Session Summary — [Topic]

## What Was Done
[Bullet list of concrete actions taken]

## Decisions Made
[Reference decision log IDs or note new decisions for the log]

## Open Questions
[Unresolved items for next session]

## Files Modified
[List of files created, edited, or moved]

## Next Steps
[What should happen next, and which agent is best positioned for it]
```

---

## 2. Handoff Brief Protocol

When a planning session determines that work needs to go to an executor, a handoff brief is produced. The brief must contain everything the executor needs to do the work without asking questions.

### Handoff Brief Template

```markdown
# Handoff Brief: [Clear Descriptive Title]

## Objective
One sentence. What needs to happen.

## Background
Why this work is being done. What led to this decision. 2-3 sentences maximum.

## Executor
Who should do this work and why.

## Hermes Context Files
List every Hermes document the executor should read before starting:
- [[document_one]] — why it's relevant
- [[document_two]] — why it's relevant

## Repo Files (if applicable)
List specific files in the codebase the executor needs to examine or edit:
- `path/to/file.js` — what to look at or change

## Specifications
Detailed requirements. Be precise:
- Current behaviour
- Desired behaviour
- Constraints and rules
- Locked decisions that must not be changed

## Acceptance Criteria
Specific, verifiable outcomes. Not vague ("works well" is not a criterion).

## Do NOT
Anything the executor must avoid.
```

### Brief Quality Rules

1. The brief must be self-contained. The executor should not need to ask for clarification.
2. Every Hermes document referenced must exist in the vault.
3. Every repo file referenced should include the actual file path.
4. Acceptance criteria must be specific and testable.
5. If context is missing, state what's missing rather than guessing.

### Handoff Brief Frontmatter

```yaml
---
title: "handoff_[descriptive_name]"
domain: "relevant domain"
type: handoff
status: "active | complete"
created: YYYY-MM-DD
updated: YYYY-MM-DD
updated_by: "authoring agent"
tags: [handoff]
supersedes: ""
related: ["[[relevant_docs]]"]
from_model: "chatgpt | claude | claude_cowork"
to_model: "claude_code | codex | brain_manager_gpt"
---
```

Active handoff briefs are saved to `40-operations/handoffs/`. When work is complete and the completion report is processed, set status to `complete`.

---

## 3. Agent Pre-Read Requirements

Before starting work, any AI agent operating in Hermes should read:

1. `00-system/decision-log.md` — current architectural state and recent decisions
2. The relevant domain `INDEX.md` — domain topology and retrieval guidance
3. The most recent session summary for that domain — where work left off
4. Its own manifest in `30-agents/` — its permissions and responsibilities

This is not optional. Skipping the pre-read risks duplicating work, violating locked decisions, or breaking architectural coherence.

---

## 4. Executor Routing

| Route to Claude Code when... | Route to Codex when... |
|------------------------------|------------------------|
| Task touches 4+ files | Task is 1-3 files |
| Architecture change needed | Implementation within existing architecture |
| New feature spanning multiple systems | Bug fix or small feature in known location |
| Codebase documentation needed | Styling or copy changes |
| Refactoring across components | Well-scoped, clearly defined edit |

When in doubt, route to Claude Code. Overscoping wastes some capacity. Underscoping risks a failed session.

---

## 5. Completion Report Protocol

Every executor produces a completion report after finishing work. The completion report goes to the Brain Manager GPT (or equivalent) for vault updates.

### Completion Report Structure

```markdown
# Completion Report: [Title]

## What Was Done
[Specific actions taken, files created/modified]

## Brain Updates Required
[New documents to create, existing documents to update, status changes to make]

## Decisions Made During Execution
[Any decisions made that need to be logged]

## Issues Encountered
[Problems found, workarounds applied, things that need follow-up]

## Verification
[How the work was verified — tests run, manual checks, screenshots]
```

---

## 6. Git Commit Message Format

All commits to the Hermes repository follow this format:

```
[agent:name] [domain:name] Brief description

Examples:
[agent:claude] [domain:rmm] Normalized frontmatter for 12 overview notes
[agent:human] [domain:system] Updated metadata schema with retrieval-priority field
[agent:chatgpt] [domain:system] Revised agent manifest template
[agent:claude-cowork] [domain:rmm] Migrated codebase subdomain (20 notes)
```

---

## 7. The Two-AI Dynamic

Hermes is co-architected by Claude and ChatGPT. The decision log is the primary mitigation against architectural drift between them. After each major session with either AI:

1. Commit output to Hermes
2. Record decisions by ID in the decision log
3. The other AI reads committed decisions, not pasted documents

This prevents the "human integration bus" problem — where Valken manually relays context between AI systems.
