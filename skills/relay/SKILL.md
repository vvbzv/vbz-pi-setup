---
name: relay
description: Cross-LLM session handover with zero-loss context transfer. 7-layer state capture, verification gate, Engram/context-mode integration. Use when switching LLMs, ending sessions, or preserving complex work state.
---

# /relay — Cross-LLM Universal Knowledge & Work Transfer Protocol

## Overview

Model-agnostic session handover capturing 100% of project knowledge and work state so any downstream LLM can resume cold with zero loss. Evidence before assertions. Capture WHAT + WHY + HOW + WHAT-FAILED + RUNTIME-STATE. Nothing silent. Nothing assumed.

**Guaranteed completeness:** Completeness Gate refuses to finalize until every layer has content or explicit `N/A — reason: ...` marker.

## When to Use

- User types `/relay` or asks to hand off / wrap up / pass to next session
- Ending a work session (daily stop, context running low, switching machines)
- Switching LLMs mid-project (Claude → GPT → Gemini → Codex)
- Resuming cold on a different model days later
- Pair-programming between two LLMs in round-robin
- Before any major context compaction or `/clear`

**Skip if:** trivial one-shot question, throwaway conversation, no project artifacts.

---

## Three Handover Modes

Mode declared at top of RELAY.md and stored in relay-state.json.

| Mode | Use when | Next LLM chosen by |
|---|---|---|
| **🎯 Routed (default)** | Mixed LLM fleet; pick best model per task | Capability tags on tasks |
| **🔄 Round-robin** | Pinned 2-model cycle (e.g. Claude ⇄ Codex) | cycle array, auto-alternates |
| **🌀 Free-form** | Opportunistic, any LLM available | Human grabs whatever's handy |

**Capability tags:**
```
[reasoning-heavy]  → architecture, trade-offs, deep analysis     (Claude Opus, GPT-5 thinking)
[execution-heavy]  → fast coding, refactors, one-shot tasks      (Codex, GPT-5, Haiku, local coder)
[research-heavy]   → web/docs lookup, fact-finding               (Perplexity, Gemini, Claude + web)
[review-heavy]     → audits, security, edge cases                (Claude Opus, GPT-5 review)
[creative-heavy]   → naming, UX copy, design prose               (Claude Sonnet, GPT-4o)
```

## Pass Typology

| Badge | Meaning | Next LLM expectation |
|---|---|---|
| 🟢 **Clean** | All tests green, no blockers, obvious next step | Build features |
| 🟡 **Caveat** | Work done but with known gaps listed explicitly | Finish gaps first |
| 🔴 **Rescue** | Something broken; fix before building anything else | Triage + repair only |

---

## The 7 Layers of 100% Transfer

Every pass MUST capture all 7 or mark N/A with reason. No silent gaps.

| # | Layer | Captures | Answers |
|---|---|---|---|
| 1 | **Intent** | Original goal, current sub-goal, scope boundaries, out-of-scope | "What are we trying to do?" |
| 2 | **Progress** | Deliverables done, % per task, exact files & line numbers touched | "Where are we?" |
| 3 | **Runtime state** | Git SHA + branch, uncommitted diff, running procs, env vars, deployed versions | "What is the world like now?" |
| 4 | **Reasoning trace** | Decisions + WHY, alternatives considered, trade-offs accepted | "Why this way?" |
| 5 | **Negative space** | Hypotheses ruled out, failed approaches, dead-ends, do-not-retry | "What NOT to retry?" |
| 6 | **Knowledge graph** | Entities (files, functions, APIs, configs) + relationships | "What are the moving parts?" |
| 7 | **Continuity** | Pass number, debt retired/added, recurring risks | "How is this handoff better?" |

---

## Hardcoded Paths

```
CENTRAL_POST_MORTEM = /Users/vvbz/Desktop/Trading Bot/Trading System/POST_MORTEM.md
CENTRAL_MEMORY_INDEX = /Users/vvbz/.opencode/projects/-Users-vvbz/memory/MEMORY.md
```

