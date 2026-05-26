---
title: metadata-schema
domain: system
type: knowledge
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude
tags: [system, schema, metadata]
supersedes: ""
related: ["[[domain-map]]", "[[health-check]]", "[[index-template]]"]
---

# Hermes Metadata Schema

This document defines the frontmatter convention for every note in Hermes. The schema is derived from the existing Obsidian vault conventions (which are strong and proven) with Hermes-specific additions for retrieval and governance.

## Design Principle

Metadata exists to reduce cognitive load, not to create organizational purity. Start lean. Add complexity ONLY when retrieval quality or operational clarity genuinely improves. Every field must justify its operational cost. If creating a note starts feeling like administrative labor, the schema is too heavy.

---

## Required Fields (Every Note)

```yaml
---
title: "matches_filename_exactly"
domain: "system | rmm | personal | finance | cyberdeck | learning | ideas | writing"
type: "knowledge | decision | task | handoff | idea | log | session-summary | agent-manifest | domain-index | retrospective"
status: "draft | active | review | complete | archived | superseded"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
updated_by: "valken | claude | claude_code | claude_cowork | chatgpt | brain_manager_gpt | local_llm"
tags: ["hyphenated-tags", "no-underscores", "no-ampersands"]
supersedes: ""
related: ["[[properly_linked]]", "[[with_commas]]"]
---
```

### Field Rules

- **title**: Must match filename exactly (without `.md` extension). Filenames are `lowercase_with_underscores`.
- **domain**: Which knowledge domain this note belongs to. Use the domain names defined in `domain-map.md`.
- **type**: The note's archetype. Defined per domain, but common types listed above.
- **status**: Lifecycle state. Notes are never deleted — they get `status: superseded` with a `supersedes` link to the replacement.
- **created / updated**: ISO 8601 date format. When editing a note, always update the `updated` field.
- **updated_by**: Which agent or human last modified this note. Always update when editing.
- **tags**: Array of hyphenated lowercase tags. No spaces, no underscores, no ampersands, no duplicates. No self-referencing.
- **supersedes**: Path to the note this one replaces, or empty string if original.
- **related**: Array of wiki-links to related notes. Proper YAML array syntax with commas. No self-referencing. Bidirectional links are maintained where practical (if A links to B, B should link to A).

---

## Domain-Optional Fields

These fields are used within specific domains. They are not required globally but should be consistent within their domain.

### RMM-Specific

```yaml
# Handoff notes
from_model: "chatgpt | claude | claude_code | claude_cowork"
to_model: "claude_code | codex | brain_manager_gpt"

# Data-sourced notes
source: "filename or data origin"

# Trail/geographic notes
trail: "trail name"
region: "geographic region"
data_source: "strava | garmin | manual | qgis"
```

### Homelab/Cyberdeck-Specific (Future)

```yaml
service: "service name"
host: "hostname"
port: "port number"
```

### Career/Business-Specific (Future)

```yaml
company: "company name"
role: "role title"
application_status: "applied | interviewing | offered | declined | closed"
```

### Finance-Specific (Future)

```yaml
currency: "ZAR | USD | EUR"
category: "income | expense | investment | saving"
```

---

## Reserved Fields (Defined Now, Populated Later)

These fields are defined in the schema but not required during initial migration. They will be populated during Phase 4 (Operationalization) when retrieval optimization begins.

```yaml
retrieval_priority: "high | normal | low"
```

This field will help AI agents prioritize which notes to read first when operating within a domain. High-priority notes are essential context; low-priority notes are reference material that can be skipped unless specifically relevant.

---

## Migration Rules

1. **Existing frontmatter is PRESERVED.** New required fields are ADDED alongside existing fields. No existing fields are removed or renamed.
2. **Conflicts are flagged, not silently resolved.** If an existing field value conflicts with the new schema, log the conflict in the migration issues log and flag for human review.
3. **The existing vault's field names take precedence.** The vault already uses `updated_by`, `related`, and `supersedes` — these are the canonical names. Do not rename them.
4. **Empty optional fields use empty string `""`, not null or omission.** This makes the schema self-documenting — you can see which fields exist even when empty.

---

## Schema Evolution Rules

1. Adding a new optional field: Any agent can propose. Requires human approval before implementation.
2. Adding a new required field: Requires human approval AND a migration plan for existing notes.
3. Renaming a field: Strongly discouraged. Only with human approval and full vault migration.
4. Removing a field: Never. Deprecated fields get documented as deprecated but remain in the schema.
5. All schema changes are recorded in the decision log.
