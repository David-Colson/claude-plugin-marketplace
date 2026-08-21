# {{PROJECT_NAME}} — Agent Operating Rules

## Posture

{{POSTURE_STATEMENT}}
<!-- Example: "This is a v0 prototype: single user, localhost, throwaway data.
     Auth, rate limiting, input hardening, and multi-tenancy are explicitly out
     of scope until v1." Build for THIS reality, not the most demanding one. -->

## Invariants

- No file over {{MAX_FILE_LINES}} lines. If a change would exceed the limit,
  split first, then make the change.
- Each module has one reason to change, stated in a comment at the top.
- Layer direction: {{LAYER_DIRECTION}}. Never the reverse.
- New dependencies require asking first.
- Never write under {{PROTECTED_PATHS}}. Original data is read-only reference
  material: derive from it, never overwrite it. (Hook-enforced.)

## Working rules

- No spec, no code. Build only against the active spec in `specs/`.
- Before any milestone with real design content: propose 2–3 approaches with
  trade-offs and a recommendation. **No code until one is chosen.**
- The promotion bar judges one item at a time — but when the owner names a
  capability, the capability is the unit it judges, and the parked items
  become its cited parts. Promoting only the parts whose triggers fired
  would ship half a capability.
- Escalation: if completing the milestone appears to require violating an
  invariant or doing work on the non-goals list, **stop and write a proposal
  instead of code.**
- Anything encountered mid-build that isn't in the spec goes to `LATER.md`,
  not into code.
- Definition of done always includes: `scripts/checks/` pass and the full test
  suite is green; at close-out the ratchet's tighten mode runs where a length
  baseline exists, so ceilings follow shrunk files down.
- On completion of a milestone, append the Result section to its spec.
- Plans are dependency-ordered action queues (task-DAG shape), never
  calendar time. Effort is stated in relative size or token/cost units,
  not hours or days.
- Code optimizes for AI cognitive ergonomics — its primary reader is an
  agent. Polish serving human readers who will never exist is declined;
  owner-facing records (roadmap, spec gates, status views) still serve
  the owner.
- Prefer s-expressions over JSON wherever the format is ours to choose.
  Platform-mandated formats (`.claude/settings.json`, plugin/package
  manifests, tool-required schemas) are exempt — never sexpr-ify a file
  the platform parses as JSON.

## Loading order

1. This file
2. `ROADMAP.md` — the "Now" block
3. The active spec in `specs/`
