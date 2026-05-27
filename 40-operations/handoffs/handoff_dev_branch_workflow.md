---
title: handoff_dev_branch_workflow
domain: rmm
type: handoff
status: complete
created: 2026-04-25
updated: 2026-04-26
updated_by: claude_cowork
tags: [handoff, git, workflow, vercel, deployment]
supersedes: ""
related: ["[[website_architecture]]", "[[website_deployment_and_devops]]", "[[master_task_list]]"]
from_model: claude_cowork
to_model: claude_code
---

# Handoff Brief: Set Up Dev Branch + Release Workflow

## Objective
Set up a `dev` branch workflow for the RMM production repo so Valken can work freely without affecting the live site, preview changes via Vercel preview URLs, and release to production with clean squash merges on his schedule.

## Background
Currently, every push to `main` auto-deploys to runmadmaps.com immediately. Valken wants to:
1. Work on the site without affecting production
2. Preview changes on a live URL before releasing
3. Batch changes into planned releases (not 10 deploys per session)
4. Keep git history clean — one commit per release, not dozens of working commits

Vercel already generates preview URLs for non-main branches automatically. No Vercel config changes needed — just git branching.

## Executor
Claude Code — this is a quick setup task plus a brain document.

## Brain Context Files
- [[website_architecture]] — Current deployment setup (auto-deploy on push to main)
- [[website_deployment_and_devops]] — If it exists, deployment details

## Repo
`THE OFFICIAL BUILD` — the production RMM website repo.

## Specifications

### 1. Create the dev branch
```bash
cd "THE OFFICIAL BUILD"
git checkout main
git pull origin main
git checkout -b dev
git push -u origin dev
```

### 2. Verify Vercel picks it up
After pushing, check the Vercel dashboard. Under the project's Deployments tab, a new preview deployment for `dev` should appear automatically. Note the preview URL — it will look something like `rmm-git-dev-valkenmadness.vercel.app` or similar.

### 3. Set dev as the default working branch
In the local repo, make sure future work happens on `dev`:
```bash
git checkout dev
```

### 4. Configure branch protection on main (optional but recommended)
If Valken has GitHub Pro or the repo is public, recommend enabling branch protection on `main`:
- Require pull request before merging
- This prevents accidental direct pushes to production

### 5. Write a brain document
Create `rmm/operations/release_workflow.md` in the Obsidian vault with this content:

**Frontmatter:**
```yaml
---
title: "release_workflow"
domain: "rmm"
type: "knowledge"
status: "active"
created: "2026-04-25"
updated: "2026-04-25"
updated_by: "claude_code"
tags: ["operations", "git", "deployment", "workflow"]
supersedes: ""
related: ["[[website_architecture]]", "[[master_task_list]]"]
---
```

**Content should cover:**

**Branches:**
- `main` = production. Only updated via squash merge from `dev`. Auto-deploys to runmadmaps.com.
- `dev` = working branch. All daily work happens here. Every push gets a Vercel preview URL.
- Feature branches (optional) = branch off `dev` for large isolated features, merge back to `dev`.

**Daily workflow:**
1. Work on `dev` branch
2. Commit freely — messy commits are fine on `dev`
3. Push to `origin dev` whenever you want to preview
4. Check the Vercel preview URL to see changes live
5. Share preview URL with testers if needed

**Release workflow:**
1. Decide it's release day
2. Go to GitHub → Pull Requests → New Pull Request
3. Base: `main` ← Compare: `dev`
4. Title: "Release YYYY-MM-DD — [brief description]"
5. Select "Squash and merge" (not regular merge)
6. One clean commit lands on `main`
7. Vercel auto-deploys to runmadmaps.com
8. Continue working on `dev`

**Rules:**
- Never push directly to `main`
- Every AI model works on `dev` unless explicitly told otherwise
- The CLAUDE.md in the repo should note that `dev` is the working branch

### 6. Update CLAUDE.md in the repo
Add a section near the top noting:
```
## Branching
- `dev` is the working branch. All work happens here.
- `main` is production. Only updated via squash merge from dev.
- Never push directly to main.
```

### 7. Copy environment variables
Ensure the Vercel project has env vars available for Preview deployments (not just Production). In Vercel dashboard → Settings → Environment Variables, check that existing vars (Mapbox, Supabase) apply to "Preview" as well as "Production". This ensures the dev preview URL works correctly.

## Acceptance Criteria
1. ✅ `dev` branch exists on origin and Vercel generates a preview URL for it
2. ✅ `release_workflow.md` exists in the brain at `rmm/operations/`
3. ✅ `CLAUDE.md` in the repo has branching instructions
4. ✅ Valken can push to `dev`, see a preview URL, and `main` / runmadmaps.com is unaffected
5. ⚠️ Existing env vars — Valken to verify Preview scope in Vercel dashboard

## Completion Notes
- Completed 2026-04-26 by claude_cowork + Valken (manual push)
- Dev branch commit: `55f905f` (CLAUDE.md branching section)
- Vercel preview deployment: READY at `runmadmaps-git-dev-valkenmadness-projects.vercel.app`
- Production (main) unaffected — latest production deploy unchanged
- Unstaged work on dev: `api/python/`, `vercel.json`, `.gitignore` changes ready for next commit

## Do NOT
- Do NOT modify any website code, HTML, CSS, or JS in this task
- Do NOT change any Vercel project settings beyond env var scope
- Do NOT delete or force-push any existing git history
- Do NOT merge anything to main — leave that for Valken's first intentional release
