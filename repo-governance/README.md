# repo-governance

A Claude Code plugin that sets up or retrofits governance on agent-built repos — any starting state.

The kit constrains **invariants, boundaries, done-conditions, and production
posture — never implementation.** The agent owns the "how"; the human owns the
"what" and "whether". Three layers of constraint, ordered by how well they
survive: mechanical checks (work when nobody is paying attention), spec
done-conditions (work within a session), prose invariants (work when the agent
is attentive).

## What's in it

Skills are numbered by rough usage sequence; `init-` skills are one-time
setup. (Rename mapping for older records: ADR-016.)

- **`skills/init-cartography`** — one-time: bring any repo under
  governance (empty, artifacts-only, or legacy): Survey (read-only;
  dropped artifacts are evidence, tagged stated-vs-inferred) → Draft &
  Confirm (every decision drafted with evidence; plan-style gate; the
  human picks, never authors essays) → Apply (merge-never-clobber,
  ratchet baselines, prove checks fire, governance ADR). Re-runs re-sync
  standards only — they never redraft the roadmap.
- **`skills/init-ship`** *(approved, unbuilt — spec 10)* — one-time: set
  up a repo's delivery skill. Survey how the repo actually ships,
  confirm the delivery contract, instantiate a repo-local /ship, prove
  it live.
- **`skills/1-continue`** — the transition ritual: verify the current
  milestone's done-conditions with evidence, run the close ritual when
  met (Result, amendment log, "Now" block; a spec never closes holding
  OPEN items), then open the next leg — stopping AT every owner gate,
  never through it. Kit-style and case-law repos alike.
- **`skills/2-route`** — the roadmap as the owner's dependency-ordered
  action queue, read-only: active milestone, open nodes, every owner
  action in sequence with what it unlocks, open repairs, ship and
  near-cap flags. Contradictions flag, never repair.
- **`skills/3-map`** — the territory beyond the route, read-only: the
  backlog census (parking-lot rows, decision-log revisit triggers,
  obligations in closed specs — single-homed ones flagged), non-goals,
  recorded declines, archive pointer. The map is free; the route is
  gated.
- **`skills/4-scrutinize`** — the future-proofing question run with
  guardrails: every candidate needs a named precedent AND a local
  evidence tag, tiered by the repo's own bar (adopt / park /
  decline-recorded); the parking lot is the only landing zone.
- **`skills/5-scout`** — research and disposition, two entry modes:
  evaluate a dropped-in artifact whole, or research a named problem
  against prior art. Every finding carries an evidence tag and a
  disk-verified cite; the gate tiers by the repo's own bars; every
  decline and adopt-candidate survives a default-REFUTED challenge
  before delivery. Findings land on the map, never directly on the
  route.
- **`skills/6-reroute`** — the route's only rebuilder, owner-gated: one
  plan (backlog → milestones, unstarted-milestone adjustments, verbatim
  rotation of closed history to the archive), applied only on approval.
  In-flight milestones untouchable; archives append-only.
- **`templates/`** — the kit itself: `CLAUDE.md` (posture + invariants +
  working rules + owner doctrine), `ROADMAP.md`, `DECISIONS.md`,
  `LATER.md`, spec + handoff + archive templates, four check scripts,
  and a `.claude/settings.json` config (hooks + cloud-marketplace keys).

## Field glossary — the core information objects

