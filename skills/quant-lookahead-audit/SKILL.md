---
name: quant-lookahead-audit
description: Audit algorithmic trading systems, backtests, live bots, validators, and portfolio simulators for deterministic look-ahead bias, repaint risk, stale-price leakage, multi-timeframe alignment errors, and live/backtest timing mismatches. Use when reviewing quant strategies, trading bots, backtests, or when the user asks whether a trading system is lookahead-clean.
user-invocable: true
allowed-tools: Read, Find, Search, AST Grep, LSP, Bash, Task, Todo Write, Write
---

# Quant look-ahead audit

> CIO + Red-Team + Risk-Team procedure for proving a trading stack is not cheating with future information.

## Mission

Your job is **not** to say a strategy “looks fine.”

Your job is to answer this harder question:

> **Could this system have produced the same signals, the same entries, and the same portfolio decisions if the future bars did not exist yet?**

If the answer is not provably yes, the stack is not clean.

## Core stance

- **Evidence before trust.**
- **Determinism over heuristics.**
- **Active path over dead code.**
- **Line-level proof over vibes.**
- **No “probably clean.”** Either show why it is clean, or show exactly where it leaks.

## When to use

Use this skill when the user asks to:
- audit a trading strategy for look-ahead bias
- verify a backtest is “no lookahead” or “no repaint”
- compare live vs backtest timing logic
- review multi-timeframe strategy logic
- validate a portfolio simulator or walk-forward engine
- red-team a quant research stack
- prove a trading system is safe to trust

Also use it when you see any of these phrases:
- “lookahead bias”
- “repaint”
- “future leak”
- “uses completed bars only”
- “same bar entry”
- “multi-timeframe alignment”
- “walk-forward”
- “portfolio simulation”

## What this skill is for

This skill is for detecting and proving or disproving:
- deterministic future-data leakage
- signal repainting under future-bar append
- stale-anchor timing mismatches that masquerade as alpha
- multi-timeframe leaks from incomplete higher-timeframe bars
- portfolio-level sequencing bugs that let the simulator use impossible information
- live/backtest timing or sizing mismatches that invalidate research conclusions

## What this skill is not for

This skill is **not** primarily about:
- parameter optimization
- strategy edge discovery
- profitability review
- exchange slippage realism
- general code quality

Those matter, but they are separate questions.

## Required mindset

Operate as three roles at once:

### CIO
Ask:
- Would I trust capital to this system?
- Is the evidence strong enough to accept the research result?
- Is the stack measuring real edge or accidental leakage?

### Red-Team
Ask:
- Where is the easiest place for future bars to leak in?
- What assumption is silently doing the cheating?
- If I wanted to fake alpha accidentally, where would it happen?

### Risk Team
Ask:
- Does the simulator use information that would not have existed at the time of trade?
- Are position limits, concurrency, and sizing enforced realistically?
- Are research conclusions invalid even if code “runs”? 

## Definitions

## Deterministic look-ahead bias

A strategy has deterministic look-ahead bias if any decision at time `t` depends on information from:
- bar `t` close while claiming entry at bar `t` open
- bar `t+1` or later
- a higher timeframe bar that was incomplete at time `t`
- a portfolio state that requires knowledge of trades not yet decided in sequence

## Repaint risk

A strategy repaints if adding later bars changes:
- earlier entry signals
- earlier side decisions
- earlier stop/target levels
- earlier higher-timeframe permission flags

## Stale-anchor mismatch

Not always look-ahead, but still critical.

This happens when:
- a stop/target is computed from a prior anchor price
- entry occurs later at a different price
- risk distance, R-multiple, or sizing no longer match what the report claims

This can invalidate backtest quality even when the code is technically not peeking ahead.

## What does **not** count as look-ahead

Do **not** flag these as leaks by default:
- `close.shift(1)` used in a formula
- ATR true range using previous close
- completed-bar calculations in live if the caller already strips the forming bar
- same-bar high/low exit simulation **after** entering at the bar open, as long as the entry decision was made from prior-bar information
- forward-filling a higher-timeframe value that came from the **last completed** higher-timeframe bar

These are valid unless something else makes them unsafe.

## Hard rules

### 1. Audit the active stack first

Do **not** spend most of your time in stale notebooks, archived scripts, or superseded engines.

First identify the real deployment or research path.