---

## Pre-Pass Verification Gate

Evidence before assertions. **Do not** fabricate "tests pass" claims.

Run and record exact output:
- [ ] Test suite — exact pass/fail count + command used
- [ ] Linter / type-checker — exact errors or "0 errors" + command used
- [ ] Live services running? — `ps`/`curl`/smoke test evidence
- [ ] Deployment landed? — version check, remote file hash, or smoke call
- [ ] Direct-on-server edits? — flag explicitly; note rsync overwrite risk
- [ ] Uncommitted work captured? — diff summary or patch file path

**If you cannot run a check**, write it under `Not Verified` with the reason.

---

## Files Produced

| # | File | Mode | Purpose | Audience |
|---|---|---|---|---|
| 1 | `RELAY.md` | overwrite | Current state + priming prompt + 7-layer snapshot | Next LLM, cold |
| 2 | `RELAY-NEXT.md` | overwrite | Prioritized tasks with success criteria & capability tags | Next LLM, after reading RELAY |
| 3 | `RELAY-LOG.md` | append-top | Pass-by-pass history, debt retired/added | Future passes |
| 4 | `SCRATCHPAD.md` | overwrite | Active mid-thought notes, half-baked ideas | Current-thread continuity |
| 5 | `MEMORY.md` | append/selective | Project-lifetime facts, decisions, conventions | Anyone in 3 months |
| 6 | `docs/POST_MORTEM.md` | append-only | Failures, root causes, resolutions | Future debugging |
| 7 | Central `POST_MORTEM.md` | append-only | Cross-repo transferable lessons | All repos |
| 8 | `relay-state.json` | overwrite | Machine-readable state | Automation, dashboards |

---

## Integration with Modern Tools

### Engram Memory
Before writing RELAY.md, call `mem_session_summary` to capture session into Engram. Ensures persistent memory survives even if relay files are lost.

### Context-Mode
- Use `ctx_execute` for verification gate commands when output may be large
- Use `ctx_index` to index RELAY.md for future searches via `ctx_search`

### GitNexus
Run `gitnexus_detect_changes` before finalizing to ensure all changes captured in runtime state.

---

## Execution Steps

### Step 0 — Survey the session (mental pass, no writes yet)

Extract from conversation:
- Concrete deliverables produced
- Files changed (paths + why)
- Decisions made + rationale
- Failed attempts + why abandoned
- Current blockers / open questions
- Exact in-progress state (file:line)
- Tool calls that mattered vs noise

### Step 1 — Read existing relay files

```bash
for f in RELAY.md RELAY-NEXT.md RELAY-LOG.md SCRATCHPAD.md MEMORY.md docs/POST_MORTEM.md relay-state.json; do
  [ -f "$f" ] && echo "=== $f ===" && cat "$f" || echo "=== $f === (not found)"
done
CENTRAL="/Users/vvbz/Desktop/Trading Bot/Trading System/POST_MORTEM.md"
[ -f "$CENTRAL" ] && echo "=== Central POST_MORTEM (tail) ===" && tail -30 "$CENTRAL"
mkdir -p docs
```

### Step 2 — Run verification gate

Record exact commands & output. Do not skip. Do not paraphrase.

### Step 3 — Capture runtime state

```bash
git rev-parse HEAD 2>/dev/null
git rev-parse --abbrev-ref HEAD 2>/dev/null
git status --short 2>/dev/null
git diff --stat 2>/dev/null
git diff > .relay/uncommitted.patch 2>/dev/null || true
ps aux | grep -iE "node|python|bot|server" | grep -v grep
```

Record into RELAY.md Layer 3.

### Step 4 — Capture session into Engram

Call `mem_session_summary` with Goal, Instructions, Discoveries, Accomplished, Next Steps, Relevant Files.

### Step 5 — Write RELAY.md (full overwrite)

Use template below. Every layer filled or N/A with reason. Include priming prompt block at top.

