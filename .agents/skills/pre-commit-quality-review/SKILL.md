---
name: pre-commit-quality-review
description: Use when the user asks to commit, amend, or squash code, or requests a pre-commit structural quality review.
---

# Pre-commit Quality Review

Check that iterative edits converged into a clear, cohesive, maintainable implementation before they become a commit,
so later code review is not spent on basic structure. `AGENTS.md` and `.agents/rules.md` apply throughout. This skill
grants no authority: commit, push, and history rewrites stay under the user's existing authorization, and silence is
not consent.

## Triage

Most commits stop here. Decide from the change summary, the diff, and the local context it needs; never start with a
repository-wide scan.

- **Skip** formatting, mechanical renames, generated output, copy changes, and simple local fixes. They go through the
  normal commit flow without extra confirmation. Say the review was skipped, never that it passed.
- **Review** when a core implementation is replaced; when responsibilities, dependency direction, or public abstractions
  change materially; when accumulated patches added branches, duplicate paths, or indirection; or when new code draws
  responsibility boundaries. A small change can move a critical responsibility, so line count is not a trigger.
- An explicit structural review request bypasses triage.

The snapshot under review is the intended commit compared with its baseline:

| Operation | Baseline |
|---|---|
| Regular commit | `HEAD` |
| Amend | Parent of the commit being replaced |
| Squash | Version preceding the agreed range |
| Initial commit | Empty tree |

Ask when the range or parent is materially ambiguous instead of assuming the whole branch. Read staged versions of
partially staged files; an unstaged fix is not part of the pending commit. Preserve unrelated changes and partial
staging.

## Review the Final Structure

Scope the review to the responsibility boundaries this change touched. Read the complete final implementation of the
affected units and compare before and after, not only the last patch. Report issues this change introduced or
worsened; untouched historical debt is not a pre-commit requirement. Follow a call or dependency path only as far as a
concrete concern needs, and disclose missing essential context rather than claiming a complete pass.

Focus on:

- **Responsibilities and cohesion:** units mixing responsibilities that change independently; orchestration tangled
  with implementation detail; responsibilities in layers that should not own them.
- **Dependencies and abstractions:** reversed or circular dependencies, forwarding layers, abstractions that isolate
  nothing; similar names or interfaces hiding different responsibilities.
- **Complexity and readability:** nested conditions, repeated fallbacks, boolean parameter combinations, mutually
  dependent helpers; names and decomposition that do not reduce reading effort.
- **Duplication and consistency:** reimplemented existing capabilities, parallel implementations or duplicate state,
  scattered ownership of error handling, cleanup, or state updates.
- **Remnants:** obsolete branches, compatibility layers, unused parameters, commented-out code, comments the rewrite
  invalidated; coupling that makes existing test boundaries hard to use.

Not findings: length, a missing design pattern, naming taste, or anything without code evidence and a real
maintenance cost. Do not add cross-layer coupling to remove a few similar lines, rewrite stable code for uniformity,
or demand abstractions for speculative needs.

Business logic, UI behavior, performance, security, platform compatibility, and full functional review are out of
scope. Report an incidentally found serious defect separately through the normal defect workflow, without hiding it or
widening this review.

## Findings and the User's Decision

A finding qualifies only when all three hold:

- Before-and-after code and the necessary call relationships show this change introduced or worsened it.
- The maintenance cost is concrete, such as updating one rule in two places or touching unrelated layers for one
  responsibility. Clarity or elegance alone is not enough.
- A minimal proposal fits existing constraints, with a benefit not offset by new coupling, indirection, or scope.

With no qualifying finding, state the reviewed scope and conclusion in a sentence or two and continue under the
existing commit authorization. Do not ask for confirmation because a review happened, and do not collect optional
improvements into a suggestion list.

With qualifying findings, finish the read-only review and independent checks first, merge findings that share a cause,
and give for each: file, symbol, and location with how this change introduced it; the concrete maintenance cost; the
smallest proposal with its scope and any behavioral impact. Then **pause before creating the commit and ask whether to
optimize first; do not edit or commit until the user answers.** Attribute the pause to this skill by file path so the
user recognizes their configured workflow, for example: "The structural issues above support consolidating the
duplicate state-update paths. Should I make that change before committing?"

Existing explicit authorization for these findings is enough to act without asking again. The user may accept all,
some, or none. Keep accepted findings and tradeoffs in the task context only, and do not re-ask because files were
restaged, a hash changed, or unrelated edits landed; reassess only when relevant code changes invalidate the tradeoff.

## Resolve and Finish

Once authorized, make the smallest adjustments that resolve the accepted findings while preserving behavior and task
scope; explain separately if either must change. Verify only the accepted findings and the direct effects of the
adjustments, without another search for improvements. Raise a new finding only with evidence that meets the threshold
and exceeds the existing authorization.

Before committing, recheck status and the actual staged diff so the pending snapshot matches what was reviewed, and
review only the delta of later edits. Run the checks `AGENTS.md` requires for the change: `flutter pub get`,
`flutter analyze --no-fatal-infos`, and the covering `flutter test` suites listed in `.agents/commands.md`. Reuse
results that are still valid, rerun those a later edit invalidated, and never present results from an earlier snapshot
as verification of the staged one. The `comment-density` and `commit-msg` hooks in `.agents/rules.md` still gate the
commit.

Report the reviewed scope, completed improvements or accepted tradeoffs, check results, and any verification limits.
Claim the commit is done only after it exists.
