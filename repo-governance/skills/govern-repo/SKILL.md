---
name: govern-repo
description: Set up or retrofit governance on any repository — empty, seeded with dropped notes/artifacts, or a full legacy codebase. Surveys whatever exists (dropped .md files, docs, code, git history), drafts every governance decision from that evidence, walks the user through confirmations plan-style, and only then applies the kit. Use this whenever the user says "seed this repo", "adopt this repo", "set up governance", "govern this repo", "bring this repo under management", "review the files I dropped in and set up the project", "initialize project structure", or starts any repo an agent will build in — even without the word "governance".
---

# Govern Repo

One procedure for any repo state. Survey what exists, draft every governance
decision from evidence, confirm plan-style, then apply. **The human confirms
and chooses; they never author essays.** The kit constrains invariants,
boundaries, done-conditions, and posture — never implementation.

Dropped artifacts (notes, requirement docs, sketches, sample data) are
**evidence, not decisions**: extract from them, cite them, and tag every
extracted item as `stated (file:line)` or `inferred — confirm`. A sentence in a
brainstorm dump does not become an invariant without confirmation.

## Hard rules

- **Read-only until Phase C approval.** Phases A and B write nothing in the repo.
- **`git status` first** when history exists; uncommitted substantive changes
  are surfaced and the human decides commit/stash before anything else.
- **Test baseline before any change** (when a suite exists). Recorded verbatim.
  A red baseline is recorded, not fixed — fixing is a milestone.
- **Verification precedes authoring.** No new doc asserts a fact not verified
  open-file this session, with `file:line` evidence.
- **No feature code. No refactoring.** Such requests go to `LATER.md`.
- **Merge, never clobber.** No existing file is deleted or emptied without an
  explicitly approved disposition.
- **Timebox.** If the session runs long, apply the approved plan in priority
  order — checks + `CLAUDE.md`, then doc reconciliation, then roadmap — and
  stop, recording what remains.

## Phase A — Survey (read-only)

Scaled to what exists; skip what's absent.

1. `git status` + recent log (if history) — surface uncommitted work.
2. **Artifact inventory:** every dropped .md / doc / note / diagram / sample
   file. Extract stated goals, constraints, decisions, risky assumptions, and
   data-protection needs — each tagged `stated (file:line)` or `inferred`.
3. **Code inventory** (if code): stack, manifests, direct dep count, largest
   source files + any over the target cap, entry points, CI config.
4. Test suite (if present): run, record N passed / N failed verbatim.
5. Data & secrets: source-data/original dirs; `.env` and committed secrets —
   **flag to the human; never edit or rotate them yourself.**
6. Drift check (if existing docs make claims): claim vs. open-file reality,
   with evidence.

## Phase B — Draft & Confirm (plan style, still read-only)

Assemble one governance plan. Every item arrives **drafted**, with its evidence
or an explicit default — the only questions asked are the gaps the survey
genuinely could not fill, one at a time, each with a proposed default.

**Selection filter:** draft an item only where incidents already cluster or
where it protects the repo's ability to absorb the next feature — never a
priori. Governance that gets in the way of development is a defect.

1. **Posture** — drafted from artifacts/code; confirm or edit.
2. **Protected paths** — candidates found; confirm.
3. **Invariant config** — `MAX_LINES`, layer direction, `MAX_DEPS` (current
   count when legacy code exists; template default otherwise); confirm.
4. **Ratchet plan** (legacy code only) — files to baseline, names + counts.
   One drafted question: "Which files grow with every feature by design
   (routes, schema, registries)? Drafted: <list from the survey>. These get
   seam headroom (~10%, maintained by `--tighten`) so the first feature
   commit after adoption doesn't trip the ratchet. Confirm or edit."
5. **Reconciliation table** (existing docs and the dropped artifacts) — every
   file → keep / fold into X / move to `docs/intake/` / supersede / delete.
   One recommendation per row; the human decides each. Dropped notes get a row:
   once absorbed, they must not linger as a second source of truth.