| Object | File | What it holds · when it's used |
|---|---|---|
| The charter | `CLAUDE.md` | Posture, code invariants, working rules, owner doctrine. Auto-loaded every session; changed only by owner ruling. |
| Destinations | `ROADMAP.md` §Goals | What the journey is toward — the measuring sticks. Set at chartering; read by 1-continue, 4-scrutinize, 6-reroute. |
| The current leg | `ROADMAP.md` §Now | The one milestone in flight + its active itinerary. Read first every session; advanced only by 1-continue's close or a reroute. |
| Waypoints | `ROADMAP.md` §Milestones | Committed legs; closed ones compress to pointer lines. Entered only via 6-reroute or a 1-continue boundary pick. |
| No-go zones | `ROADMAP.md` §Non-goals | Out-of-scope as recorded state, each with a "closed until". Checked before scope-adjacent builds. |
| The captain's log | `ROADMAP.md` §Amendment log | Dated entries, one fact per physical line (a multi-fact event = several entries); last five live, rest rotate. |
| Old logbooks | `docs/roadmap-archive.md` + `docs/decisions-archive.md` | Verbatim rotated history, append-only, stamped. Written only by 6-reroute (or a build under an approved spec, stamped as such). |
| Itineraries | `specs/NN-*.md` | One leg's full plan + agent brief. No itinerary, no travel. |
| Trip reports | spec §Result | What actually happened: verbatim evidence, as-built deltas, friction. Appended at close. |
| Map margins | `LATER.md` | Ideas parked free as labeled-field blocks (Idea slug = citation key) with origin + promote-trigger; also holds adopt-candidates awaiting the owner's pick. Anyone writes anytime; consumed by 6-reroute. |
| The forks log | `DECISIONS.md` | Every fork taken: choice, rejected paths, revisit-when, one-token Status. 3-map renders live triggers from here only; spent/fired/superseded/absorbed ADRs rotate to `docs/decisions-archive.md`. |
| Guardrails & gear check | `scripts/checks/` + hooks + baseline | Write-blocking fences, pack limits (ratchet: shrink never grow), deps cap, `selftest.sh` proving it all fires. Hooks on every write; gear check at chartering and re-sync. |
| Dispatches | from `templates/HANDOFF_PROMPT.md` | Self-contained orders for work crossing a session/repo boundary, with the record block the courier brings home. |

The plugin is the shipping container; **the repo files are the product.**
Invariants must be in context every session, so they live in the target repo's
own `CLAUDE.md` — written by the skill, not shipped as plugin context. Likewise
the checks are installed repo-local (`scripts/checks/` + `.claude/settings.json`),
so the repo stays self-governing for anyone who clones it without this plugin.

## The lifecycle — how work moves

**The route holds what is committed; the map holds everything else.**
Defined milestones and approved specs live on the route (`/2-route`
renders it). Ideas, parked rows, revisit triggers, declines, and open
obligations live on the map (`/3-map`). Nothing crosses from map to
route except through a `/6-reroute` recut or an `/1-continue` boundary
pick — that gate is what keeps the route meaning "committed" instead
of "wished for".

**Three things look like bugs; only one is.**

| What surfaced | It is | What happens |
|---|---|---|
| A done-when item of the current milestone isn't met | remaining work | keep building; `/1-continue` does it |
| Something recorded as done or promised isn't true | **a defect** | repair lane: the owner's word, then patch + Result amendment |
| Work needs a decision the spec doesn't record | a gate | stop and deliver the choice; never build the deviation |

**Everything else discovered mid-build goes to the map** — the parking
lot — whether the agent found it or the owner asked for it. That rule
is what stops a milestone from absorbing every good idea that arrives
while it runs.

**Boundaries are where the map consolidates into the route.** When a
milestone closes, the close ritual offers a recut before the next one
opens; the owner accepts or declines in a word. Accepting runs
`/6-reroute`, which surveys the whole map, proposes one plan, and
writes nothing until approved.

**Records are append-only and forward-only.** Rotation moves history
verbatim to an archive; conventions apply to new records, never
retroactively; a correction is a new entry citing the old one, never
an edit of it.

## Install

