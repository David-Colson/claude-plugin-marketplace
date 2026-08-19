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
- **Contracts exported:** (signature — `path:line`)
- **Evidence:** (test output, demo notes)
- **Parked to LATER.md:**
- **Review verdict:**
