---
title: RMM Operations Index
domain: rmm
type: index
status: active
created: 2026-05-27
updated: 2026-05-27
updated_by: claude-cowork
tags: [index, operations, rmm]
supersedes: ""
related: ["[[operating_philosophy]]", "[[master_task_list]]", "[[workforce_model]]"]
---

# RMM Operations

How RMM runs day-to-day — the solo founder operating model, AI workforce coordination, development and release workflows, automation systems, incident response, and the complete task backlog. This sub-domain defines how work gets done, not what gets built.

## Contents

### Philosophy & Workforce

| Note | Description |
|------|-------------|
| [[operating_philosophy]] | Solo founder reality, three principles, cost hierarchy (Tier 0–3), build philosophy |
| [[workforce_model]] | V/Claude/Automation/Third-party split, decision framework, Claude operating model, function-to-resource assignment |
| [[ai_resource_management]] | Claude Pro usage limits, 6 rules, batch strategy, Ollama assessment |
| [[claude_project_structure]] | 5 Claude Projects — Formulas, Build, Content, Business, Legal |

### Development & Deployment

| Note | Description |
|------|-------------|
| [[development_workflow]] | 6-step proven pattern (V identifies → Claude architects → Claude Code implements → V reviews → deploy), testing & QA |
| [[release_workflow]] | Direct-to-main deploys, admin gating, feature branches for risky changes, Vercel rollback |
| [[session_protocol]] | Opening/wrap-up protocol, principles — build strong, build once |

### Knowledge & Documents

| Note | Description |
|------|-------------|
| [[knowledge_continuity]] | WRAP UP pattern, context injection, log format across all functions |
| [[document_architecture]] | Document hierarchy — Master Doc, Formula V2, Formula Log, Build Log, Brand Guide, CLAUDE.md |

### Automation & Pipelines

| Note | Description |
|------|-------------|
| [[automation_architecture]] | 8 automated systems, what doesn't get automated, automation stack (Vercel Cron, webhooks, GitHub Actions, Resend) |
| [[gps_processing_pipeline]] | 10-step pipeline from webhook to notification, failure handling, cost consideration |

### Content & Events

| Note | Description |
|------|-------------|
| [[content_and_community]] | Route description template, social media strategy, email sequences, community management, athlete support tiers |
| [[event_operations]] | Time Trial/Group Run/Timed Event types, operations workflow, leaderboard rules |

### Risk & Incidents

| Note | Description |
|------|-------------|
| [[service_failure_matrix]] | 9 services with impact/response/recovery |
| [[catastrophic_scenarios]] | V unavailable, Strava API risk, competitor response |
| [[data_level_incidents]] | Incorrect scores, data corruption, false positive handling |

### Task Tracking

| Note | Description |
|------|-------------|
| [[master_task_list]] | 275+ tasks across Phase 0 through V4, plus NEW-1 through NEW-58, ongoing tasks #261–#272. Living document — DO NOT SPLIT. Last updated 2026-05-22. |

## Cross-Domain Dependencies

- **Operations → Product**: `gps_processing_pipeline` implements the engines defined in `product/gps_stream_processor` and `product/data_integrity_and_anti_gaming`
- **Operations → Strategy**: `master_task_list` drives the roadmap defined in `strategy/phased_build_plan` and `strategy/launch_readiness_checklist`
- **Operations → Decisions**: `release_workflow` reflects decisions in `decisions/` (e.g., direct-to-main deploys)
- **Operations → Codebase**: `development_workflow` and `release_workflow` govern how code in `codebase/` gets built and deployed
- **Operations → Finance**: `operating_philosophy` cost hierarchy maps to `finance/cost_tracking`

## Retrieval Guidance

- For "how does RMM operate" → `operating_philosophy` then `workforce_model`
- For "how is code built and deployed" → `development_workflow` → `release_workflow`
- For "what's automated" → `automation_architecture` → `gps_processing_pipeline`
- For "what tasks remain" → `master_task_list` (the single source — never split)
- For "what if X breaks" → `service_failure_matrix` → `catastrophic_scenarios` → `data_level_incidents`
- For "how does V work with AI" → `ai_resource_management` → `claude_project_structure` → `session_protocol`
- For content and events → `content_and_community` → `event_operations`
