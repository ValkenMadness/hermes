---
title: brain_update_protocol
domain: system
type: knowledge
status: active
created: 2026-04-24
updated: 2026-04-24
updated_by: claude
tags: [system, process, brain-update, maintenance]
supersedes: ""
related: ["[[master_instruction_deck]]", "[[ways_of_working]]", "[[handoff_protocol]]", "[[completion_report_protocol]]"]
---

# Brain Update Protocol

This document defines how completion reports and conversation outputs get processed back into the Obsidian vault. This is the job of the Brain Manager GPT, or any AI model performing brain maintenance.

## The Core Rule

Every piece of work produces a report. Every report gets processed into the brain. The brain is always current. If a report was generated and the brain wasn't updated, the system is broken.

## Processing a Completion Report

When you receive a completion report, follow this sequence:

### Step 1: Identify Affected Documents

Read the completion report's "Brain Documents Affected" section. For each document listed:
- Read the current version from the vault
- Determine what needs to change based on the report
- Classify the change: minor update, major rewrite, or new document needed

### Step 2: Classify the Update Type

**Minor update:** The document's core content is still valid but specific details need refreshing. Examples: a build status changed, a new feature was added to an existing system, a date or version number changed. Action: edit the document in place, update the `updated` date and `updated_by` field.

**Major rewrite:** The document's structure or fundamental content has changed significantly. Examples: an architecture was refactored, a system was replaced, a strategy shifted. Action: create a new document. Set the old document's status to `superseded` and add a `supersedes` field pointing to the new document. Move the old document to `archive/`.

**New document needed:** The work created something that has no existing brain document. Examples: a new system was built, a new decision was made, a new component was added. Action: create a new document with proper frontmatter in the correct domain folder.

### Step 3: Perform the Updates

For each affected document:

1. **Update frontmatter:**
   - Set `updated` to today's date
   - Set `updated_by` to the model performing the update
   - Add or update `related` links if new connections exist
   - Add new tags if applicable

2. **Update content:**
   - Modify the specific sections that changed
   - Do not rewrite content that hasn't changed
   - If adding new information, integrate it naturally — don't append a "Updates" section at the bottom

3. **Maintain links:**
   - If the updated document now relates to new documents, add bidirectional links
   - If a new document was created, make sure existing relevant documents link to it
   - Verify no broken links were introduced

### Step 4: Handle New Documents

When creating a new document:

1. Determine the correct folder based on domain and content type
2. Create the filename using lowercase_with_underscores
3. Add complete frontmatter with all fields
4. Write self-contained content (500-2,000 words)
5. Set `related` links to all relevant existing documents
6. Update those related documents to link back to the new one

### Step 5: Handle Superseded Documents

When a document is being replaced:

1. Create the new document first
2. Go to the old document:
   - Set `status: "superseded"`
   - Add `supersedes: "[[new_document_name]]"` (note: the supersedes field on the OLD doc points TO the new doc)
3. Move the old document to `archive/`
4. Update any documents that linked to the old one — they should now link to the new one

### Step 6: Verify Integrity

After all updates are complete:
- Confirm every new related link is bidirectional
- Confirm no broken links exist
- Confirm no duplicate tags were introduced
- Confirm all titles match filenames
- Confirm frontmatter is properly formatted

## Processing a Conversation Summary

When Valken provides a summary of a ChatGPT or Claude conversation (rather than a formal completion report), the process is similar but requires more judgment:

1. Read the summary and identify: decisions made, ideas captured, status changes, new information
2. For each decision: check if a decision document exists in `rmm/decisions/`. If not, create one. If one exists and this modifies it, update it.
3. For each idea: create an idea document in `ideas/` or the relevant domain folder
4. For status changes: update the relevant documents (build status, phased build plan, etc.)
5. For new information: determine the correct document and folder, create or update as needed

## Processing an Idea Report

When ChatGPT produces an idea report from a conversation:

1. Save it to `ideas/` or the relevant domain folder (e.g., `rmm/product/` if it's a product idea)
2. Add proper frontmatter with `type: "idea"` and `status: "active"`
3. Link it to related existing documents
4. Update related documents to link back

## What NOT to Do

- **Do not create a document for the completion report itself.** The report is transient. Extract its knowledge into brain documents and discard the report.
- **Do not append "update logs" to existing documents.** Integrate changes naturally into the content. The `updated` date in frontmatter tracks when something changed.
- **Do not create documents for trivial changes.** If a one-line CSS fix was made, update the relevant build status document — don't create a new document about the fix.
- **Do not guess at information not in the report.** If the report doesn't specify something, don't infer it. Flag it as missing.

## Telling Valken What You Did

After processing a report, tell Valken exactly what changed:

```
Brain updated:
- Updated: [[website_build_status_overview]] — popup system now uses hover trigger
- Created: [[popup_hover_system]] in rmm/codebase/ — new implementation docs
- Superseded: [[old_popup_docs]] → moved to archive/
- Added bidirectional links between [[popup_hover_system]] and [[map_system_markers_and_interactions]]
```

This gives Valken a clear audit trail without requiring him to inspect every file.