### Step 6 — Write RELAY-NEXT.md (full overwrite)

Each task MUST have: description, success criteria (runnable check), capability tag, priority, dependencies, carry-forward marker if unresolved.

### Step 7 — Prepend new entry to RELAY-LOG.md (append-top)

Never rewrite prior entries. Use template below.

### Step 8 — Update SCRATCHPAD.md (overwrite)

Mid-thought notes, open questions, hypotheses. Keep short.

### Step 9 — Update MEMORY.md (selective append)

Only add: new architectural decisions, new conventions, new tool configs, corrections to prior facts. **Don't dump session summaries** — that's RELAY.md's job.

### Step 10 — Append to docs/POST_MORTEM.md if real failure this session

Skip if session was clean.

### Step 11 — Append to Central POST_MORTEM if lesson transferable

Strip project-specific paths; keep generalizable takeaway.

### Step 12 — Write relay-state.json (overwrite)

Use template below.

### Step 13 — Run Completeness Gate

Go through checklist. If any item missing, fill it or mark N/A with reason.

### Step 14 — Print Baton Pass Summary

Short copy-pasteable block, then stop. Wait for human.

---

## Template: RELAY.md

```markdown
# RELAY — Session {N} — {DATE} — {Badge}

## 🚀 Priming Prompt (copy-paste into any LLM to resume cold)

> You are picking up work on this project. Read these files in order before anything else:
> 1. This file (`RELAY.md`) — current state + 7-layer snapshot
> 2. `RELAY-NEXT.md` — your prioritized task list
> 3. `RELAY-LOG.md` (top entry only) — what the previous pass did
> 4. `MEMORY.md` — long-term project facts
> 5. `docs/POST_MORTEM.md` (tail) — recent failure history
>
> Do NOT start coding until you have confirmed:
> - Current git SHA matches `Runtime Snapshot` below
> - Uncommitted diff matches `.relay/uncommitted.patch` (if present)
> - All items under `Not Verified` are acknowledged
>
> Mode: {routed | round-robin | free-form}
> Your role (if round-robin): {A | B}
> Capability hint for your model: {reasoning-heavy | execution-heavy | ...}

## Pass Header

- **Pass type:** 🟢 Clean | 🟡 Caveat | 🔴 Rescue
- **Session:** {N}
- **Date:** {YYYY-MM-DD}
- **Source LLM:** {claude-opus-4-7 | gpt-5 | codex | gemini-2.5 | ...}
- **Target LLM hint:** {routed-by-tags | next-in-cycle: codex | any}
- **Mode:** {routed | round-robin | free-form}

## Layer 1 — Intent

- **Original goal:** ...
- **Current sub-goal:** ...
- **In scope:** ...
- **Out of scope:** ...

## Layer 2 — Progress

| Task | Status | Files touched | Notes |
|---|---|---|---|
| ... | 70% | `src/foo.py:12-84` | blocked on X |

## Layer 3 — Runtime Snapshot

- **Git SHA:** `abc1234`
- **Branch:** `main`
- **Uncommitted:** `N files, +X/-Y lines` (patch at `.relay/uncommitted.patch` if saved)
- **Running procs:** ...
- **Env vars of interest:** `FOO=...` (values redacted if sensitive — reference location only)
- **Deployed versions:** prod=`v1.2.3`, staging=`v1.2.4-rc1`

## Layer 4 — Reasoning Trace

- **Decision:** Used polling over websockets for X. **Why:** broker API rate-limits websockets after 5min. **Trade-off:** 200ms latency accepted.

## Layer 5 — Negative Space (Do NOT Retry)

- ❌ Tried `asyncio.gather` with 50+ tasks → hit API rate limit
- ❌ Considered switching to library X → incompatible with Python 3.11

## Layer 6 — Knowledge Graph

```
backtest.py ──imports──> numba_utils.py ──caches──> ~/.cache/numba/
backtest.py ──calls────> broker_client.py ──env──> API_KEY, API_SECRET
```

## Layer 7 — Continuity

- **Previous pass:** Session {N-1} — {badge} — {one-line summary}
- **Debt retired this pass:** ...
- **New debt introduced:** ...
- **Recurring risks:** ...

## Verification Results

```
$ pytest -q
16 passed, 0 failed in 2.1s

