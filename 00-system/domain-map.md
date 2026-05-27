---
title: domain-map
domain: system
type: knowledge
status: active
created: 2026-05-26
updated: 2026-05-27
updated_by: claude_cowork
tags: [system, domain-map, architecture]
supersedes: ""
related: ["[[metadata-schema]]", "[[index-template]]", "[[decision-log]]"]
---

# Hermes Domain Map

This document defines every knowledge domain in Hermes, its location, note archetypes, estimated migration scope, and priority order. Based on the vault audit performed 2026-05-26 against the live Obsidian vault.

## Design Principle: One Note = One Coherent Operational Unit

This principle is correct but must be defined per domain. Different domains operate at different granularities. A trail data profile is different from a service runbook is different from a strategic decision document. Example units are defined per domain below.

**Warning against over-atomization**: Once people discover "smaller notes improve retrieval," they often oversplit. This creates fragmented cognition, excessive navigation, and broken narrative continuity. Some ideas REQUIRE large cohesive narrative structures. Optimize for operational cognition, not maximum retrieval atomization.

---

## Active Domains

### RMM (Run Mad Maps)

- **Hermes location**: `20-projects/rmm/`
- **Source vault location**: `rmm/`
- **Note count**: 95 notes across 9 subdirectories (+ 9 INDEX files)
- **Migration status**: COMPLETE (2026-05-26)
- **Migration priority**: Migrated in sub-domain batches (see order below)
- **Note archetypes**: knowledge, decision, handoff, operations, task
- **Example units**:
  - One note = one complete system specification (e.g., `runner_performance_score_rps.md`)
  - One note = one locked decision register (e.g., `locked_decisions_register.md`)
  - One note = one operational status document (e.g., `master_task_list.md`)
- **Cross-domain dependencies**: Minimal external dependencies (self-contained project). Internal cross-references are extensive.
- **Internal subdirectories to preserve**:
  - `codebase/` (20 notes) — website architecture, map system, formula lab, security
  - `product/` (20 notes) — RPS, route grading, trail ecosystem, UX
  - `operations/` (17 notes) — task list, workflows, AI management
  - `strategy/` (13 notes) — market, revenue, risk, build phases
  - `overview/` (9 notes) — brand identity, founder, origin story
  - `decisions/` (8 notes) — locked decisions register + sub-documents
  - `finance/` (4 notes) — revenue streams, costs, partnerships
  - `legal/` (3 notes) — POPIA, IP, OAuth compliance
  - `open_questions/` (1 note) — master unresolved items list

### System (Governance Layer)

- **Hermes location**: `00-system/`
- **Source vault location**: `_system/`
- **Note count**: 13 governance docs + 6 templates
- **Migration status**: COMPLETE (2026-05-26)
- **Note archetypes**: knowledge, template
- **Example units**:
  - One note = one governance protocol (e.g., `handoff_protocol.md`)
  - One note = one operational template (e.g., `template_handoff.md`)
- **Cross-domain dependencies**: Referenced by all other domains.

### Operations (Work Pipeline)

- **Hermes location**: `40-operations/`
- **Source vault location**: `_work/`
- **Note count**: 11 handoff briefs (merged from `_work/_handoffs/` and `rmm/_work/_handoffs/`)
- **Migration status**: COMPLETE (2026-05-26)
- **Note archetypes**: handoff
- **Cross-domain dependencies**: Handoffs reference RMM documents.

---

## Placeholder Domains (Empty — Future Content)

These directories exist in the current vault but contain zero notes. They represent intent. In Hermes, they receive placeholder READMEs and are populated when content is naturally created.

| Domain | Hermes Location | Purpose | When to Populate |
|--------|----------------|---------|-----------------|
| Personal | `10-domains/personal/` | Personal life systems (gardening, diving, yoga, preparedness) | When Valken creates content about these topics |
| Finance | `10-domains/finance/` | Personal financial tracking and planning | When financial documentation is needed |
| Cyberdeck | `10-domains/cyberdeck/` | Hardware builds, homelab, infrastructure | When hardware/homelab projects begin |
| Learning | `10-domains/learning/` or `50-skills/` | Study materials, skill development, courses | When learning documentation is created |
| Ideas | `10-domains/ideas/` | Idea capture, concept exploration | When ideas need structured documentation |
| Writing | `10-domains/writing/` | Content creation, copywriting, blog posts | When creative writing content is developed |
| Local AI | `10-domains/local-ai/` | Local LLM infrastructure, model notes | When local AI infrastructure is set up |

---

## RMM Sub-Domain Migration Record

All sub-domains migrated 2026-05-26 in a single session, smallest-first ordering:

| Order | RMM Sub-Domain | Notes | Status |
|-------|---------------|-------|--------|
| 1 (PoC) | `overview/` | 9 | COMPLETE |
| 2 | `legal/` | 3 | COMPLETE |
| 3 | `open_questions/` | 1 | COMPLETE |
| 4 | `finance/` | 4 | COMPLETE |
| 5 | `decisions/` | 8 | COMPLETE |
| 6 | `strategy/` | 13 | COMPLETE |
| 7 | `product/` | 20 | COMPLETE |
| 8 | `operations/` | 17 | COMPLETE |
| 9 | `codebase/` | 20 | COMPLETE |

**Post-migration notes**:
- `master_task_list.md` migrated intact as a single unit (275+ tasks)
- `website_architecture.md` migrated intact (500+ lines)
- RMM `_work/_handoffs/` (2 notes) merged into `40-operations/handoffs/`
- Every sub-domain received an INDEX.md with categorized listings
- Frontmatter health check passed (2026-05-27): 131 notes, 0 critical issues
