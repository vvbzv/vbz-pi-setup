# Bug fix playbook

## When

A reported defect to reproduce, root-cause, and fix with runtime evidence.

## Steps

1. Capture the report as a reproduction, not a summary. On a code path with tests, write the failing test first. Without a test surface, record the exact command, input, and environment that shows the symptom.
2. Freeze the failing evidence under the artifact identity it applies to: the repro command and its output belong in the execute gate.
3. Root-cause before editing: trace the symptom to the cause. Fixing the first plausible site without a mechanism is a guess; say so if the cause is only inferred.
4. Fix the cause, then rerun the same reproduction and the surrounding regression scope on the new snapshot.
5. If the fix crosses a function boundary or changes an interface, return to the plan gate and revise the plan before dependent work continues.

## Gate mapping

- Research: the reproduction command and observed failure are named; the expected behavior comes from the contract, not from the current code.
- Plan: the fix is mapped to a step and the repro is mapped to a verification method.
- Execute: READY requires failing-before and passing-after evidence from the same reproduction on the same environment.
- Deliver: the reproduction is rerun on the frozen final candidate; a passing test on an unfrozen intermediate does not count.

## Evidence required

Repro command, pre-fix output, post-fix output, environment, artifact version. A claim that the bug is fixed without a rerun is unverified.