$ ruff check .
All checks passed!
```

## Not Verified (gaps — be honest)

- GCP deployment smoke test: skipped, no creds in this session

## Shaky Parts / Risks

- `bid=None` patch on GCP may get overwritten by next rsync

## Reproduction Block

```bash
git checkout abc1234
[ -f .relay/uncommitted.patch ] && git apply .relay/uncommitted.patch
export FOO=bar
python -m mybot.backtest --from 2026-01-01
```
```

---

## Template: RELAY-NEXT.md

```markdown
# RELAY-NEXT — Session {N+1} targets

## Priority 1 — Blockers (do these first)

### [P1] Fix Numba cache invalidation in backtest.py:47 [execution-heavy]
- **Why it matters:** Causes 30s cold-start on every run.
- **Success criteria:** `pytest tests/test_backtest_cache.py` passes AND cold-start < 3s.
- **Depends on:** nothing.
- **Hint:** minimal patch, don't refactor.
- ⏭️ Carried from Session 11.

## Priority 2 — Feature work

### [P2] Add PnL daily summary export [execution-heavy]
- ...

## Priority 3 — Review / audit

### [P3] Audit risk_manager.py for integer-overflow [review-heavy]
- ...

## Carry-forward ledger

| Item | First appeared | Status | Why still open |
|---|---|---|---|
| Numba cache fix | Session 9 | ⏭️ | Needs deeper rewrite |
```

---

## Template: RELAY-LOG entry

Prepended to top. Never rewrite prior entries.

```markdown
---
## [YYYY-MM-DD] — Session {N} — {source LLM} — 🟢|🟡|🔴

- **Accomplished:** One-sentence summary.
- **Verified:** Tests 16/16 passing. Lint clean. Services healthy.
- **Not verified:** GCP smoke test (no creds in session).
- **Handoff quality delta:** Previous pass missed X; this pass captures it via Y.
- **Debt retired:** {shaky item from prior pass that this pass fixed}
- **New debt:** {new shaky areas introduced}
- **Mode:** routed | round-robin | free-form
- **Next model hint:** {codex | claude | any}
```

---

## Template: POST_MORTEM entry

```markdown
---
## {DATE} — {Short title}

**Context:** What were we trying to do
**What happened:** The failure / unexpected behavior
**Root cause:** Why it happened
**Resolution:** How it was fixed or worked around
**Prevention:** What to do differently
```

Central POST_MORTEM — add `Repo/Project:` field, strip project-specific paths:

```markdown
---
## {DATE} — {Short title}

**Repo/Project:** {repo name}
**Context:** What were we trying to do (described generically)
**What happened:** The failure / unexpected behavior
**Root cause:** Why it happened
**Lesson learned:** Transferable takeaway
**Prevention:** What to do differently — broadly applicable
```

---

## Template: relay-state.json

```json
{
  "session": 12,
  "date": "2026-06-04",
  "source_llm": "claude-opus-4-7",
  "pass_type": "caveat",
  "mode": "routed",
  "cycle": null,
  "last_model": "claude",
  "next_model_hint": "codex",
  "tests_passed": 16,
  "tests_failed": 0,
  "lint_clean": true,
  "services_healthy": true,
  "git_sha": "abc1234",
  "branch": "main",
  "uncommitted_files": 3,
  "open_blockers": [
    "Numba cache invalidation on macOS 15+"
  ],
  "next_priority": "Fix Numba cache in backtest.py:47",
  "completeness": {
    "layer1_intent": "filled",
    "layer2_progress": "filled",
    "layer3_runtime": "filled",
    "layer4_reasoning": "filled",
    "layer5_negative": "filled",
    "layer6_graph": "filled",
    "layer7_continuity": "filled"
  }
}
```

