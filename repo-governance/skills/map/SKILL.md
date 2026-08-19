---
name: map
description: Render an at-a-glance status tree of THIS repo's roadmap — closed milestones collapsed, the active one marked, open action items tabbed under what they block and tagged owner-vs-agent, pending specs in recommended order, plus a sequencing note. Read-only always; it maps recorded state and never verifies, writes, or advances. Use when the user says "map", "map this repo", "status", "at a glance", "show me the plan", "where is this repo at". If they want done-conditions verified or the plan pushed forward, that is /advance, not /map — offer it instead.
---

# Map

One read-only view that answers "where is this repo, and what's waiting on
whom?" without triggering the transition ritual. /advance verifies and
moves; **/map only looks.** Built because prose status summaries fail at
multi-repo scale (owner, 2026-08-18: three repos in flight, "skimming
technical summaries is starting to make my head spin").

## Hard rules

- **Read-only, no exceptions.** No writes, no commits, no check/gate runs,
  no Result authoring, no fixing of stale records. The only outputs are
  the tree and a few lines of prose.
- **This repo only.** Map the repo the session is in (its root). Never
  scan sibling directories, never aggregate other repos — even if their
  paths appear in the records being read.
- **Trust the records, and say so.** Status comes from artifacts on disk,
  never from session memory. The map renders what is *recorded*; whether
  reality matches is /advance's evidence problem, and the tree's header
  carries "as recorded" for that reason.
- **Flag contradictions, never repair them.** Where records disagree —
  the "Now" block names a milestone whose spec Result records closure, an
  amendment log entry contradicts a status stamp — render a `⚠` line
  under the affected node quoting both sources (`file:line`). Do not
  guess which side is right.
- **Ungoverned repo → refuse to invent.** No operating rules and no
  roadmap or documented equivalent means there is no plan to map: report
  what's missing, offer /govern-repo, and stop. Scaffold nothing.

## Procedure

### 1. Locate (same sources as /advance, read-only)

`git status --short` and HEAD short-hash for the header. Load the repo's
operating rules (`CLAUDE.md`/`AGENTS.md`), roadmap "Now" block or
equivalent, specs/round docs, LATER/backlog, and the kit/plugin version
where one is recorded; none recorded → omit that header segment.
**Keep-sovereign repos:** the adoption ADR's concept mapping names the
local home of each governed-repo interface function — current-milestone
pointer, gated spec pipeline, close-out record, amendment log — read
those, exactly as /advance would; an unnamed function — or a named home
that is absent on disk — is itself a `⚠` line, not a guess.

### 2. Classify every milestone and side spec

From records alone:

- `✅` **closed** — close-out record present AND the amendment logged AND
  the pointer has moved on (all three; /advance's definition).
- `●` **active** — the current milestone: owner's go recorded and build
  begun, or the "Now" block's milestone awaiting its named prerequisite.
  A side spec in recorded build renders ● too — more than one ● is
  parallel work, not a contradiction.
- `◐` **built/unclosed** — work recorded complete but a done-when or
  close-ritual item is explicitly open (e.g. a Result marked pending).
- `○` **drafted/seeded** — spec or roadmap entry exists, no recorded go.

Open action items come from the records' own gate language (approval
pending, owner pick named, smoke pending, checklist unexecuted). Tag each:

- `YOU ·` — owner gates, /advance's definitions: approvals, picks,
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

     ●=active  ◐=built/unclosed  ○=drafted  ✅=closed  [ ]=open item  ⚠=records disagree
```

Prose after the tree — exactly three things, one or two lines each:
1. **Lead insight** — the single most useful compression ("this repo
   needs only approvals from you", "everything waits on one session in
   X").
2. **Recommended order** — pending items sequenced, with a word on why.
3. **Sequencing note** — which items are order-dependent vs
   parallelizable, citing any hard ordering rules the specs themselves
   record (e.g. "nothing ships mid-eval"). If everything is independent,
   say so in one line.

No prose that restates the tree. No history narration. If the map
surfaced `⚠` lines, end by naming /advance (to verify and fix forward) as
the follow-up — never fix in /map.

## Refusals

- Running checks, selftest, or gates "just to be sure" → never; that is
  /advance.
- Writing anything — including fixing a typo'd status the map revealed →
  never; report it as a `⚠` line.
- Mapping or mentioning sibling repos' state → never; one repo per map.
- Scaffolding a roadmap/spec in an ungoverned repo → never; offer
  /govern-repo.
- Verifying "as recorded" claims against reality → never; the header says
  "as recorded" precisely because the map does not.
