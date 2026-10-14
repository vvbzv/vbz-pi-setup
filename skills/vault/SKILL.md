---
name: vault
description: Write, update, and review Obsidian vault notes using PARA + KISS. Saves project work under `1. Project/<project_name>/` as one folder per project. Invoke after discussions that produce decisions, concepts, or status changes.
argument-hint: '[action] [details] e.g. "update <project_name>" or "review" or "archive <project_name>"'
user-invocable: true
---

# Vault Documentation Skill (PARA + KISS)

You maintain the user's Obsidian vault at `/Users/vvbz/Documents/VVBZ_Vault/`.

Vault uses **PARA** (Projects / Areas / Resources / Archive) and follows **KISS**: one project = one folder with as few files as possible. Don't fragment a project across many notes. Cross-link with `[[wikilinks]]` when relevant.

## User's Request

$ARGUMENTS

## Step 1: Detect Action

### Action: UPDATE (default)
Trigger: after discussion, new decisions, status change, or user says "update".
1. Identify the current project name (from `$ARGUMENTS` or recent conversation context). If unclear, ASK.
2. Resolve the project folder: `1. Project/<project_name>/`.
   - If folder exists → update the main note(s) inside it.
   - If folder does not exist → create it with one main note `<project_name>.md` first.
3. Append/edit content in the SMALLEST number of files possible. Default to editing the existing main note. Only create a second file if the topic is genuinely separate (e.g. a long log, a reference dump).
4. If the new info relates to another project/area → add a `[[wikilink]]` from the project note to that target. Don't duplicate the content.
5. Run broken-link check (Step 3).

### Action: MIGRATE
Trigger: user provides a source doc/folder to bring into the vault.
1. Read the source fully.
2. Decide ONE project name → create `1. Project/<project_name>/`.
3. Write a single main note `<project_name>.md`. Only split into extra files if length or topic clearly demands it (e.g. `LOG.md`, `RELAY.md`).
4. Use `[[wikilinks]]` to connect to existing notes in `2. Area/`, `3. Resource/`, or other projects. Do not copy content that already exists elsewhere.
5. Run broken-link check.

### Action: REVIEW
Trigger: user says "review" or asks about vault health.
1. List broken `[[wikilinks]]` (referenced but no file exists).
2. List orphan project folders with no incoming links.
3. Flag projects in `1. Project/` that look stale (no recent edits, status says done) → suggest moving to `4. Archive/`.
4. Report findings only. Do not move/delete without user confirmation.

### Action: ARCHIVE
Trigger: user says "archive <project_name>".
1. Move `1. Project/<project_name>/` → `4. Archive/<project_name>/` using `mv`.
2. Update any wikilinks that broke.
3. Confirm with user before running `mv`.

## Step 2: Vault Conventions

### Folder Structure (PARA)
```
/Users/vvbz/Documents/VVBZ_Vault/
├── 1. Project/         # Active projects with a goal + deadline
│   └── <project>/      # ONE folder per project, minimal files inside
├── 2. Area/            # Ongoing responsibilities (Garage, Self Host, ...)
├── 3. Resource/        # Reference material, topics of interest
└── 4. Archive/         # Inactive / done projects
```

### KISS Rules (binding)
- **One folder per project.** All project docs live inside `1. Project/<project_name>/`.
- **One main note by default.** `<project_name>.md` holds the project's content. Only split when a section is large enough to stand alone or has a different lifecycle (logs, relay state, raw refs).
- **No heavy ceremony.** No MOC, no ADR numbering, no required Decision Index. If a decision matters, write it inline under a `## Decisions` heading in the main note.
- **No mandatory YAML frontmatter.** Most existing vault notes have none. Add frontmatter ONLY if the user already uses it on that note, or asks for it.
- **Link don't duplicate.** Reference other projects/areas with `[[Project Name]]` instead of copying.
- **Match existing tone.** User's style is terse, often code blocks and bullet lists, mixed Thai/English. Don't pad with corporate prose.

### Default Project Note Shape
Keep it small. Use only the sections that have content. Skip empty sections.

```markdown
# <Project Name>

Short one-line description.

## Status
- {current state, next step}

## Notes
- {bullets, links, snippets}

## Decisions
- {date} — {decision} — {why, in one line}

## Related
- [[Other Project]]
- [[Some Area]]
```

### Naming
- Project folder + main note: same name, Title Case, spaces OK.
  Example: `1. Project/Trading Bot/Trading Bot.md`
- Extra files inside a project folder use ALL-CAPS or short Title Case:
  `LOG.md`, `RELAY.md`, `Research.md`.
- No date prefixes on filenames unless the user already uses them.

### Wikilinks
- Use `[[Note Name]]`. Obsidian resolves by filename across the whole vault.
- Cross-link freely between `1. Project/` ↔ `2. Area/` ↔ `3. Resource/`.
- A project without any incoming links is fine if it's brand new — flag it only in REVIEW.

## Step 3: Broken Link Check

Run from the vault root after any write:
```bash
cd "/Users/vvbz/Documents/VVBZ_Vault"
grep -roh '\[\[[^]]*\]\]' . 2>/dev/null | sed 's/\[\[//;s/\]\]//;s/|.*//;s/#.*//' | sort -u > /tmp/wl.txt
find . -name "*.md" -not -path "./.obsidian/*" -exec basename -s .md {} \; | sort -u > /tmp/fl.txt
comm -23 /tmp/wl.txt /tmp/fl.txt
```
If output is non-empty → list broken targets. Ask the user before creating stub notes for them; don't auto-create.

## Step 4: Report

After the action, give a short report:
- Folder/files touched (one line each)
- Broken-link count (0 = good)
- Anything that needs the user's decision

Keep the report tight. No filler.
