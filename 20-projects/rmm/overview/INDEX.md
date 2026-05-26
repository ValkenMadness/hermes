---
title: index_rmm_overview
domain: rmm
type: domain-index
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude_cowork
tags: [domain-index]
supersedes: ""
related: ["[[index-template]]"]
---

# RMM Overview — Domain Index

## Overview

Brand identity, origin story, and strategic positioning for Run Mad Maps. These notes define what RMM is, why it exists, who built it, and what makes it defensible. This is the narrative layer — the "why" behind everything technical.

## Note Archetypes

- **Brand notes**: Visual identity elements (colour, typography, voice) — short, definitive, rarely changed
- **Narrative notes**: Origin story, problem statement, solution — longer, storytelling, stable once written
- **Strategic notes**: Moats, flywheel, founder context — analytical, referenced by strategy domain

## Contents

| Note | Type | Status | Updated | Summary |
|------|------|--------|---------|---------|
| [[colour_pallet]] | knowledge | active | 2026-04-30 | Four-colour system with usage weights (Dark Olive 50%, White 30%, Papaya 15%, Sunset 5%) |
| [[typography]] | knowledge | active | 2026-04-23 | ValkenMadness for headlines only, supporting fonts for everything else |
| [[voice]] | knowledge | active | 2026-04-23 | Brand voice: authoritative not arrogant, specific not vague. Yes/No word lists |
| [[the_founder]] | knowledge | active | 2026-04-23 | Valken de Villiers — Senior Designer, sole founder, AI-assisted build methodology |
| [[the_origin]] | knowledge | active | 2026-04-23 | Born from frustration with generic tools on Peninsula terrain |
| [[the_problem]] | knowledge | active | 2026-04-23 | Five specific failures of existing platforms for Peninsula athletes |
| [[the_solution]] | knowledge | active | 2026-04-23 | Four interconnected formula systems + live interactive map |
| [[the_four_strategic_moats]] | knowledge | active | 2026-04-23 | Hyper-local data, proprietary engine, GPS-verified anti-gaming, community trust |
| [[the_product_flywheel]] | knowledge | active | 2026-04-23 | Data → calibration → accuracy → trust → athletes → events → data loop |

## Cross-Domain Dependencies

- `colour_pallet` and `typography` reference notes in `rmm/codebase/` (website styling) — these will resolve once `codebase/` is migrated
- `the_four_strategic_moats` references notes in `rmm/strategy/` and `rmm/legal/` — will resolve during those migrations
- `the_solution` references product vision in `rmm/product/` — will resolve during product migration

## Retrieval Guidance

For AI agents: if you need to understand what RMM is and why it exists, read `the_problem` then `the_solution`. For brand voice decisions, read `voice`. For visual identity, read `colour_pallet` and `typography`. For competitive positioning, read `the_four_strategic_moats`. The `the_product_flywheel` note is a single paragraph — read it, it takes 10 seconds.
