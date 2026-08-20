# Roadmap — {{PROJECT_NAME}}

## Now

<!-- One screen maximum. If this block is stale, nothing else can be trusted. -->

- **Milestone:** M1 — {{SKELETON_CAPABILITY}}
- **Done when:** {{M1_DONE_CONDITION}}
- **Active spec:** `specs/01-{{SKELETON_SLUG}}.md`

## Milestones

<!-- Milestones are demonstrable capabilities, never components.
     "User can X and see Y" — not "finish the API layer".
     Each is sized to one coherent work session.
     Closed milestones rotate to the roadmap archive at the next /6-reroute,
     leaving a one-line pointer (name · close date · ≤1 outcome clause ·
     spec Result ref) — the spec Result stays the authoritative record. -->

### M0.5 — Spike: {{RISKIEST_ASSUMPTION}}  *(include only if the risk is real)*

- **Question it answers:** {{SPIKE_QUESTION}}
- **Done when:** the answer is written into `DECISIONS.md`, with evidence.
- **Not in this milestone:** building anything that assumes the answer.

### M1 — {{SKELETON_CAPABILITY}}  *(walking skeleton)*

Thinnest end-to-end path through every intended layer, doing something trivial
but real. Includes migrations/persistence from day one if the system stores
anything.

- **Done when:** {{M1_DONE_CONDITION}}
- **Not in this milestone:** {{M1_NON_GOALS}}

### M2 — {{NEXT_CAPABILITY}}

- **Done when:**
- **Not in this milestone:**

## Non-goals

<!-- Out is a recorded state, not ambient fading. -->

| What | Until when | Why |
|---|---|---|
| {{NON_GOAL_1}} | {{UNTIL}} | {{WHY}} |

## Amendment log

Versioned by git. A one-line entry here per re-plan, at milestone boundaries
only: date, what changed, why. Entries may rotate at milestone boundaries
to `docs/roadmap-archive.md` (verbatim moves by /6-reroute, never edits) —
when they do, a pointer line here names the archive; the live log and
the archive are one append-only stream.
