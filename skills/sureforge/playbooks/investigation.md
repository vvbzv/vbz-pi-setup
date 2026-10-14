# Investigation playbook

## When

A read-only question: how something works, why it was built this way, or whether an approach is sound. The deliverable is a cited answer.

## Steps

1. State the question and the done criterion: what answer, with what evidence, settles it.
2. Gather sources: code, configuration, runtime behavior, primary external documentation. Prefer the actual system over summaries of it.
3. Separate observed, sourced, and inferred statements. An inference that cannot be checked stays labelled as one.
4. Answer with evidence attached to each claim and name the limits of the investigation.
5. Do not implement while investigating. If the answer implies a change, recommend it and stop: implementation is a separate task with its own contract.

## Gate mapping

- Research: the question and the evidence needed to answer it are fixed; decisive unknowns are resolved or explicitly bounded.
- Execute: the investigation itself is the work; no artifact changes are made or hidden as "investigation".
- Deliver: READY is a supported answer with citations and stated limits, not an implementation.

## Evidence required

Sources consulted with locations, observed behavior with commands, and a clear list of what was not checked.
