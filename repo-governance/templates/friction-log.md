# Friction log — {{PROJECT_NAME}}

<!-- Cross-session workflow gotchas: the things that were slow, wrong, or
     surprising, and the recipes that fixed them. Read at the start of a
     run, maintained by the close ritual. NOT the parking lot (ideas) and
     NOT a spec Result (per-milestone record) — this file exists because
     a gotcha recurs across runs and nothing else counts recurrences.
     Read at run start by the close-ritual skill; written, incremented,
     and pruned by that skill's close branch. -->

Entry shape: one BLOCK per pattern — three labeled lines, blank-line
separated. One pattern per block; a recurrence adds a date, never a
second block.

Pattern: {{ONE_LINE — what bit, and the fix if one is known}}
Seen: {{YYYY-MM-DD}}[, {{YYYY-MM-DD}} ...]   <!-- a repeat adds a date -->
Candidate: {{nothing yet | doc line | extend <skill> | park to LATER}}

Rules the close ritual applies:
- A pattern already listed and seen again gets today's date appended —
  recurrence is the evidence a fix is worth building.
- A pattern whose fix has shipped is deleted; the shipping record is its
  archive.
- A pattern seen once and not again in a long while is pruned.
- Hard cap: keep this file short enough to read every run. When it grows
  past that, prune before adding.