Usually this means finding:
- active strategy functions
- active feature builders
- active simulator / validator
- active portfolio aggregation path
- active live entry path

### 2. Never trust heuristic “lookahead auditors” alone

If the codebase already has an audit script, treat it as a clue, not proof.

Heuristic auditors often:
- hard-code passes
- check the wrong columns
- miss deterministic timing bugs
- give false confidence

A deterministic truncation / prefix-invariance test is stronger.

### 3. Separate look-ahead from other defects

Classify findings precisely:
- deterministic look-ahead
- repaint risk
- stale-anchor mismatch
- execution-model mismatch
- portfolio sequencing bug
- live/backtest sizing mismatch

Do not mash them together.

### 4. Fresh reviewers reduce self-bias

For non-trivial audits, dispatch at least two fresh reviewers:
- one for the **signal path**
- one for the **simulation / portfolio path**

Their job is read-only. No edits, no tests, no formatting.

## Audit workflow

## Phase 0 — Scope the real stack

Map the active path before you judge anything.

Find:
- active live strategy list or priority order
- active timeframe(s)
- active feature computation path
- active signal functions
- active backtest / validator / combined portfolio path
- any special alternate-timeframe blocks
- the actual shared-cap / concurrency logic

Output of this phase:
- a short list of files that define the active path
- a short list of stale or dead files that should not dominate the audit

## Phase 1 — Audit signal timing

For each active sleeve or strategy:

### Check entry inputs

Verify whether entries at bar `t` use only:
- bar `t-1`
- older bars
- completed higher-timeframe bars aligned at or before `t-1`

Look for dangerous patterns:
- `close` used directly in an entry condition while the trade is entered at that same bar’s open
- `iloc[-1]` on data that still includes the forming bar
- MTF permissions built from an unshifted higher-timeframe close
- `rolling()` or `ewm()` outputs used on the current bar without lag when the trade assumes next-bar entry from the same bar

### Check MTF alignment

Look for:
- `ffill()` from higher timeframe without first shifting completed bars
- resample alignment that lets a 15m bar see a 1h close before the hour finished
- use of current higher-timeframe VWAP / EMA / ADX without lag

### Clean patterns

Examples of good timing patterns:
- `trend_up = (ema_fast > ema_slow).shift(1)`
- `prev_close = close.shift(1)`
- `adx_gate = adx.shift(1) > threshold`
- completed higher-timeframe flags shifted by 1 before forward-fill

## Phase 2 — Audit stop / target materialization

This is where many “clean” systems still cheat indirectly.

For each active strategy:
- find where SL/TP are computed
- compare the anchor price to the actual entry price
- verify the stop distance is the one the sizing logic thinks it is

Red flags:
- stop/target computed from `close.shift(1)` but entry occurs later at a different open without recomputing
- clip/floor/cap logic applied live but not in backtest
- break-even or trail logic activating on the same bar as the trigger without conservative sequencing

Clean pattern:
- signal decides **that** a trade exists
- simulator or live entry path anchors stop distance to the actual entry price or explicitly modeled prior-bar anchor with matching sizing assumptions

## Phase 3 — Audit trade simulation timing

Review the engine that turns entries into trades.

Required checks:
- what bar the trade enters on
- what price it enters on
- whether same-bar exit is possible
- whether stop vs target tie-break is defined
- whether break-even or trailing only activates from a later bar when intrabar path is ambiguous

Conservative sequencing is acceptable.

Common safe pattern:
- signal computed from bar `t-1`
- entry at bar `t` open
- intrabar exits on bar `t` allowed using high/low
- stop checked before target on the same bar

Flag if:
- entry uses current close but then pretends it was available at open
- a same-bar trail or break-even activates before the bar that triggered it has closed

## Phase 4 — Audit portfolio aggregation timing

Single-symbol timing can be clean while the portfolio still cheats.

Check:
- shared capital limits
- shared concurrency cap
- symbol-level position limits
- sleeve / strategy priority ordering
- chronological merge of trades from different symbols / sleeves

Critical question:

> If two trades start on the same bar, does the portfolio resolve them in a deterministic order with the available capacity at that time?

Red flags:
- `max_concurrent` carried in config but never enforced
- aggregating all symbol PnLs after the fact without filtering impossible overlapping entries
- using per-symbol simulation independently and then summing, as if shared capital did not exist

