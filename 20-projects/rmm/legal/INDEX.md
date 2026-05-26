---
title: index_rmm_legal
domain: rmm
type: domain-index
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude_cowork
tags: [domain-index]
supersedes: ""
related: []
---

# RMM Legal — Domain Index

## Overview

Legal compliance, intellectual property protection, and API agreement obligations for Run Mad Maps. These are living documents that must be kept current as the platform evolves — especially the IP protection note, which tracks an active remediation issue.

## Note Archetypes

- **Compliance notes**: Regulatory requirements and implementation status (POPIA, OAuth)
- **IP notes**: Trade secret protection, exposure tracking, remediation plans

## Contents

| Note | Type | Status | Updated | Summary |
|------|------|--------|---------|---------|
| [[popia_compliance]] | knowledge | active | 2026-04-23 | POPIA requirements: data collection, deletion rights, documentation needed pre-launch |
| [[ip_protection]] | knowledge | active | 2026-05-22 | Trade secret status. CRITICAL: 6 formula files exposed in git history — remediation pending (NEW-46) |
| [[oauth_and_api_compliance]] | knowledge | active | 2026-05-22 | Strava/Garmin API terms. CRITICAL: OAuth state CSRF vulnerability documented (NEW-48) |

## Cross-Domain Dependencies

- `ip_protection` references `the_four_strategic_moats` in overview (moat 2 = proprietary engine)
- `oauth_and_api_compliance` references `data_architecture` in product
- Both security-updated notes reference `security_audit_findings_2026_05_22` (will be in codebase when migrated)

## Retrieval Guidance

For AI agents: if you need to understand what RMM can and cannot do with user data, read `popia_compliance`. If you're touching anything related to formula values or env vars, read `ip_protection` first — there's an active exposure issue. If you're working on auth or Strava integration, read `oauth_and_api_compliance` — there's an unpatched CSRF vulnerability.
