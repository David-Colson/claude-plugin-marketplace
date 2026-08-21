# Later

Good ideas that aren't now. Parking an idea here is cheap and prevents it
from feeling urgent. Mid-build discoveries land here instead of in code.
The lot also holds **adopt-candidates**: items that cleared the repo's
promotion bar and await the owner's boundary pick — tagged as such in
their Trigger field, cleared on pick or recorded decline.

Promotion to the roadmap happens at milestone boundaries only, and the bar
for jumping the queue is narrow: it's a one-way door current work is about
to walk through, or it invalidates a decision already being built on.
"Exciting" and "small" do not qualify.

Entry shape — labeled-field blocks, one field per physical line,
blank-line separated; the kebab-case `Idea:` slug is the stable citation
key (cite slugs, never line numbers):

Idea: {{KEBAB_SLUG}}
Logged: {{DATE}}
Origin: {{SESSION_OR_SPEC}}
Trigger: {{PROMOTE_WHEN — or "owner's boundary pick (adopt-candidate)"}}
Notes: {{FREE_TEXT — may span lines; next block starts after a blank line}}
