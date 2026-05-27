---
title: completion_report_protocol
domain: system
type: knowledge
status: active
created: 2026-04-24
updated: 2026-04-24
updated_by: claude
tags: [system, process, completion-report]
supersedes: ""
related: ["[[master_instruction_deck]]", "[[ways_of_working]]", "[[handoff_protocol]]", "[[brain_update_protocol]]"]
---

# Completion Report Protocol

Every executor (Claude Code, Codex, Claude, ChatGPT) produces a completion report when a task is finished. The completion report is the artifact that closes the loop — it feeds back into the brain via the Brain Manager GPT so the vault stays current.

## When to Produce a Completion Report

Every time. No exceptions. Every session that produces work also produces a report. If the work was exploratory and nothing changed, the report says so. If the work failed, the report documents why. The brain needs to know what happened regardless of outcome.

## Completion Report Structure

```
# Completion Report: [Clear descriptive title]

## Date
YYYY-MM-DD

## Executor
Which model did this work (claude_code, codex, claude, chatgpt).

## Objective
What was the task? Reference the handoff brief if one exists.

## Prior State
What did the system look like before this work? Reference existing brain documents where applicable:
- [[existing_doc]] described [what it described]
- The file `path/to/file.js` previously [did what]

Keep this brief. The brain already has the prior state documented — just reference it, don't reproduce it.

## What Was Done
Detailed description of the work performed:
- What was created, edited, or deleted
- Which files were touched and what changed in each
- Any decisions made during execution that weren't in the brief

## What Changed
Summary of the delta — the difference between prior state and current state:
- New files created: [list with paths]
- Files modified: [list with what changed]
- Files deleted: [list with reasoning]
- Configuration changes: [list]
- Dependencies added or removed: [list]

## Decisions Made During Execution
Any choices the executor made that weren't specified in the brief. These need to be captured because they may become locked decisions or affect future work.

## Current State
What does the system look like now? This section should be detailed enough that the Brain Manager GPT can determine which brain documents need updating.

## Brain Documents Affected
List every brain document that may need updating as a result of this work:
- [[document_name]] — what changed that affects it
- [[another_document]] — what changed that affects it

If new brain documents should be created, describe them:
- Suggested new doc: `filename.md` in `rmm/codebase/` covering [topic]

## Open Items
Anything that remains unfinished, needs follow-up, or was discovered during the work:
- [item] — what needs to happen next
- [item] — who should handle it

## Acceptance Criteria Status
Reference the acceptance criteria from the handoff brief and state whether each is met:
- [criterion 1]: Met / Not met / Partially met (explanation)
- [criterion 2]: Met / Not met / Partially met (explanation)
```

## Quality Rules for Completion Reports

1. **Be specific about file paths.** "Updated the map component" is useless. "Edited `scripts/map.js` lines 142-180, changed the popup trigger from click to hover" is useful.

2. **Reference brain documents by their wiki link names.** This lets the Brain Manager GPT map changes to existing docs.

3. **Capture decisions made during execution.** If the executor chose approach A over approach B because of a constraint discovered during the work, that decision must be in the report. It may need to become a decision document in `rmm/decisions/`.

4. **Don't reproduce the entire prior state.** The brain already has it. Reference the documents that describe it. Only include prior state detail when it helps clarify what changed.

5. **Be honest about failures.** If something didn't work, say why. A failed attempt is still information the brain needs.

6. **List open items explicitly.** If the task spawned follow-up work, that work needs to be visible so it doesn't get lost.

## What Happens to the Report

The completion report is given to the Brain Manager GPT (or to ChatGPT/Claude if the Brain Manager GPT isn't available yet). The receiving model reads the report, determines which brain documents need updating, produces the updates, and writes them back to the vault. See `[[brain_update_protocol]]` for that process.

The completion report itself is not stored in the brain permanently. It's a transient artifact — its value is extracted into brain document updates and then it can be discarded. The knowledge lives in the brain, not in the report.
