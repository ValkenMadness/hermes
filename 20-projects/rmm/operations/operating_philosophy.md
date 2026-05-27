---
title: operating_philosophy
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [operations, philosophy, principles]
supersedes: ""
related: ["[[core_principles]]", "[[development_workflow]]", "[[knowledge_continuity]]", "[[document_architecture]]"]
---

### The Solo Founder Reality

RMM is built and operated by one person — V. There is no team. There is no funding. Every hour on operations is an hour not on product or community. The workforce system makes one person operate like a small team.

Three principles:

1. Every function handled by the cheapest capable resource. If a script can do it, an AI should not. If an AI can do it, V should not.
2. Systems built once and reused forever. Templates over individual outputs. Scripts over manual processes.
3. Graceful degradation. If Claude is down, the business continues. Nothing is a single point of failure except V's strategic decisions.

### The Cost Hierarchy

**Tier 0 — Free automation (scripts, cron jobs, templates).** Zero marginal cost. Handles everything deterministic.

**Tier 1 — Claude (Pro subscription).** Fixed monthly cost with daily usage limits. Primary AI for strategy, architecture, content, code, analysis. Three interfaces: Claude.ai conversations, Claude Projects, Claude Code (separate usage pool).

**Tier 2 — API calls and external services.** Variable cost. Elevation API, OAuth, email, hosting.

**Tier 3 — V's time.** The most expensive resource. V should only do: strategic decisions, community relationships, creative direction, quality review.

### Build Philosophy

**AI is a tool, not a colleague.** Receives input, produces output, output is reviewed.

**Systems over intelligence.** A dumb system that runs reliably beats a smart AI that fails unpredictably.

**Memory is architecture, not magic.** Memory is built through documents — project instructions, formula logs, reference docs, templates.
