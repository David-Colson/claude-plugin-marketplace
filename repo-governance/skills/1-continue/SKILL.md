---
name: 1-continue
description: Nudge a governed repo forward through its plan — verify the current milestone's done-conditions with evidence, run the close ritual when they're met, then initiate the next milestone's build (delivering its spec draft for the owner's go first). Use when the user says "continue", "advance", "nudge this forward", "what's next", "continue the plan", "next milestone", "push this repo along", or opens a session in a governed repo asking where things stand.
---

# Continue

One procedure to move a governed repo from "where were we?" to "building
the right next thing" without skipping gates. The failures this prevents
are recorded, not hypothetical: Result sections left unfilled after
milestone runs, a stale roadmap "Now" block, every transition waiting on a
manual prod. The skill mechanizes the transition ritual — it never
mechanizes the owner's decisions.

## Hard rules

- **Evidence or it isn't done.** A done-when item is verified by running
  the named check/gate or reading the named artifact (`file:line`) — never
  by assuming, never from memory of a prior session.
- **Owner gates survive nudging.** Approach choices, spec approvals,
  milestone picks, roadmap-named owner conditions, plan-style approvals —
  the nudge stops AT a gate, never through it. A gate reached is a success
  state, not a stall.
- **Decisions already recorded stay made.** A chosen approach, spec scope,
  or logged owner ruling is not re-litigated by a nudge; a discovered need
  to deviate is a gate — STOP with the proposal, don't build the deviation.
- **Never author Result content that wasn't demonstrated.** Missing
  evidence is a gap to report, not to paper over.
- **Respect the repo's own system.** Kit-style (ROADMAP "Now" + `specs/`)
  or its documented equivalent. In a keep-sovereign repo, the adoption
  ADR's concept-mapping or divergence doc names the local home of each of
  the governed-repo interface's four functions —
  **current-milestone pointer, gated spec pipeline, close-out record,
  amendment log** — and that mapping is authoritative: write into those,
  never into kit-named files it says are served elsewhere. An unnamed
  function is a gap to deliver as a gate (ask the owner to name it),
  never to guess around.

## Procedure

### 1. Locate (read-only)

`git status` first — surface uncommitted work. Read-only verification
(steps 1–2) may proceed over a dirty tree, but no write branch — close
ritual, spec drafting, build — starts until the human decides
commit/stash; running unattended, report the dirty tree as the gate and
stop before any write. A branch behind or diverged from its upstream is
the same gate: verify against the local tree and say what upstream holds,
but syncing (`git pull`, fast-forward or otherwise) is the owner's
decision — deliver it, never pull unprompted.

Load the repo's operating rules (`CLAUDE.md`/`AGENTS.md`), the roadmap
"Now" block or equivalent, and the active spec/round doc. **If the repo
has no operating rules, no roadmap or documented equivalent — no plan to
advance — STOP:** report what's missing and offer /init-cartography (or ask
the owner to name equivalents). Never scaffold roadmaps, specs, or any
governance file from this skill.

Identify the **current** milestone. *Current means in flight*: its spec
or round doc has the owner's go and build has begun — the same definition
/4-scrutinize uses. A milestone merely seeded in the "Now" block, with no
approved spec or no build begun, is not current — it is the *next*
milestone: step 2 then verifies the most recent milestone that WAS in
flight (its closure is what needs checking), and step 3 handles the
seeded one. If no milestone has ever been in flight, skip step 2.

### 2. Verify the current milestone

Check every done-when item with evidence: run `scripts/checks/` or the
repo's gates, read the named artifacts, cite `file:line`. Reach a verdict:

- **Incomplete** → the nudge IS the remaining work. List the gaps with
  evidence, then continue building the CURRENT milestone against its
  approved spec, under the repo's working rules and its recorded
  decisions. A gap that requires any decision the spec does not already
  record is a gate, not remaining work. Do not touch the next milestone.
