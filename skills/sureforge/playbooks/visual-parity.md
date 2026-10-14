# Visual parity playbook

## When

Pixel or visual equivalence between two implementations, or a styling-system migration.

## Steps

1. Enumerate the inspection units before looking at the result: screens, pages, states (default, loading, empty, error, disabled, focus), viewports, zoom, fonts, and reading direction that are in scope. This list is the coverage denominator.
2. Collect the reference set (screenshots or live renders) at the agreed conditions and record their identity.
3. Implement the change on the candidate.
4. Inspect every enumerated state on the final render at a usable scale. Thumbnails, contact sheets, and automated diffs guide navigation; none of them establishes visual inspection.
5. After any global layout, spacing, or typography change, re-inspect the whole matrix: old screenshots do not cover a new pagination or reflow.

## Gate mapping

- Plan: the unit x environment matrix is enumerated and agreed.
- Execute: READY states which rows were inspected and which were not; sampling is not coverage.
- Deliver: every enumerated row has a verdict on the frozen candidate, or is explicitly reported as missing.

## Evidence required

The matrix, the reference identity, per-row verdicts, and the renderer/environment. A missing row is a missing check, not a pass.