Clean pattern:
- merge trades chronologically
- enforce shared cap on that merged stream
- deterministic tie-break on same-bar events (e.g. sleeve order, symbol order)

## Phase 5 — Audit live/backtest parity on sizing and controls

Even if timing is clean, research can still be misleading if live and backtest use different risk caps.

Check whether live and research match on:
- leverage-aware notional cap
- per-symbol max position USD
- available-margin buffer
- stop clipping and TP clipping
- risk-per-trade percentage
- shared max positions / concurrency

This is not pure look-ahead, but if it is misaligned, the backtest can claim a risk shape live will never achieve.

## Phase 6 — Add deterministic proof

This is the mandatory proof layer.

Add prefix-invariance / truncation tests.

### Required idea

Take a real series prefix `bars[:N]` and an extended series `bars[:N+K]`.

Recompute the active path on both.

Assert that on the prefix region:
- long entries match
- short entries match
- side decisions match
- stop values match
- target values match
- validator entry materialization matches

If appending future bars changes earlier outputs, the stack repaints.

### Minimum proof set

For active deployment:
- one test for each active sleeve
- one test for the validator / entry-materialization path

## Severity model

### Critical
Deterministic future-data leak.

Examples:
- current-bar close used to enter at current-bar open
- incomplete higher-timeframe bar used for current decision
- future trades implied in portfolio sequencing

### High
No direct future leak, but research result still invalid.

Examples:
- stale-anchor stop sizing mismatch
- live/backtest cap mismatch that changes position scale materially
- same-bar trail activation with impossible path assumption

### Medium
Risk-shape distortion or reproducibility problem.

Examples:
- shared cap ignored in portfolio research
- inconsistent tie-break ordering
- inactive alternate-timeframe path still wired and confusing results

### Low
Documentation or comment drift.

Examples:
- docstring says trailing stop, implementation does not
- comments imply completed bars but caller path is ambiguous

## Required output format

Every audit should produce these sections.

## 1. Active stack in scope
- exact files reviewed
- exact active sleeves / strategies
- explicit note about stale files excluded from decision path

## 2. Verdict
One of:
- `clean`
- `clean with non-lookahead caveats`
- `concerns`
- `critical leak`

## 3. Findings table
For each finding:
- severity
- file path
- line range
- what is wrong
- why it matters
- whether it is look-ahead, repaint, stale-anchor, or parity mismatch

## 4. Clean passes
List the exact places you positively verified as timing-clean.

## 5. Deterministic evidence
- which truncation tests were run
- whether they passed
- what they prove

## 6. Final trust statement
State clearly:
- whether the active deployment stack is lookahead-clean
- what is still not proven by that statement

## Commands and tool patterns

Prefer these tools:
- `Find` for scope mapping
- `Search` for timing keywords (`shift(1)`, `ffill`, `close`, `open`, `_tf`, `rolling`, `ewm`, `entry_bar`, `exit_bar`, `max_concurrent`)
- `Read` for exact code regions
- `Task` with fresh reviewers for independent passes
- `Write` or `Edit` only after evidence is complete

Good search patterns:
- `shift\(1\)`
- `ffill`
- `entry_bar|exit_bar`
- `max_concurrent|max_positions`
- `_tf|timeframe|interval`
- `take_profit|stop_loss|sl_price|tp_price`
- `iloc\[-1\]|close\.iloc\[-1\]`

## Self-knowledge / quant reflections

These are the failure patterns most worth assuming first:

### 1. Current-bar close leaks are the commonest cheat
A signal that uses `close[t]` and claims entry at `open[t]` is wrong unless the strategy explicitly waits for close.

### 2. MTF leaks are more dangerous than single-timeframe leaks
A strategy can look clean in the local timeframe while leaking through higher-timeframe alignment.

### 3. Stale-anchor stop logic can fake edge without future peeking
Not a look-ahead bug, but still a serious audit failure if risk distance is misrepresented.

### 4. Portfolio sequencing bugs create fake robustness
A per-symbol clean strategy can still become a cheating portfolio if shared capital is not enforced in sequence.

### 5. Heuristic auditors are not enough
If the proof does not survive truncation / prefix-invariance testing, do not trust it.

## Final operating principle

A quant backtest is trustworthy only when all four are true:
1. signal timing is clean
2. execution timing is coherent
3. portfolio sequencing is realistic
4. future-bar append does not change prior outputs

If any one is missing, do not call the stack clean.
