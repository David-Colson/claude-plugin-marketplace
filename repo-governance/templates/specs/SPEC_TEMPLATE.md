# Spec {{NN}} — {{CAPABILITY}}

<!-- This file is both the plan and the agent brief. It is the only authority
     for what gets built in this milestone. -->

## Mission

{{ONE_PARAGRAPH — the demonstrable capability and who it is demonstrated to.}}

## Contracts consumed

<!-- Exact signatures, columns, endpoints this milestone depends on, each with
     file:line evidence VERIFIED OPEN-FILE AT AUTHORING TIME. Never from
     memory. A missing contract discovered here is a recorded prerequisite; a
     missing contract discovered mid-build is a landmine. -->

- `{{symbol_or_column}}` — `{{path}}:{{line}}` — {{what it promises}}

## Current state *(verified at HEAD `{{HASH}}`, {{DATE}})*

<!-- The divergence inventory this spec builds from: what exists NOW,
     open-file verified, file:line. Not the mission restated — the ground
     truth that makes mid-build surprises spec defects instead of
     landmines. Re-verify if the tree moves under the spec. -->

- {{FACT}} — `{{path}}:{{line}}`

## Done when

{{OBSERVABLE_BEHAVIOR — what would be demoed, and how.}}

## Not in this milestone

<!-- Name the specific temptations. A general "stay focused" does not work;
     naming the temptations does. -->

- {{TEMPTATION_1}}
- {{TEMPTATION_2}}

## Verification

- `scripts/checks/` pass
- Full test suite green
- End-to-end smoke: {{SMOKE_DESCRIPTION}}

---

## Result *(appended on completion — this is the archive; no file moves)*

- **Decisions / deviations:**
- **As built — deltas from this plan:** <!-- each delta with measured
  evidence; "none" is a claim to earn, not a default -->
- **Contracts exported:** (signature — `path:line`)
- **Evidence:** (test output, demo notes)
- **Parked to LATER.md:**
- **Review verdict:**