From a local checkout, add this directory as a marketplace source and install
`repo-governance` via the `/plugin` command in Claude Code (see the plugins
documentation at https://code.claude.com/docs for current install syntax).
Layout rule if you modify it: **only `plugin.json` lives in `.claude-plugin/`**;
all component directories stay at plugin root. Misplacing them fails silently.
SKILL.md edits apply immediately; hook/manifest edits need `/reload-plugins`.

## Hook mechanics

- `check-source-writes.sh` — PreToolUse on `Write|Edit|MultiEdit` (`--hook`);
  exit 2 blocks the write and feeds the reason back to the agent. Repo-relative
  and absolute (outside-the-repo) protected lists, Windows-normalized
  (backslashes, case, MSYS drive forms). Guards tool writes only — Bash can
  still write, so protected dirs should also get filesystem-level protection
  where possible.
- `check-file-length.sh` — PostToolUse (`--hook`), `--scan` (batched: two greps
  → one wc → one awk; gates/CI), `--write-baseline` (adoption-time only —
  refuses once a baseline exists), and `--tighten` (close-out ratchet
  maintenance: never raises, drops under-cap rows, `seam`-tagged rows keep
  ~10% headroom over current size).
- `check-deps.sh` — scan mode only; run in gates/CI or at review.
  `MANIFEST_ORDER` is repo config.
- `selftest.sh` — proof harness run at adoption and re-sync, never a recurring
  gate: drives the real hooks with simulated stdin and replays the
  settings.json command lines (catches script/settings drift).

Scripts probe `jq → node → python3 → python → py` and take the first
NON-EMPTY answer (a `command -v` hit is not enough: the Microsoft Store
python3 shim exists on PATH but emits nothing); with no working extractor
they fail open with a loud stderr warning. Instantiated scripts split into a
repo-config region (survives re-sync) and a kit-code region stamped
`KIT_VERSION=` (replaced wholesale on re-sync).

## Deliberately absent / deferred

Building tooling for procedures never yet run manually is the
over-engineering the kit exists to prevent. The list's one long-time
entry graduated: the `disposition-pass` deferral (ADR-010) held until
the procedure had run manually — twice (ADR-014, ADR-017) — and
shipped as `5-scout` in 0.12.0. Currently deferred: `init-ship`
(spec 10, approved-unbuilt, built on its own pick).

## History

- 0.13.0 — the ritual and its conventions hold (spec 17, M7). The close
  ritual now sweeps consumed non-goal rows, runs the ratchet's tighten
  mode, compares a context baseline, and records friction; it offers a
  recut at every milestone boundary. New artifacts: a friction log
  (cross-session gotchas with recurrence counts) and a context budget,
  both offered at adoption and installed by Phase C. Record artifacts
  became seam files (ADR-019) so governance records can grow while the
  ratchet still trails them. Three record conventions (ADR-020):
  citation by date + quoted phrase with entry-anchored move-not-copy
  proofs, capability-as-unit for the promotion bar, one fact per dated
  log line. README gains the lifecycle section. Review: 33 agents, 15
  confirmed applied, 15 refuted.

- 0.12.0 — /5-scout ships (spec 16, M6; owner-approved plan after an
  evidence pass on the challenge tier). The intake procedure's three
  manual runs codified as one skill, two entry modes (drop-in
  disposition / research): five-field handoff records (evidence tag +
  disk-verified cite per finding), gate by the repo's own bars, and
  the ruling that made the verification OUTCOME mandatory with the
  mechanism free — every decline and adopt-candidate survives a
  default-REFUTED challenge (refuter fan-out where the harness has
  subagents, inline at reduced depth otherwise; stats recorded per
  run). Four-part write-set: run doc, decline ADRs, lot rows
  (awaiting-pick class), one amendment line. Correction folded in:
  0.11.0's History line said both review docs were refuter-verified —
  the intake review was; the format scrutiny was gate-verified.
- 0.11.0 — records hold their shape (spec 15, owner plan-B pick after
  the intake-pipeline review [refuter-verified] + artifact-format
  scrutiny [gate-verified]). The decision log gets its valve: one-token ADR
  Status line (live | standing | spent | fired | superseded |
  absorbed), rotation to docs/decisions-archive.md under the ADR-015
  conventions (/6-reroute sole mover), near-cap flag widened to the
  decision log at 90%. Grep-contract registry
  (scripts/checks/grep-contracts.tsv) + selftest T12 make the
  twice-bitten wrap-split class check-mechanical — T12's first run
  caught a live split in init-cartography. Spec State line, amendment
  one-fact-per-entry rule, LATER.md as labeled-field blocks with the
  adopt-candidate class (/4-scrutinize gains the fourth write). ADR-014
  D4 repair. Spec 16 (/5-scout) authored for the owner's gate.
- 0.10.0 — the settled names (spec 14, owner ruling): init-cartography
  (was govern-repo), 1-continue (was advance), 2-route, 3-map,
  4-scrutinize, 6-reroute (was recut), with init-ship (was make-ship)
  and 5-scout (was prior-art) reserved for their builds. Numbers = rough
  usage sequence; init- = one-time setup. README gains the field
  glossary. Records keep old names verbatim; ADR-016 holds the mapping.
- 0.9.0 — the navigation suite (spec 13, owner-approved plan). /map
  becomes /route (the roadmap as the owner's dependency-ordered action
  queue, + near-cap flag); a new broadened /map renders the territory
  (backlog census across parking lot + ADR revisit triggers +
  spec-embedded obligations, non-goals, declines, archive pointer); new
  /recut is the route's only rebuilder (owner-gated plan → verbatim
  rotation to docs/roadmap-archive.md, backlog→milestones, map hygiene).
  Doctrine encoded: the map is free, the route is gated; repair lane for
  defects. /advance close ritual gains export-on-close (a spec never
  closes holding OPEN items) and census-fed boundary candidates. `md`
  joined this repo's length-check config (governance records now under
  the mechanical 300 cap). Census evidence: 80%-history roadmap,
  two-thirds single-homed backlog, Done-er's 4-6-file "what next".
