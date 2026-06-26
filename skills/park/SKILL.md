---
name: park
description: Clean up after finishing work. Parks the worktree, closes Jira tickets, and cleans up branches. Use -a to abandon (close open PRs and reset Jira tickets).
---

Clean up the current session's work. Run the `park` script with `-c` to park and clean the branch, transition Jira tickets, and delete any extra branches worked on.

## Arguments

- `-a` (abandon): Proceed even if PRs are not merged. Closes open/draft PRs and moves Jira tickets back to Open.

## Execution Order

1. **Identify session work**: Scan the conversation for branch names worked on and Jira ticket keys (from MF, IOSDBAPP, or ANDROIDDBAPP projects). Also check the PR body (`gh pr view <number> --json body`) for any ticket keys not found in conversation.
2. **Check PR states**: For each PR, run `gh pr view <number> --json state,number,title,isDraft,statusCheckRollup` to get the PR status. Always use the PR number (not the branch name) — `gh pr view <branch>` does not work reliably.
3. **Gate check**: If any PR is NOT merged and `-a` was NOT passed:
   - **If the `watch-pr-and-fix` skill is available (xplat repo)**: don't bail. Instead of checking merge state yourself, invoke `/watch-pr-and-fix` for each unmerged PR to watch its CQ build through to terminal state, fixing failures as they arise. Park only proceeds once the watcher reports the PR merged. If the watcher reports the build failed/canceled/errored and it can't land, report that and stop (re-run with `-a` to abandon instead).
   - **Otherwise**: stop immediately. Print each unmerged PR with its number, branch, state (open/draft), and check status. Tell the user to merge first or re-run with `-a` to abandon.
4. **Ensure tickets in PR body**: For each merged/open PR, check if the discovered Jira tickets are mentioned in the body. If any are missing, edit the PR body to add them (e.g. append to the Summary section). This keeps the paper trail intact even after context is lost.
5. **Jira transitions**:
   - If PRs are merged: Transition all mentioned Jira tickets to **Done** (transition ID `91`).
   - If abandoning (`-a`): Transition all mentioned Jira tickets to **Open** (transition ID `61`).
6. **Close PRs (abandon only)**: If `-a` was passed, close all open/draft PRs with `gh pr close <number>`.
7. **Update plan progress**: If a plan file was used this session (typically in `scratch/plans/`), mark completed tasks/subtasks with `[x]` in the progress tracking section.
8. **Park current branch**: Run `park -c` (outside the sandbox — it modifies git state and calls cmux). This parks the worktree, rebases the pl branch, cleans the working branch, and renames the cmux workspace.
9. **Delete extra branches**: For any other branches from this worktree that were worked on in the session, run `git branch -D <branch>` to clean them up.

## No PRs or Tickets

If no Jira tickets or PRs were mentioned in the conversation, skip the gate check and Jira steps entirely. Still update plan progress if a plan file was used this session (see step 7), then run `park -c` and delete extra branches.

## Output

Narrate every action as it happens. Report what you're checking, what you found, and what you're doing. Prefix each line with a status emoji so the summary is easy to scan: ✅ for success/done, ⚠️ for a warning or skipped/no-op step, ❌ for a failure or blocked step. Example:

```
✅ Checking PR #1234 (branch fix-login)... merged
✅ Transitioning MF-567 to Done... done
✅ Updating plan scratch/plans/fix-login.md... marked 3 tasks complete
⚠️ No plan file found this session — skipping plan update
✅ Running park -c... parked on pl
✅ Deleting branch add-retry-logic... deleted
```

## Gate Check Failure Output

When bailing due to unmerged PRs (and `watch-pr-and-fix` is not available), include full status details:

```
❌ Cannot park — unmerged PRs exist:

  PR #1234 (branch fix-login)
    State: open (draft)
    Checks: 3/5 passing, 1 failing, 1 pending

  PR #1235 (branch add-feature)
    State: open
    Checks: all passing, awaiting review

Merge these PRs first, or re-run with /park -a to abandon.
```

## Jira Reference

- **Cloud ID**: `dropbox.atlassian.net`
- **Done**: transition ID `91`
- **Open**: transition ID `61`
- Use `mcp__atlassian__transitionJiraIssue` for transitions.

## Important Notes

- Always run `park` outside the sandbox (it needs to modify git state and call cmux).
- Always pass `-c` to `park` — the branch is either merged or being abandoned, so clean it up.
- Only look at Jira tickets explicitly mentioned in the conversation — don't query for linked tickets.
- Ticket keys can come from any project (MF-*, IOSDBAPP-*, ANDROIDDBAPP-*).
