---
title: domain-map
domain: system
type: knowledge
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude
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
- **Current vault location**: `rmm/`
- **Note count**: ~97 notes across 10 subdirectories
- **Migration complexity**: HIGH
- **Migration priority**: Migrated in sub-domain batches (see priority order below)
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
- **Current vault location**: `_system/`
- **Note count**: 12 (6 documents + 6 templates)
- **Migration complexity**: LOW
- **Migration priority**: First (becomes the Hermes governance layer itself)
- **Note archetypes**: knowledge, template
- **Example units**:
  - One note = one governance protocol (e.g., `handoff_protocol.md`)
  - One note = one operational template (e.g., `template_handoff.md`)
- **Cross-domain dependencies**: Referenced by all other domains.

### Operations (Work Pipeline)

- **Hermes location**: `40-operations/`
- **Current vault location**: `_work/`
- **Note count**: 9 handoff briefs + 2 RMM-specific handoffs (in `rmm/_work/_handoffs/`)
- **Migration complexity**: LOW
- **Migration priority**: Second (merged into `40-operations/handoffs/`)
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

## RMM Sub-Domain Migration Priority Order

Since RMM is the only populated content domain, it is migrated in sub-domain batches, smallest and most self-contained first:

| Priority | RMM Sub-Domain | Note Count | Rationale |
|----------|---------------|------------|-----------|
| 1 (PoC) | `overview/` | 9 | Brand/identity notes. Self-contained, low risk, validates the full migration process |
| 2 | `legal/` | 3 | Tiny, completely self-contained, minimal cross-references |
| 3 | `open_questions/` | 1 | Single note, trivial migration |
| 4 | `finance/` | 4 | Small, structured, low cross-domain dependency |
| 5 | `decisions/` | 8 | Self-contained register + sub-documents. Important reference material |
| 6 | `strategy/` | 13 | Moderate complexity, some cross-domain references to product |
| 7 | `product/` | 20 | Complex formula specifications, significant cross-references |
| 8 | `operations/` | 17 | Includes master task list (the operational heartbeat). Needs careful handling |
| 9 | `codebase/` | 20 | Most complex — detailed technical docs, most recently updated, highest cross-reference density |

**Special handling notes**:
- `master_task_list.md` (in `operations/`) is a 275-task living document. Do NOT split. Migrate as a single unit.
- `website_architecture.md` (in `codebase/`) is a 500+ line technical reference. Do NOT split. Migrate as a single unit.
- RMM also has its own `_work/_handoffs/` (2 notes) — these merge into `40-operations/handoffs/` during migration.
