- Be extremely concise.  Sacrifice grammar for the sake of concision when writing responses, code comments, pr descriptions, etc. 
- Never amend commits. Always create new commits for additional changes.
- Never commit to a `pl` branch (e.g., `pl`, `pl2`, `pl-example-text`). Always branch off of latest main/master (primary branch) before committing.
- Flat branch names only. No prefixes like `jboulter/`. Use `example-branch`, not `jboulter/example-branch`.
- When starting work on any task, immediately create and check out a descriptive branch name (flat, no prefixes).
- When rebasing a stack of branches (multiple branches stacked on each other), always use `git rebase --update-refs` from the tip of the stack (the topmost branch). This rebases every branch in the chain in one pass, automatically updating intermediate branch refs along the way — including any middle-of-the-stack branches whose tips fall on commits inside the rebase range. Running it from a middle branch only updates refs up to that branch and leaves higher branches untouched, so always start from the tip.
- Keep individual PRs small: when a PR would exceed 1000 lines added (as GitHub reports it), proactively break it into a stack of smaller PRs — without asking. Split along logical boundaries (self-contained, coherent units of change), never mechanically by file. Every PR in a stack must leave main functional on its own, since each lands separately — it must build, pass tests, and not crash or spurriously log errors at runtime. A slice doesn't have to be independently useful or fully wired up (inert, unreached code is fine), but it can't break anything. Plan the split up front when the work is obviously going to be large; reacting after the fact is fine when something grows unexpectedly. This applies to all PRs, drafts included. When there's no clean logical seam to split on (e.g. large generated code), stop and flag it to me so we can figure out the split together — never take an automatic exemption. I can override this on a per-PR basis, but unless I explicitly say so, always default to breaking up PRs into stacks without asking.
- Background agents do not need to be waited on manually — they notify you when they finish. Never sleep and then poll to check whether a background agent is done; just continue with other work and react when the completion notification arrives.
- When working on Jira tickets, manage their status:
  - Move to "In Progress" when work starts on the ticket.
  - Move to "In Review" when the PR comes out of draft.
  - Move to "Done" when the PR with that task's work lands.
  - Handle subtasks similarly if needed (transition them through the same statuses).
- "landed" means merged into the primary branch (main/master). "shipped"/"released" means deployed to production/users. Neither is a generic word for what code does — use "add"/"introduce" for that.
- When writing pr descriptions focus on the what and why for the change.  What is changing and why is it changing in as few words as possible.  The size of the PR description should be commensurate with the size and importance of the change.  If you're not sure why a change is being made, ask.
- When writing pr descriptions, include mermaid diagrams when helpful for showing object relations or data flow.
- AI attribution markers (e.g. `[Claude Opus 5.5 🤖]`) are only for messages to humans (Slack, comments, emails). Don't add them to documents we co-edit and I review (Confluence pages, doc version messages, etc.).
- For stacked PRs, include links to each PR in the stack and an indication of where this one is in the stack with PR numbers at the bottom of the PR description, like so:
```
## Stack
- #12345
- #12346 <<< This PR
- #12347
```

