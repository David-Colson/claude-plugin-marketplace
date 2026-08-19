# Handoff prompt template

<!-- The shape for work handed to another session, repo, or environment.
     Fill the placeholders, then paste the block below VERBATIM into the
     executing session. The executor must need NOTHING beyond this text —
     if it has to discover something to proceed, either add it to Context
     or (eval-integrity variant) omit it DELIBERATELY and say so, because
     the run is measuring discovery itself.
     Record-block rules: every field must be fillable on both the success
     and the stopped path; no outcome-pressure inside placeholders (the
     pass criterion belongs to the requester, not the record template —
     ask for "final line verbatim", never "must say X"). -->

---

Owner instruction — {{TASK_TITLE}}. {{ONE_LINE_INTENT}}.
Scope: {{VERIFICATION_ONLY_OR_BUILD}}. Write nothing beyond
{{ALLOWED_WRITES}}; commit nothing beyond {{ALLOWED_COMMITS}}; never push
without my word.

Context — everything you may rely on; nothing here needs re-discovery:
- {{FACT_OR_PATH_1}}
- {{FACT_OR_PATH_2}}

Constraints and refusals:
- {{CONSTRAINT_1}}
- Improvise only the minimum needed to keep moving, and record every such
  moment; anything that needs a decision not listed here → stop and
  report it as the gate.

When the work completes (or stops), print exactly:

=== Record for {{ORIGIN_REPO}} — {{SPEC_OR_TASK_REF}} ===
{{FIELD_1}}:   <{{WHAT_TO_CAPTURE_VERBATIM}}>
{{FIELD_2}}:   <{{FILLABLE_ON_STOP_TOO}}>
Friction:      <one line per moment that was slow, wrong, surprising, or
                forced improvisation — or explicitly "none observed">
=== end record ===
