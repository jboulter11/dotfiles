---
name: ksdiff
description: Show uncommitted or committed Git changes in Kaleidoscope as one changeset of file-content comparisons. Use when asked to open changes in ksdiff or Kaleidoscope.
---

Show the requested scope as **one changeset containing actual file diffs**. Directory comparisons only show a file inventory; separate comparisons scatter the review across windows. Do not commit, stage, or modify source just to display it.

Run `scripts/open_changeset.py` with the repository/worktree path. Honor the repository's execution permissions, including running Git outside a sandbox where required. The helper uses Git internally.

## Choose the comparison

```bash
# HEAD → working tree, including staged, unstaged, and untracked files
python3 scripts/open_changeset.py --repo /absolute/worktree uncommitted

# HEAD → index, or index → working tree
python3 scripts/open_changeset.py --repo /absolute/worktree uncommitted --staged
python3 scripts/open_changeset.py --repo /absolute/worktree uncommitted --unstaged

# One commit against its first parent
python3 scripts/open_changeset.py --repo /absolute/worktree committed --commit HEAD

# Exact endpoints (equivalent to git diff BASE HEAD)
python3 scripts/open_changeset.py --repo /absolute/worktree committed --base BASE --head HEAD

# Branch contribution since common ancestor (equivalent to git diff BASE...HEAD)
python3 scripts/open_changeset.py --repo /absolute/worktree committed --base main --head HEAD --merge-base
```

`HEAD` is the default committed head. Choose exact endpoints for a requested commit range; choose merge-base for a branch/PR contribution when its base has advanced. Merge commits compare to their first parent; use explicit endpoints for another parent. Root commits compare against an empty tree.

Append repository-relative pathspecs to restrict scope, e.g. `uncommitted -- 'ios/path with spaces.swift'`. Always include non-ignored untracked files in uncommitted working-tree comparisons, including `--unstaged`. Staged-only comparisons show only the index, so they exclude untracked files. Unmerged entries and changed submodules require a separate targeted review; the helper stops instead of pretending they are ordinary files.

## Changeset mechanics

The helper snapshots both sides into a retained temporary directory, then invokes this **once per changed file**, always with the same UUID:

```bash
ksdiff --partial-changeset --UUID "$id" \
  --relative-path "$repo_path" "$before_snapshot" "$after_snapshot" </dev/null
ksdiff --mark-changeset-as-closed "$id" </dev/null
```

Close the shared changeset after submitting its files. If submission fails, the helper closes any partial changeset and reports the error. Keep snapshots until review finishes; the printed directory contains the manifest and exact compared bytes. Missing sides are empty files. Renames compare the old path's contents with the new path's contents and use the new path for display. Working-tree symlinks compare their link targets, matching Git. Content comparisons do not visualize executable-bit changes; mention those separately when present.

Use the minimal commands above. This machine's ksdiff 7.0.2 advertised `--changeset --filelist` but rejected that form; extra flags also failed with changeset modes. Plain two-file comparisons and two-directory comparisons do not meet the grouped-review request. A successful CLI exit confirms submission, not correct UI presentation; if uncertain, ask whether the user sees file contents grouped in one changeset.