- 0.8.0 — one train, two specs. Spec 11 (cbtdag adoptions + owner
  doctrine): semantic-conventions section in the spec template + Phase B
  extraction line (implicit conventions are per-builder coin flips);
  `templates/HANDOFF_PROMPT.md` (the self-contained handoff shape,
  reverse-engineered from five live instances including red-team fixes);
  owner doctrine into templates/CLAUDE.md — task-DAG action queues not
  calendar time, AI cognitive ergonomics over polish for absent readers,
  sexpr over JSON where the format is ours to choose (platform formats
  exempt). M4 (spec 12, friction-cut from the M3 field eval): six fixes
  each traced to a recorded item — absent-tooling skip rule, lightest
  approval facility, one-topic batched questions with option-cap
  semantics, uniform-table plan-level approval, Windows exec-bit index
  fix, and selftest T11 (leftover-placeholder check, proven
  green/red-on-probe/green). DAG machinery from the cbtdag drop-in
  declined (ADR-014).
- 0.7.3 — /map ship flag (owner-requested): in a repo whose records name
  a delivery step, the map ends with `⇪ ship needed — <why>` when payload
  paths are dirty or carry commits newer than the last recorded version
  change — derived from records and git alone, never by reading delivery
  targets outside the repo root. Verification: both states demonstrated
  live (flag fired pre-ship on the dirty payload; clean map post-ship).
- 0.7.2 — /map hardened after its adversarial review (the pass spec 09's
  Result had queued): four confirmed wording gaps closed — named-but-
  absent mapped homes flag ⚠ like unnamed ones; the header's version
  segment gets a source and an omit-when-unrecorded fallback; a side
  spec in recorded build legally renders a second ●; ✅'s "logged" names
  its object (the amendment). Review: 3 adversarial lenses, 22 findings,
  each independently verified — 4 confirmed, 18 refuted (all four
  MUST_FIX claims among them).
- 0.7.1 — /advance step 1 names the behind-origin/diverged-branch gate
  (owner decides syncing; never pull unprompted). Rationale: the
  2026-08-19 Done-er live test hit the state and had to extrapolate;
  adopted via the first /scrutinize run (docs/scrutiny-2026-08-19).
  Verification: the live run itself exercised the state; the sentence
  codifies its correct handling.
- 0.7.0 — the governed-repo interface (spec 07, convergence approach B).
  Four functions stated by one name in govern-repo (authoring side),
  /advance and /map (consuming side), with a required mapping-table stub
  in the DECISIONS template: current-milestone pointer, gated spec
  pipeline, close-out record, amendment log; a keep-sovereign mapping
  leaving one unnamed is an adoption defect. Spec template back-ports
  Done-er's stronger practices (Current-state-at-HEAD section, as-built
  deltas in Result). Named failure: /advance could not run in Done-er —
  its ADR-001 mapping lacks two of the four rows.