---

## Completeness Gate Checklist

Refuse to finalize until every item is ✅ or explicitly `N/A — reason: ...`.

- [ ] `RELAY.md` has pass-type badge at top
- [ ] `RELAY.md` has priming prompt block
- [ ] All 7 layers filled or `N/A` with reason
- [ ] Verification results include exact commands + output
- [ ] `Not Verified` section explicit (or `N/A`)
- [ ] Shaky parts / risks section non-empty (or `N/A`)
- [ ] Reproduction block includes SHA + patch ref + env + start command
- [ ] `RELAY-NEXT.md` every task has success criteria + capability tag
- [ ] `RELAY-NEXT.md` carry-forward ledger updated
- [ ] `RELAY-LOG.md` new entry prepended (not rewritten)
- [ ] `RELAY-LOG.md` entry addresses previous pass's flagged risks
- [ ] `MEMORY.md` updated only if long-term facts changed (else skip)
- [ ] `docs/POST_MORTEM.md` entry added iff real failure this session
- [ ] Central POST_MORTEM entry added iff lesson is transferable
- [ ] `relay-state.json` written with all fields
- [ ] All dates ISO format (YYYY-MM-DD)

---

## Anti-Patterns (DO NOT DO)

### In RELAY.md
- ❌ "Everything works" without exact test/lint output
- ❌ Empty `Shaky parts` because "nothing feels shaky"
- ❌ Listing every file touched — only where change matters
- ❌ Pasting raw conversation transcript — synthesize, don't transcribe
- ❌ Writing tool-specific verbs ("used Edit tool") — use neutral verbs ("edited")
- ❌ Omitting the priming prompt block

### In RELAY-NEXT.md
- ❌ Vague tasks like "improve performance" — use specific metrics
- ❌ Tasks without success criteria
- ❌ Dropping unresolved items from prior pass without carry-forward
- ❌ Missing capability tag

### In RELAY-LOG.md
- ❌ Rewriting prior entries — append-top only
- ❌ Claiming "cleaner handoff" without saying HOW
- ❌ Hiding new debt

### In MEMORY.md
- ❌ Dumping session summaries (that's RELAY.md's job)
- ❌ Over-padding — if it'll be stale in a week, it's not a memory

### Cross-cutting
- ❌ Round-robin mode without `cycle` set in relay-state.json
- ❌ Silent gaps anywhere — mark `N/A — reason: ...` instead
- ❌ Skipping verification gate because "I'm confident"

---

## Cross-LLM Portability Notes

1. **No tool-specific verbs** in output files. Say "ran the test suite", not "used the Bash tool".
2. **No Claude-specific skills** referenced in next-tasks. Reference commands, files, or docs any LLM can read.
3. **Priming prompt** at top of RELAY.md is the cold-start contract. Any LLM reading it should be able to resume.
4. **Machine-readable state** in relay-state.json lets automation or other LLMs ingest without parsing markdown.
5. **Reproduction block** is executable from any shell.
6. **Capability tags** map to generic LLM strengths, not model names.

---

## Output to User

```
Relay complete — Session {N} — {badge}

RELAY.md              — overwritten (7 layers filled, {K} N/A with reason)
RELAY-NEXT.md         — overwritten ({P1}/{P2}/{P3} tasks, {C} carried-forward)
RELAY-LOG.md          — prepended entry (session {N})
SCRATCHPAD.md         — overwritten ({T} TODOs, {Q} open questions)
MEMORY.md             — {appended N entries | no changes}
docs/POST_MORTEM.md   — {appended 1 entry: "{title}" | no changes}
Central POST_MORTEM   — {appended: "{title}" | skipped | no changes}
relay-state.json      — written (mode: {mode})

Verification: {tests X/Y} {lint clean|N errors} {services healthy|N/A}
Not verified: {list or "none"}

Next LLM should: {one-line most-important instruction}
```

Then stop. Wait for human.
