---
name: scrutinize
description: Best-practices and future-proofing review of a governed repo's roadmap or plan — asks "are there industry-standard best practices that would improve this setup, or anything that would better future-proof this plan?", then gates every finding through the repo's own promotion bar so precedent-shopping never becomes scope creep. Deliberately invoked by the owner only — never as an automatic step of another skill. Use when the owner asks while authoring or recutting a roadmap, choosing the next milestone, approaching a one-way door (wire contract, storage schema, release mechanics), after a high-friction milestone, or says "scrutinize", "best practices review", "future-proof this plan", or "review the roadmap against standards".
---

# Scrutinize

The owner's proven question, run with guardrails. Unfiltered, "adopt best
practices" is the exact a-priori move governed repos exist to resist; the
same question gated by local evidence has repeatedly improved real plans.

## Hard rules

- **The prompt generates; the repo's own bar gates; the parking lot and
  decision log land.** The skill supplies no promotion bar of its own —
  where its wording and the repo's documented bar differ, the repo's bar
  wins.
- **A run that recommends adopting everything it found has failed.**
  Adoption is the exception the evidence must earn.
- **Only three writes exist:** the dated survey doc, parking-lot rows, and
  decision-log decline entries. Code, specs, roadmap entries — reading
  them is the job; writing them never is, and *creating new ones counts
  the same as editing*.

## When to run (and when not)

Run when the owner asks, at: roadmap authoring or recutting; choosing the
next milestone (/advance or /govern-repo may *offer* this — only the
owner's acceptance runs it); before a one-way door; after a milestone
whose Result recorded heavy friction.

Do NOT run: mid-milestone to change its scope; on a schedule or recurring
trigger; from another skill's flow without the owner's explicit ask.

## Procedure

### 1. Ground (read-only)

Load the repo's operating rules, roadmap, decision log(s) — including
wherever product decisions live if the repo splits them from governance
ADRs — the parking lot, the most recent Result/close-out sections, and
any prior scrutiny survey docs (so settled items are not re-surveyed).
A roadmap archive, where the amendment log names one, is history:
consult it only to check whether a candidate was already adopted or
declined — never as the live plan.
In a keep-sovereign repo, the adoption ADR's concept-mapping or
divergence doc names the local equivalents of roadmap, parking lot, and
spec pipeline — that mapping is authoritative; never create kit-named
files it says are served elsewhere.

Name the scrutiny target explicitly — the whole roadmap, one milestone
set, or one decision — and confirm it if the request is ambiguous. Note
the repo's promotion bar (e.g. named-failure for machinery, observed-need
for standards content); if none is documented, default to incident-backed
plus the owner's explicit go, and say in the survey doc that the default
was used.

**If the repo has no parking lot, no decision log, or no governance at
all: STOP.** Report what's missing and offer /govern-repo (or ask the
owner to name equivalents). Never create governance files from this
skill; never run the survey ungated.

### 2. Survey (the generator)

Ask the question against the target across the practice domains that
apply: versioning/release, contracts and API evolution, testing and
verification, dependency hygiene, security, data/schema migration, docs
and decision records, CI/automation. For each candidate, record BOTH:

- **Precedent** — the named industry practice or tool it instantiates
  (e.g. semantic versioning, `buf breaking`, Betterer-style ratchets,
  keep-a-changelog, gitleaks, `flutter doctor`). No named precedent →
  not a candidate.
- **Local evidence** — one tag: `incident` (a named failure here),
  `observed-need` (cite file/history), or `none` (speculation — say so
  plainly).

A candidate already in the parking lot is re-cited with its existing row
(checking whether its revisit trigger has fired), never re-added; a
previously declined candidate is not re-reported absent new local
evidence.

### 3. Gate (the filter)

Tier every candidate by the repo's own bar, using the evidence tag:

- **Adopt-candidate** — the tag meets the repo's promotion bar for the
  candidate's class (`incident` for machinery; `incident` or
  `observed-need` for standards content, where the repo distinguishes).
  A `none` tag can never reach this tier — a future-proofing claim
  without local evidence Parks at best. Propose the *smallest*
  mechanization that closes it.
- **Park** — real precedent, the repo's bar not yet met. Gets a parking
  row with a revisit trigger ("promote when X happens").
- **Decline, recorded** — doesn't serve this repo's goals or carries
  noise/tax costs. The reason lands in the decision log — the file that
  exists to stop re-litigation.

### 4. Deliver (the landing zone)

- **A dated survey doc** in the repo's docs/notes area (`docs/`,
  `construction/`, or equivalent — never `specs/`, round docs, or any
  protected/read-only path such as `intake/` or `releases/`). When no
  dated-file convention exists, default to
  `<docs-area>/scrutiny-YYYY-MM-DD-<target>.md`. The survey doc is a
  record of the run, not a register: the parking lot and decision log
  hold the durable state, and a later run never treats a past survey doc
  as overriding them.
- **Parking rows** for the Park tier, written in the lot's own format and
  under its own contract — where the lot requires owner deferral, the
  rows are proposed alongside the survey doc and land on the owner's nod.
- **Decline entries** in the decision log, brief, with the reason.
- **Adopt-candidates:** a recommendation for the owner. On their pick,
  the run ends and the item is handed off as an ordinary task in the
  repo's spec pipeline (specs, round docs + owner's go, or equivalent),
  started at a milestone boundary. This skill authors no spec, adds no
  roadmap entry, writes no code — and the owner's pick does not move the
  boundary for in-flight work.
- **In-flight milestones:** a milestone is in flight once its spec or
  round doc has the owner's go and build has begun; one merely seeded in
  the "Now" block, or drafted but not started, is AT the boundary and may
  be informed through the owner's pick. Findings against in-flight work
  wait at the boundary — except one that gates a one-way door the work is
  about to walk through: surface that to the owner immediately under the
  parking lot's own queue-jump bar, still without editing anything.

## Refusals

- A candidate with no named precedent, or presented without its evidence
  tag → not reported.
- Writing anything beyond the survey doc, parking rows, and decline
  entries — including *new* specs, roadmap entries, or governance files
  → never; on an adopt pick, delivering the handoff is the job.
- Treating "the industry does X" as sufficient by itself → never;
  precedent proposes, local evidence disposes.
- Running from another skill's flow, on a schedule, or without the
  owner's explicit ask in this session → never; other skills may offer,
  only the owner accepts.