- **Blocked** → a gap's remaining work needs an action only the owner can
  take (funding, credentials, an external account or third-party
  dependency): do not attempt or retry it. Record the blocker and the
  exact unblock action where the repo's status lives (Now block, STATE,
  or equivalent), and deliver it as the gate — cross-session or off-repo
  unblock actions use the shape in `templates/HANDOFF_PROMPT.md`.
- **Complete but unclosed** → run the close ritual: append the Result
  section (or the repo's close-out equivalent) from evidence gathered
  THIS run — verbatim numbers and hashes; re-run reproducible checks
  after the ritual writes so the evidence describes the tree being
  committed; irreproducible items cite their recorded artifact.
  **A spec never closes holding OPEN items:** every obligation left open
  in its Result or Not-in sections gets a parking-lot row (a pointer,
  never a restatement) or a recorded decline before the ritual's commit.
  A near-cap roadmap (≥85% of the repo's line cap) is reported in the
  ritual's output — never rotated here; rotation is /6-reroute's. Add the
  amendment-log entry, advance the "Now" block (or the mapped
  equivalents). Commit the ritual writes — and only them; pre-existing
  uncommitted work never rides along — where the repo's conventions
  permit unprompted commits; where the repo gates commits, leave the
  writes in the tree and name the commit as the owner's next action.
  Never push. Then proceed to step 3.
- **Closed** (Result present, amendment logged — in the live log or the
  archive its header names — and "Now" advanced; all three; anything
  partial is complete-but-unclosed: finish the ritual) → proceed to
  step 3.

### 3. Initiate the next milestone

- **Spec exists and has the owner's go** (kit: spec approved; case-law:
  §5-CONFIRM-style gate answered) → open the build against it. Unchosen
  design forks still get propose-2–3-and-STOP — no code until one is
  chosen.
- **Spec drafted but not approved** → deliver the approval gate: present
  the spec (or its confirm questions) and STOP.
- **Milestone defined, no spec** → honor any owner input the roadmap
  entry itself names as prerequisite ("authored once the owner picks…")
  by delivering that gate first. Otherwise author the spec **draft** from
  the roadmap entry plus `LATER.md`/backlog candidates, per the repo's
  spec conventions, then **STOP for the owner's go on the spec** —
  authoring is never a license to build.
- **No next milestone defined** → propose 1–3 candidates from the
  repo's own goals, recorded friction, and **the backlog census** —
  parked rows, decision-log revisit triggers and recorded declines, and
  open obligations in close-out records (the same census /3-map renders) —
  each with its local evidence tag (incident / observed-need / none —
  /4-scrutinize's tags) so the promotion bar is auditable, and **STOP for
  the owner's pick.** The pick selects the milestone only; seeding the
  roadmap and authoring its spec then proceed under this step's own
  gates. This boundary pick is the ONE route-entry path besides /6-reroute
  (the map is free; the route is gated). You may OFFER /4-scrutinize or
  /6-reroute at this boundary; never run either — nor an inline survey —
  without the owner's explicit acceptance.

### 4. Report

Whatever branch ran, end with: what was verified (with its evidence),
what was closed or built, and the exact gate now awaiting the owner — if
any. One next action, named concretely.

## Refusals

- Marking a done-when item complete without running its evidence → never.
- Advancing past an owner gate (approach choice, spec approval, milestone
  pick, roadmap-named owner condition, non-goal promotion) → never;
  delivering the gate is the job.
- Authoring a spec and building against it in the same run → never; the
  owner's go on the spec comes first.
- Retrying an owner-only blocker (funding, credentials, external
  accounts) → never; record and deliver it as the gate.
- Scaffolding governance files in an ungoverned repo → never; that is
  /init-cartography's job, offered not assumed.
- Starting work that sits on the repo's non-goals list → escalate per the
  repo's rules instead of building.
- Fixing unrelated breakage discovered en route → record it (LATER.md or
  the repo's parking lot) and stay on the milestone.
