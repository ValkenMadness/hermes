---
title: index-template
domain: system
type: template
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude
tags: [system, template, index]
supersedes: ""
related: ["[[domain-map]]", "[[metadata-schema]]"]
---

# INDEX.md Template

Copy this template when creating an INDEX.md for a new domain or subdirectory. The INDEX.md is the entry point — the first thing an AI agent reads to understand what a domain contains and how to navigate it.

---

## Template

```yaml
---
title: index_[domain_name]
domain: [domain]
type: domain-index
status: active
created: YYYY-MM-DD
updated: YYYY-MM-DD
updated_by: [agent]
tags: [domain-index]
supersedes: ""
related: []
---
```

```markdown
# [Domain Name] — Domain Index

## Overview
[2-3 sentences: what this domain contains and its operational purpose]

## Note Archetypes
- **[Type 1]**: [description, expected grain size]
- **[Type 2]**: [description, expected grain size]

## Contents
| Note | Type | Status | Updated | Summary |
|------|------|--------|---------|---------|
| [[note_name]] | [type] | [status] | [date] | [one-line summary] |

## Cross-Domain Dependencies
[Which other domains does this reference? Which domains reference this?]

## Retrieval Guidance
[For AI agents: what to read first, what's most important, what can be skipped for most queries]
```

---

## INDEX.md Maintenance Rules

1. INDEX.md files WILL naturally decay unless maintenance friction remains low. Accept this.
2. Manual updates are correct during migration. Automation is Phase 4+.
3. Update the INDEX.md whenever notes are added, removed, or significantly changed.
4. The Contents table does not need to be exhaustive for large domains — focus on the most important notes and group minor ones.
5. Retrieval Guidance is the most valuable section for AI agents. Write it as if you're briefing a colleague who needs to find something fast.
