# Performance playbook

## When

A measured slowness or a claimed speedup to establish against a baseline.

## Steps

1. Define the metric, its unit, and the workload before changing anything.
2. Measure the baseline on the real workload in the agreed environment and keep the raw output. One number without its command is not a baseline.
3. Change the implementation. Keep the workload identical; if it must change, record that and re-baseline.
4. Re-measure with the same method, workload, and environment. Repeat enough to see variance when the difference is small.
5. Explain the number: what limits it, and what could make the change look better or worse than it is. A regression that is real gets reported, not hidden.

## Gate mapping

- Plan: the metric, workload, environment, and measurement command are fixed.
- Execute: READY requires before/after numbers produced by the same method; different methods on the two sides do not count.
- Deliver: the final report states the measured delta, the environment, and the residual uncertainty.

## Evidence required

Measurement command, raw before and after output, workload description, environment, variance or repetition count when available. A predicted improvement is labelled a prediction, never reported as measured.
