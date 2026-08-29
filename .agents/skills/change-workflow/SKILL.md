---
name: change-workflow
description: Use when a task changes code and should be delegated through the code-explorer, implementer, test-generator, and code-reviewer subagents with a review-fix loop and explicit exit criteria.
---

# Change Workflow

The main conversation coordinates the subagents in sequence, reads each result, and reports. Roles, tools, and
output formats are in `.agents/agents.md`.

## Steps

1. `code-explorer` with the task statement. Run several in parallel when the task spans independent areas and
   synthesize the maps. Ask the user only when an open question changes the implementation.
2. `implementer` with the task and the explorer's map verbatim.
3. `test-generator` when the implementer's report shows changed behavior without tests for its edge or failure
   paths.
4. `code-reviewer` with the base ref (default: merge-base with `main`) and the implementer's report.
5. On Critical or High findings: `implementer` with only those findings, then `code-reviewer` asked to re-check
   exactly those. Stop after two rounds and report what remains to the user.
6. Before a merge or release, run `/code-review` as the independent second opinion.

## Exit Criteria

- `flutter analyze --no-fatal-infos` is clean and the focused tests the explorer named pass.
- No Critical or High finding is open; open Medium findings are listed in the final report.
- The final report names the files changed, the commands run, the review summary, and the platforms or checks the
  review could not exercise.

## Scale Down

A one-line change in a file the main conversation already understands may skip step 1. Never skip step 4 for
changes under `lib/core/`, `lib/manager/`, `core/`, `services/helper/`, Android, or any provider that owns
lifecycle state.
