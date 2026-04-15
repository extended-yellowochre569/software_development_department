---
name: diagnose
description: "Orchestrates the Tier 2 diagnostic agents (Investigator, Verifier, Solver) to handle complex bugs with high precision and empirical verification."
---

# Skill: /diagnose

Use this skill when a bug is complex, intermittent, or occurs in unfamiliar parts of the codebase. It implements a multi-stage pipeline to ensure that fixes are based on verified facts, not assumptions.

## Workflow Execution

### Step 1: Investigation (Investigator)
Call the `investigator` agent to:
- Trace the execution path.
- Gather empirical evidence (logs, traces).
- Identify the root cause.
- Result: **Investigation Report** (JSON).

### Step 2: Verification (Verifier)
Pass the Investigation Report to the `verifier` agent to:
- Attempt to refute the findings (Devil's Advocate).
- Reproduce the symptom using triangulation.
- Confirm the cause is both necessary and sufficient.
- Result: **Verification Report** (JSON).

### Step 3: Solution (Solver)
Pass the Verification Report to the `solver` agent to:
- Generate 3 solution options (Quick, Strategic, Future-Proof).
- Perform tradeoff analysis.
- Create a surgical implementation plan.
- Result: **Solution Proposal** (JSON).

### Step 4: Finalization (Lead Programmer)
Pass the Solution Proposal to the `lead-programmer` for:
- Solution selection.
- Assignment to a specialist developer.

## Usage Guidelines

- Always start with a specific symptom or bug ID from `TODO.md`.
- Ensure all intermediate reports are saved in `.investigations/` for traceability.
- If any stage returns an "Inconclusive" status, stop and notify the user for additional context or manual intervention.
