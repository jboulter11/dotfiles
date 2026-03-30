- Don't make changes to module_weight in bazel files, they are set automatically.
- Never amend commits. Always create new commits for additional changes.
- Never commit to a `pl` branch (e.g., `pl`, `pl2`, `pl-example-text`). Always branch off before committing.
- Flat branch names only. No prefixes like `jboulter/`. Use `example-branch`, not `jboulter/example-branch`.
- Always prefer separate tool calls over chaining commands with `&&`, `;`, or `echo "---"`. Run each command as its own Bash call.
- Always prefer built-in tools (Read, Edit, Write, Glob, Grep) over equivalent Bash commands (cat, sed, find, grep, etc.).
- Never include `# comments` or unnecessary newlines in Bash commands you are running.  Comments in scripts you're writing are okay.
- When starting work on any task, immediately:
  1. Create and check out a descriptive branch name (flat, no prefixes).
  2. Rename the cmux workspace with `cmux rename-workspace "NAME"` (max 30 chars). If working on a ticket, prefix with the ticket ID, e.g. `[A1] Fix login flow` or `[DASH-456] Add retry`.
- When a PR is pushed, update the workspace name to include the PR number after any ticket prefix, e.g. `[A1] #12345 Fix login` or `#12345 Fix login flow`.