- 0.6.1 — govern-repo's Re-sync path now ensures the cloud-marketplace
  keys too. Rationale: 0.6.0 wired the keys into fresh adoptions only;
  the owner's first planned use was a re-sync (Done-er — the repo the
  cloud failure happened in), which would have missed them. Caught by the
  owner's use question the same day.
- 0.6.0 — `/map` skill + cloud-at-adoption. `/map`: read-only at-a-glance
  status tree (glyph statuses, YOU/me-tagged open items, recommended
  order, sequencing note; contradictions flagged, never repaired).
  Rationale: prose status reports failed at multi-repo scale (owner
  running three repos, 2026-08-18); the view was produced manually once
  and immediately requested as a skill. Also spec 08's owner amendment:
  `templates/claude-settings.json` now carries the cloud-marketplace keys
  and govern-repo installs them as a Phase B default disposition, so
  freshly governed repos work in cloud sessions. (Delivery side, spec 08:
  /ship pushes the payload to the private claude-plugin-marketplace repo —
  dev-repo tooling, no payload change.)
- 0.5.1 — `/advance` hardened after its first live run + adversarial
  review. Rationale: three confirmed holes — undefined "current milestone"
  deadlocked on a seeded-but-unspecced roadmap state; spec authoring could
  self-approve into building; no owner-blocker outcome for gaps only the
  owner can clear. Now: shared in-flight definition with /scrutinize, four
  verdicts (Blocked added), spec drafts always stop for the owner's go,
  recorded decisions stay made, commit-only-ritual-writes semantics.
- 0.5.0 — `/scrutinize` skill: the owner's proven best-practices question,
  gated. Rationale: run raw, it improved real plans twice (BookKeep's
  milestone recut, Done-er's improvement survey) but needed the selection
  filter applied by hand afterward; the skill mechanizes the
  generator→gate→parking-lot pairing so precedent-shopping can't become
  scope creep.
- 0.4.0 — `/advance` skill: nudge a governed repo through its plan
  (verify done-when with evidence → close ritual → next build, gates
  preserved). Rationale: the transition ritual had been run manually twice
  (M1 and M2 closes) and its skipped-step failures were recorded — Result
  sections left unfilled, a stale "Now" block, every transition waiting on
  an owner prod.
- 0.3.1 — friction-cut hardening + governed-repo re-sync. Rationale: every
  change traces to friction from the three eval runs (spec 03) — a
  working-interpreter probe with first-non-empty semantics (the python3
  Store stub failed open silently), CR/path normalization with absolute
  protected paths, a batched scan (2+ min → sub-second under MSYS),
  `--tighten` ratchet maintenance with seam headroom (a write-baseline
  re-run could RAISE ceilings), a `selftest.sh` proof artifact (improvised
  proofs were twice wrong), an explicit `--hook` flag (tty-sniff dispatch
  silently no-ops in CI), and a repo-config/kit-code split stamped with
  `KIT_VERSION`, because templates and instantiated scripts had already
  diverged silently. Re-sync migration note: protected-path entries must be
  lowercase (matching is now case-folding).
- 0.3.0 — seed-repo and adopt-repo unified into govern-repo. Rationale: in
  practice no repo starts empty (notes and artifacts are dropped in first), so
  both cases reduce to survey → draft-from-evidence → confirm → apply. This
  also resolved the v0.1 seed interview-weight issue: questions are only asked
  for gaps the survey cannot fill, each with a drafted default.
- 0.2.0 — adopt-repo + ratchet baselines. 0.1.0 — seed-repo.

## Version

0.13.0 — init-cartography + 1-continue + 2-route + 3-map +
4-scrutinize + 5-scout + 6-reroute (init-ship reserved), the
governed-repo interface, owner doctrine, field glossary, record-shape
conventions (ADR Status + rotation, spec State, labeled-field lot,
grep-contract registry + T12, seam ceilings, citation and capability
rules), a friction log and context budget, hardened checks,
cloud-ready adoptions and re-syncs.
