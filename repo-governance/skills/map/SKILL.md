---
name: map
description: Render THIS repo's territory — everything beyond the current route: the backlog census (parked rows, decision-log revisit triggers, obligations recorded in closed specs), what's decidedly out of scope (non-goals, recorded declines), and where the archived history lives. Read-only always. Use when the user says "map", "the bigger picture", "what's in the backlog", "what's parked", "what's out of scope". For the current plan in sequence that is /route; to rebuild the route from this territory, /recut.
---

# Map

The territory view. /route shows the road the repo is on; **/map shows
everything else** — what's waiting in the backlog, what was deliberately
ruled out, and where the past is filed. Read-only, records-not-memory.
Doctrine: **the map is free; the route is gated** — anything can land
here at any time without ceremony; nothing here enters the route except
through /recut or an /advance boundary pick.

## Hard rules

- **Read-only, no exceptions.** No writes, no check runs, no exports,
  no repairs of stale records. Output is the census and a few lines of
  prose.
- **This repo only.** Never scan sibling directories or aggregate other
  repos, even when this repo's records name them.
- **Trust the records, and say so.** Status comes from artifacts on
  disk; the header carries "as recorded".
- **Single sources render once.** ADR revisit triggers render from the
  decision log ONLY (a LATER row may cite an ADR, never restate its
  trigger); approved-unbuilt specs render from `specs/` directly and get
  no backlog row. Where two records restate one fact and disagree,
  render a `⚠` line quoting both (`file:line`) — never repair.
- **Ungoverned repo → refuse to invent.** No operating rules and no
  roadmap or documented equivalent: report what's missing, offer
  /govern-repo, stop.

## Procedure

### 1. Locate (read-only)

Load the repo's operating rules, roadmap or equivalent (for Non-goals
and the archive pointer its amendment-log header names), the parking lot
(LATER/backlog), the decision log(s), and closed specs' close-out
records. **Keep-sovereign repos:** read through the adoption ADR's
four-function mapping, plus the mapped parking lot and decision log; an
unnamed function — or a named home absent on disk — is a `⚠` line, not
a guess. Any repo: a census source named by its rules but absent on
disk is the same `⚠` line, never a silently omitted section.

### 2. Assemble the backlog census

**The backlog census** — parked rows, decision-log revisit triggers and
recorded declines, and open obligations in close-out records — assembled
fresh from those sources each run:

- **Parked rows:** every parking-lot row, grouped by its recorded
  origin, each marked `blocked` (its note names — or its cited ADR
  records — an unfired trigger) or `eligible` (trigger fired, or none).
- **Revisit triggers:** every live "Revisit when" clause in the decision
  log(s), one line each — skip Standing/Never and fired-and-consumed
  ones.
- **Spec-embedded obligations:** OPEN/parked/pending items in closed
  specs' Result and Not-in sections that no other surface carries — each
  quoted with `file:line` and flagged `⚠ single-homed` (an export
  candidate for /recut — the close ritual only covers specs still
  closing).
- **Declines:** decision-log entries that exist to stop re-litigation,
  one line each.

### 3. Render

Fenced block. Header as /route's (repo · version-as-recorded · HEAD ·
"as recorded — map"). Then sections, each with its count, zero-content
sections omitted:

```text
route: → /route for the queue

backlog (N):
  <origin group> · <row one-liner> · blocked|eligible
revisit triggers (N):
  ADR-<n> · <clause one-liner>
obligations in closed specs (N):        ⚠ single-homed
  <spec>:<line> · <one-liner>
non-goals (N):
  <what> · until <when>
declines (N):
  ADR-<n> · <one-liner>
archive: <pointer the roadmap names, or "none — nothing rotated yet">
```

Prose after: at most two lines — the single most useful compression
("N items eligible for the next recut", "the census is clean; nothing
single-homed"). No sequencing advice (that is /route), no promotion
recommendations (that is /recut's plan).

## Refusals

- Sequencing or next-action advice → /route.
- Exporting, promoting, or writing ANYTHING — including fixing a stale
  row the census revealed → /recut or /advance's close ritual; render
  the `⚠` line instead.
- Restating an ADR trigger from a parking-lot row → never; the decision
  log is the single source.
- Mapping sibling repos → never; one repo per map.
- Scaffolding in an ungoverned repo → never; offer /govern-repo.