6. **Roadmap** — "Now" block from actual current state; M1 as a **walking
   skeleton** for new builds, or a capability recut of existing plans (flag
   component-shaped milestones); an M0.5 spike if a risky assumption surfaced;
   non-goals with until-when; `LATER.md` candidates.
7. **ADR seeds** — decisions stated in artifacts or evident in code but never
   recorded.
8. **Cloud plugin access** — drafted default: install the kit's
   cloud-marketplace keys (`extraKnownMarketplaces` + `enabledPlugins`,
   spec 08) so cloud sessions opened in this repo load the plugin; the
   owner may strike it.

Present it as a plan for approval: if a plan-mode/approval facility is
available in the environment, use it for the gate; otherwise present the plan
in-conversation and wait for explicit approval. Where genuine forks exist,
offer 2–3 options with trade-offs and a recommendation. **STOP until approved.**
If approval is declined, the plan itself is the deliverable — write nothing.

## Phase C — Apply (only after approval)

1. Instantiate/merge kit files per the approved plan, from
   `${CLAUDE_PLUGIN_ROOT}/templates/`: `CLAUDE.md` (merge if present),
   `ROADMAP.md`, `DECISIONS.md`, `LATER.md` (seeded from Phase B), `specs/` +
   template. For new builds, author `specs/01-<skeleton-capability>.md` now.
   Execute every reconciliation disposition exactly as approved.
2. Install `scripts/checks/` with the approved config (config region above
   the marker; kit code below it verbatim, stamped with the installed plugin
   version); `chmod +x`. Run `check-file-length.sh --write-baseline` when
   legacy code exists; for each approved seam file, tag its baseline row
   (third column `seam`) and raise its ceiling to `int(current * 1.1 + 0.5)`
   — an adoption-time hand edit; afterwards the baseline moves only via
   `--tighten`. Merge the hooks config — and, per the approved Phase B
   disposition, the cloud-marketplace keys — into `.claude/settings.json`
   (commands pass `--hook`), preserving every existing entry. Append-merge into
   `.gitattributes` (autocrlf corrupts the scripts and the tab-keyed
   baseline on a fresh checkout):
   `scripts/checks/*.sh text eol=lf` and
   `scripts/checks/length-baseline.txt text eol=lf`.
3. **Prove enforcement fires:** run `bash scripts/checks/selftest.sh` and
   show its output verbatim — it must end `SELFTEST GREEN`. Do not improvise
   probes: ad-hoc proofs have twice been wrong themselves (echo-mangled JSON
   produced a false negative; inline traces through the tool's escaping
   layer lied). If anything still needs manual tracing, trace the script on
   disk, never an inline copy. A selftest that fails or cannot run is a
   finding to report, not a step to skip.
4. Write ADR-001 (or ADR-00N for an existing decision log): posture, protected
   paths, invariant config, baselines and targets, test baseline, every
   disposition executed, and the artifact provenance of each decision.
5. Commit governance changes isolated from any pre-existing work; message
   references the ADR.
6. Handoff: the "Now" block names a real capability milestone; list what was
   created, absorbed, superseded, and deliberately not migrated; one next
   action — "open a build session against `specs/01-....md`".

**The governance session produces no feature code.** Building M1 is the next
session.

## Re-sync (already-governed repo, newer kit)

Preserve the `repo config` region of each installed check script; replace
the kit-code region wholesale from the installed plugin's templates (it
carries the kit version). Apply any config-migration notes from the release
history (e.g. lowercasing protected-path entries when normalization became
case-folding at v0.3.1). Update the hook command args in
`.claude/settings.json` in the same commit, and ensure the
cloud-marketplace keys (spec 08, shipped in
`templates/claude-settings.json`) are present there, merging them if
absent — re-synced repos get cloud sessions, not just fresh adoptions. Baseline files are data — never
regenerated (`--write-baseline` refuses when one exists). Prove with
`bash scripts/checks/selftest.sh`; record the kit version in the repo's
decision log; remind that running sessions keep old hooks until restart.

## Refusals

- Fixing tests, refactoring, or building features during governance → decline
  in-session; log to `LATER.md` or the first milestone.
- Writing any repo file before Phase B approval → never.
- Treating an unconfirmed inference from dropped artifacts as a decision → never.
