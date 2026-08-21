---
name: 2-route
description: Render THIS repo's current route — the roadmap as the owner's dependency-ordered action queue: the active milestone, open nodes, every owner action in sequence with what each unlocks, open repairs, and the ship/near-cap flags. Read-only always; it renders recorded state and never verifies, writes, or advances. Use when the user says "route", "status", "what's next in order", "show me the plan", "where is this repo at". For the broader territory (backlog, out-of-scope, archive) that is /3-map; to verify or move forward, /1-continue; to rebuild the route, /6-reroute.
---

# Route

One read-only view that answers "where is this repo, and what must the
owner do next, in order?" — the owner doctrine (plans are
dependency-ordered action queues, never calendar time) applied to the
status view. /1-continue verifies and moves; /6-reroute rebuilds; **/2-route only
looks.** Built because prose status summaries fail at multi-repo scale
(owner, 2026-08-18: three repos in flight, "skimming technical summaries
is starting to make my head spin").

## Hard rules

- **Read-only, no exceptions.** No writes, no commits, no check/gate runs,
  no Result authoring, no fixing of stale records. The only outputs are
  the tree and a few lines of prose.
- **This repo only.** Map the repo the session is in (its root). Never
  scan sibling directories, never aggregate other repos — even if their
  paths appear in the records being read.
- **Trust the records, and say so.** Status comes from artifacts on disk,
  never from session memory. The route renders what is *recorded*; whether
  reality matches is /1-continue's evidence problem, and the tree's header
  carries "as recorded" for that reason.
- **Flag contradictions, never repair them.** Where records disagree —
  the "Now" block names a milestone whose spec Result records closure, an
  amendment log entry contradicts a status stamp — render a `⚠` line
  under the affected node quoting both sources (`file:line`). Do not
  guess which side is right.
- **Ungoverned repo → refuse to invent.** No operating rules and no
  roadmap or documented equivalent means there is no plan to map: report
  what's missing, offer /init-cartography, and stop. Scaffold nothing.

## Procedure

### 1. Locate (same sources as /1-continue, read-only)

`git status --short` and HEAD short-hash for the header. Load the repo's
operating rules (`CLAUDE.md`/`AGENTS.md`), roadmap "Now" block or
equivalent, specs/round docs, and the kit/plugin version where one is
recorded; none recorded → omit that header segment. (LATER/backlog is
NOT a route input — the backlog is /3-map's territory; the route renders
only what the roadmap and open specs already commit to.)
**Keep-sovereign repos:** the adoption ADR's concept mapping names the
local home of each governed-repo interface function —
current-milestone pointer, gated spec pipeline, close-out record,
amendment log — read those, exactly as /1-continue would; an unnamed
function — or a named home that is absent on disk — is itself a `⚠`
line, not a guess.

### 2. Classify every milestone and side spec

From records alone. Where a spec carries a `**State:**` token (draft |
approved | building | closed — spec 15's shape), read it first;
gate-language prose is the fallback for specs that predate it:

- `✅` **closed** — close-out record present AND the amendment logged AND
  the pointer has moved on (all three; /1-continue's definition).
- `●` **active** — in flight (owner's go recorded and build begun), or
  the "Now" block's milestone awaiting its named prerequisite (renders
  ●, not ○). A side spec in recorded build renders ● too — more than
  one ● is parallel work, not a contradiction.
- `◐` **built/unclosed** — work recorded complete but a done-when or
  close-ritual item is explicitly open (e.g. a Result marked pending).
- `○` **drafted/seeded** — spec or roadmap entry exists and build has
  not begun: no recorded go, or a go recorded but the start deferred
  (approved-unbuilt).

Open action items come from the records' own gate language (approval
pending, owner pick named, smoke pending, checklist unexecuted). Tag each:

- `YOU ·` — owner gates, /1-continue's definitions: approvals, picks,
  roadmap-named owner conditions, owner-session work in another repo,
  external/blocker actions.
- `me ·` — agent work that an already-given or pending approval unblocks.

### 3. Render

Fenced code block, then at most a few lines of prose. Shape:

```text
<repo> ── <kit/plugin version(s) as recorded> ── HEAD <hash> [· dirty: N files]   (as recorded)
│
├─ ✅ <closed milestones, one line each, collapsed> ... closed <date> (<record ref>)
│
├─ ◐ <built/unclosed item> ................ <what's open>
│    └─ [ ] YOU · <the exact open action, concretely>
│
├─ ○ <drafted item> ....................... awaiting <gate>
│    └─ [ ] <tag> · <action>
│
└─ ● <active milestone> ................... <state>
     └─ [ ] <tag> · <action>
            ↳ <what completing it unlocks>

     ●=active  ◐=built/unclosed  ○=drafted  ✅=closed  [ ]=open item  ⚠=flag (records disagree · near cap)
```

Below the tree, the queue — the view's whole point:

```text
YOUR ROUTE — dependency order
 1. [ ] YOU · <action> (<record ref>)
        ↳ unlocks: me · <the agent work this gates>
 2. [ ] YOU ⇢ independent · <action in another session/repo> (<ref>)
```

Queue rules: numbered steps are OWNER actions only, dependency-ordered;
steps runnable in any order are marked `⇢ independent`; gated agent work
appears only as `↳ unlocks` lines under the owner step that gates it,
never as numbered steps; every step cites its record; open REPAIRS
(bug-exception work in flight — a patch the owner's word opened, not yet
shipped/recorded) render as transient `[R]` steps at the top. An empty
queue renders exactly: `route clear — no owner action recorded; /1-continue
to verify and move.`

Prose after the queue — exactly two things, one or two lines each:
1. **Lead insight** — the single most useful compression ("this repo
   needs only approvals from you", "everything waits on one session in
   X").
2. **Sequencing note** — which items are order-dependent vs
   parallelizable, citing any hard ordering rules the specs themselves
   record (e.g. "nothing ships mid-eval"). If everything is independent,
   say so in one line. (The queue itself IS the recommended order.)

No prose that restates the tree. No history narration. If the route
surfaced `⚠` lines, end by naming /1-continue (to verify and fix forward) as
the follow-up — never fix here.

**Ship flag** — only in a repo whose own records name a delivery step
(e.g. this kit's dev repo: /ship, ADR-011). After the prose, end with one
line — `⇪ ship needed — <why, one clause>` — when the delivery payload is
stale as derivable from the repo's records and git ALONE: payload paths
(as the delivery step's own docs define them) are dirty, or carry commits
newer than the last commit that changed the recorded version. Clean, or
no delivery step recorded → no line at all. The flag is a recorded-state
inference, not a verification: /ship itself is the check, and delivery
targets outside the repo root (installed copies, remote marketplaces) are
never read to confirm.

**Near-cap flag** — when the roadmap file (or its mapped equivalent) is
at ≥85% of the repo's recorded line cap, or the decision log is at ≥90%
(chunkier entries, smaller rotation sets — ADR-015 amendment), end with
one line per affected file:
`⚠ <file> near cap (<n>/<cap> lines) — run /6-reroute to rotate history`.
Report only; rotation is /6-reroute's, never this skill's.

End with one pointer line: `backlog and scope: /3-map`.

## Refusals

- Running checks, selftest, or gates "just to be sure" → never; that is
  /1-continue.
- Writing anything — including fixing a typo'd status the route
  revealed, or rotating a near-cap roadmap → never; report the ⚠ line;
  rotation is /6-reroute's.
- Rendering the backlog census (parked rows, revisit triggers, spec
  obligations) → never; that is /3-map's territory.
- Mapping or mentioning sibling repos' state → never; one repo per
  route.
- Scaffolding a roadmap/spec in an ungoverned repo → never; offer
  /init-cartography.
- Verifying "as recorded" claims against reality → never; the header
  says "as recorded" precisely because the route does not.
