---
name: 6-reroute
description: Rebuild a governed repo's route — the owner-gated course-correction workflow. Reads design intent and the full backlog census, then proposes ONE recut plan: new milestones organizing backlog items, adjustments to unstarted milestones where intent shifted, and rotation of closed history to the archives (roadmap history to the roadmap archive; spent/fired/superseded/absorbed ADRs to the decisions archive). Writes nothing until the owner approves the plan. Use when the user says "reroute", "recut", "reorganize the roadmap", "adjust course", "the roadmap is stale", "fold the backlog into the plan", or when /2-route has flagged the roadmap or the decision log near its line cap and the owner asks for the rotation. To see state without changing it, /2-route and /3-map; to progress the existing plan, /1-continue.
---

# Reroute

The route's only rebuilder. Doctrine: **the map is free; the route is
gated** — ideas accumulate on the map without ceremony, and this
workflow is how they enter the route (the other path: /1-continue's
boundary pick). /2-route and /3-map look; /1-continue moves along the existing
plan; **/6-reroute redraws the plan** — under the owner's gate, never past
it.

## Hard rules

- **One plan, one gate, then apply.** Phases A–B write nothing. The
  approved plan is the ONLY authority for Phase C writes. If approval is
  declined, the plan itself is the deliverable — write nothing
  (init-cartography doctrine).
- **In-flight milestones are untouchable.** A milestone whose spec has
  the owner's go and build begun is not adjusted, split, or re-scoped
  here — a discovered need to change one is delivered as its own gate,
  not folded into the recut.
- **Archives are append-only and verbatim.** Rotation MOVES content,
  never edits, summarizes, or deletes it; every rotated block gets a
  stamp line (`— rotated YYYY-MM-DD from <file> by /6-reroute`). This skill
  is the SOLE mover; /2-route and /1-continue only flag.
- **Nothing on the map is deleted.** A backlog item the recut rejects
  becomes a recorded decline in the decision log — declines stop
  re-litigation; deletion invites it.
- **Goals and posture are the owner's text.** The recut reads them as
  intent; proposing a Goals change is allowed, applying one requires its
  own explicit owner ruling, quoted in the plan.
- **Keep-sovereign repos keep their shapes.** Work through the adoption
  ADR's four-function mapping; propose within the repo's own structures
  (e.g. extending an existing archive convention). An absent archive
  convention is a drafted question with a default; an unmapped function
  is a gate. Never impose kit-named files.

## Procedure

### Phase A — Survey (read-only)

Load: the route (roadmap or mapped equivalent — Now, open milestones,
Non-goals, amendment log + any archive its header names);
**the backlog census** — parked rows, decision-log revisit triggers and
recorded declines, and open obligations in close-out records; design intent
(Goals, posture, owner statements recorded in the amendment log); and
any dated survey/research docs in the docs area (scrutiny, scout) —
their candidates enter the draft WITH their recorded evidence tags;
nothing enters merely for having been researched.

### Phase B — The recut plan (plan style, still read-only)

Assemble ONE plan, every item drafted with its origin and evidence tag:

1. **New milestones** — backlog items organized into candidate
   milestones (dependency-ordered per the owner doctrine: task-DAG
   action queues, never calendar time), each item citing its map source;
   items that don't clear the repo's promotion bar stay on the map,
   stated plainly.
2. **Adjusted milestones** — unstarted (seeded/approved-unbuilt) route
   entries reshaped where recorded intent shifted, each adjustment
   citing the intent statement it follows.
3. **Rotation manifest** — the exact amendment-log entries and closed
   milestone blocks to move, verbatim, to the archive; the live log
   keeps its most recent window (default 5 entries) plus any entry that
   is the sole live pointer to a standing candidate or unexported
   obligation; closed milestones compress to one-line pointers (name ·
   close date · ≤1 outcome clause · close-out record ref). The manifest
   also lists decision-log rotation: ADRs whose `**Status:**` is spent,
   fired, superseded, or absorbed move verbatim, stamped, to the
   decisions archive (ADR-015 amendment; live and standing never move).
4. **Map hygiene** — parking-lot rows consumed by new milestones;
   single-homed spec obligations exported to rows (pointer, never
   restatement); stale row notes corrected; rejected items → drafted
   decline entries.
5. **Sovereign dispositions** (keep-sovereign repos) — every proposal
   phrased in the repo's own structures, defaults drafted for gaps.

Present the plan for approval using the lightest facility available.
**STOP until approved.** Genuine forks get 2–3 options with a
recommendation.

### Phase C — Apply (only after approval)

1. Append rotation blocks to the archives with stamp lines (kit repos:
   `docs/roadmap-archive.md` and `docs/decisions-archive.md`, each
   created from its `${CLAUDE_PLUGIN_ROOT}/templates/` counterpart if
   absent; sovereign repos: the approved local convention).
2. Rewrite the roadmap's forward sections per the plan; add the archive
   pointer line to the amendment-log header.
3. Execute map hygiene exactly as approved (rows added/cleared, decline
   entries appended to the decision log).
4. Append the recut's amendment entries in the log's own entry shape —
   where that shape is one fact per dated line, the recut writes
   several (what rotated · what entered the route · what was
   declined), not one entry carrying all three.
5. Commit the recut writes — and only them — where the repo's
   conventions permit unprompted commits; never push. Then hand off:
   the next action is /2-route (see the new sequence) or /1-continue (start
   the first new milestone through its gates).

## Refusals

- Writing anything before the plan is approved → never.
- Touching an in-flight milestone → never; deliver it as its own gate.
- Editing, summarizing, or deleting archived or rotated content → never.
- Deleting a backlog item → never; declines are recorded, not erased.
- Applying a Goals/posture change without its own quoted owner ruling →
  never.
- Creating kit-named files in a keep-sovereign repo → never; propose
  within its structures.
- Running from another skill's flow or on a schedule → never; /2-route
  and /1-continue may OFFER a recut — /1-continue's report offers one
  at every milestone boundary — but only the owner runs one.
