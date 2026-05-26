---
title: decision-log
domain: system
type: knowledge
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude
tags: [system, decisions, governance]
supersedes: ""
related: ["[[domain-map]]", "[[metadata-schema]]", "[[handoff-protocol]]", "[[git-governance]]"]
---

# Hermes Decision Log

All architectural and operational decisions recorded here. Entries are append-only. Decisions can be superseded but not deleted.

---

## Decision Register

| Date | ID | Decision | Agent | Rationale | Status |
|------|----|----------|-------|-----------|--------|
| 2026-05-26 | D-001 | Hermes architecture adopted as the operational cognition substrate for Valken's knowledge management | human + claude + chatgpt | AI workflow problem (conversation isolation, token constraints, vendor dependency) requires a user-owned, provider-agnostic substrate | approved |
| 2026-05-26 | D-002 | Metadata schema v1 adopted — extends existing vault conventions rather than replacing them | claude | Vault audit confirmed existing frontmatter (updated_by, related, supersedes) is strong and consistent across 120 notes. Renaming creates unnecessary churn. | approved |
| 2026-05-26 | D-003 | `rmm/overview/` selected as proof-of-concept migration domain (9 notes) | claude | Under 30 notes, self-contained brand/identity content, exercises all migration operations, low operational risk. Non-RMM domains are empty — no alternative PoC exists. | approved |
| 2026-05-26 | D-004 | RMM migrated in sub-domain batches (smallest first) rather than as monolithic domain | claude | Vault is 97% RMM (~97 notes). Original plan's multi-domain incremental approach impossible since other domains are empty. Sub-domain batching preserves the incremental philosophy. | approved |
| 2026-05-26 | D-005 | Existing governance documents (_system/) absorbed and extended, not replaced | claude | Vault audit found master_instruction_deck, handoff_protocol, brain_health_checklist, completion_report_protocol, and ways_of_working are operationally strong. Hermes extends these rather than writing from scratch. | approved |
| 2026-05-26 | D-006 | Hermes root directory: `E:\20 - Project Hermes` | human | Valken selected the location via Cowork folder picker. | approved |
| 2026-05-26 | D-007 | Five agent manifests created: claude, chatgpt, claude-code, claude-cowork, brain-manager-gpt | claude | Vault audit found Brain Manager GPT and Claude Cowork are active agents in the existing workflow but were missing from the original plan's three manifests. | approved |
| 2026-05-26 | D-008 | Hermes created as a separate vault (not in-place restructure) with legacy vault backed up | human + claude | Non-destructive approach. Legacy vault stays intact as safety net. Git initializes on the clean Hermes structure from day 1. | approved |

---

## How to Add Decisions

Append a new row to the register. Every architectural or operational decision gets recorded here, no matter how small. Include:

- **Date**: When the decision was made
- **ID**: Sequential (D-NNN)
- **Decision**: What was decided (one sentence)
- **Agent**: Who made or proposed the decision
- **Rationale**: Why (one sentence)
- **Status**: `proposed` → `approved` → `implemented` → `superseded`

Decisions move from `proposed` to `approved` only with human confirmation. Decisions are never deleted — superseded decisions get a new entry with a reference to what replaced them.
