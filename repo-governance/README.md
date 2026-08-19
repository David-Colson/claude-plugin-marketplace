# repo-governance

A Claude Code plugin that sets up or retrofits governance on agent-built repos — any starting state.

The kit constrains **invariants, boundaries, done-conditions, and production
posture — never implementation.** The agent owns the "how"; the human owns the
"what" and "whether". Three layers of constraint, ordered by how well they
survive: mechanical checks (work when nobody is paying attention), spec
done-conditions (work within a session), prose invariants (work when the agent
is attentive).

## What's in it

- **`skills/govern-repo`** — one procedure for any repo state (empty,
  artifacts-only, or legacy codebase): Survey (read-only; dropped notes and
  docs are evidence, tagged stated-vs-inferred with `file:line`) → Draft &
  Confirm (every decision arrives drafted with evidence; plan-style approval
  gate; the human confirms and picks, never authors essays) → Apply
  (merge-never-clobber, ratchet baselines for legacy code, prove checks fire,
  governance ADR). No feature code in the governance session, by rule.
- **`skills/advance`** — the transition ritual, mechanized: verify the
  current milestone's done-conditions with evidence, run the close ritual
  when met (Result section, amendment log, "Now" block), then initiate the
  next milestone's build — stopping AT every owner gate (approach choice,
  spec approval, milestone pick), never through it. Works on kit-style and
  case-law repos alike.
- **`skills/scrutinize`** — the future-proofing question ("industry-standard
  best practices that would improve this setup?") run with guardrails:
  every candidate needs a named precedent AND a local evidence tag, output
  is tiered by the repo's own selection filter (adopt / park / decline-
  recorded), and the parking lot is the only landing zone — never specs or
  code. For roadmap authoring, next-milestone choice, and one-way doors.
- **`skills/map`** — the at-a-glance status tree, read-only: closed
  milestones collapsed, the active one marked, open action items tabbed
  under what they block and tagged owner-vs-agent, pending specs in
  recommended order, sequencing note. Maps recorded state only — never
  verifies, writes, or advances; contradictions between records render as
  flagged lines. One repo per map, by rule.
- **`templates/`** — the kit itself: `CLAUDE.md` (posture + invariants + working
  rules), `ROADMAP.md` (capability milestones, non-goals with until-when),
  `DECISIONS.md`, `LATER.md`, a spec template, three check scripts, and a
  `.claude/settings.json` config (hooks + cloud-marketplace keys so cloud
  sessions in governed repos load this plugin).

The plugin is the shipping container; **the repo files are the product.**
Invariants must be in context every session, so they live in the target repo's
own `CLAUDE.md` — written by the skill, not shipped as plugin context. Likewise
the checks are installed repo-local (`scripts/checks/` + `.claude/settings.json`),
so the repo stays self-governing for anyone who clones it without this plugin.

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

- **`disposition-pass`** (post-brainstorm sorting into ADR / invariant /
  roadmap / non-goal / LATER / discard; milestone-boundary gate; posture-change
  escalation) — added after the procedure has been run manually once. Building
  tooling for procedures never yet run manually is the same over-engineering
  the kit exists to prevent.

## History

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

0.7.2 — govern-repo + advance + scrutinize + map, the governed-repo
interface, hardened checks, cloud-ready adoptions and re-syncs.
