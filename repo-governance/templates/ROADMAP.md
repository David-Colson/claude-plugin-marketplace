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

Versioned by git. Entry shape: one fact per entry; one entry = one dated
`- YYYY-MM-DD — ` physical line, never rewrapped (exempt from fill
width); a multi-fact event becomes several dated entries. A correction
cites its target by date and quoted phrase, never by position ("the
entry above" breaks the moment anything is appended or rotated), and
is appended — the original entry stays verbatim. A rotation's
move-not-copy proof anchors on the entry opening (`^- YYYY-MM-DD — `),
since a citation legitimately repeats its target's words. Entries may
rotate at milestone boundaries to `docs/roadmap-archive.md` (verbatim
moves by /6-reroute, never edits) — when they do, a pointer line here
names the archive; the live log and the archive are one append-only
stream.
