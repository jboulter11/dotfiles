#!/usr/bin/env python3
"""Submit a read-only Git comparison as one Kaleidoscope changeset."""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import uuid


def run_command(arguments, cwd):
    return subprocess.run(
        arguments,
        cwd=cwd,
        check=True,
        stdout=subprocess.PIPE,
    ).stdout


def parse_arguments():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--ksdiff", default="ksdiff", help="ksdiff executable")

    modes = parser.add_subparsers(dest="mode", required=True)

    uncommitted = modes.add_parser("uncommitted")
    selection = uncommitted.add_mutually_exclusive_group()
    selection.add_argument("--staged", action="store_true")
    selection.add_argument("--unstaged", action="store_true")

    committed = modes.add_parser("committed")
    committed.add_argument("--commit")
    committed.add_argument("--base")
    committed.add_argument("--head", default="HEAD")
    committed.add_argument("--merge-base", action="store_true")

    for mode in (uncommitted, committed):
        mode.add_argument("paths", nargs="*", help="repository-relative pathspecs")

    return parser, parser.parse_args()


def main():
    parser, args = parse_arguments()
    repository_root = run_command(
        ["git", "rev-parse", "--show-toplevel"],
        cwd=args.repo,
    )
    repo = Path(os.fsdecode(repository_root).strip())

    def git(*arguments):
        return run_command(["git", *arguments], cwd=repo)

    def revision(ref):
        return os.fsdecode(git("rev-parse", "--verify", ref + "^{commit}")).strip()

    # Select both content sources and the Git diff that lists their changed paths.
    # The index and working tree are read directly; neither is modified.
    if args.mode == "uncommitted":
        if args.staged:
            left, right = revision("HEAD"), "index"
            diff_args = ["--cached", left]
        elif args.unstaged:
            left, right = "index", "worktree"
            diff_args = []
        else:
            left, right = revision("HEAD"), "worktree"
            diff_args = [left]
    else:
        if args.commit:
            if args.base or args.merge_base or args.head != "HEAD":
                parser.error("--commit cannot be combined with endpoint options")

            right = revision(args.commit)
            parents = os.fsdecode(
                git("rev-list", "--parents", "-n", "1", right)
            ).split()[1:]

            if parents:
                left = parents[0]
            else:
                # A root commit has no parent, so compare it against an empty tree.
                empty_tree = subprocess.run(
                    ["git", "hash-object", "-t", "tree", "--stdin"],
                    input=b"",
                    cwd=repo,
                    check=True,
                    stdout=subprocess.PIPE,
                ).stdout
                left = os.fsdecode(empty_tree).strip()
        else:
            if not args.base:
                parser.error("committed requires --commit or --base")

            left, right = revision(args.base), revision(args.head)
            if args.merge_base:
                left = os.fsdecode(git("merge-base", left, right)).strip()

        diff_args = [left, right]

    # NUL-delimited records preserve filenames containing spaces or newlines.
    # Rename/copy records contain two paths; other records contain just one.
    records = git(
        "diff",
        "--no-ext-diff",
        "--no-textconv",
        "--name-status",
        "-z",
        "--find-renames",
        *diff_args,
        "--",
        *args.paths,
    ).split(b"\0")

    entries = []
    cursor = 0
    while cursor < len(records) and records[cursor]:
        status = os.fsdecode(records[cursor])
        old_path = os.fsdecode(records[cursor + 1])
        cursor += 2

        new_path = old_path
        if status[0] in "RC":
            new_path = os.fsdecode(records[cursor])
            cursor += 1

        if status[0] == "U":
            raise ValueError("Unmerged file requires targeted review: " + old_path)

        entries.append((status, old_path, new_path))

    # Git diff excludes untracked files. Include them for working-tree reviews;
    # staged-only reviews must contain only files already in the index.
    if args.mode == "uncommitted" and not args.staged:
        untracked_paths = git(
            "ls-files", "--others", "--exclude-standard", "-z", "--", *args.paths
        ).split(b"\0")

        for name in untracked_paths:
            if name:
                path = os.fsdecode(name)
                entries.append(("A", path, path))

    if not entries:
        print("No changes in the requested scope.")
        return

    executable = shutil.which(args.ksdiff)
    if not executable:
        raise ValueError("ksdiff executable not found: " + args.ksdiff)

    def contents(source, path):
        """Read file bytes from a revision, the index, or the working tree."""
        if source == "worktree":
            file_path = repo / path
            if file_path.is_symlink():
                # Git stores the link target, not the contents of the linked file.
                return os.fsencode(os.readlink(file_path))
            if file_path.is_dir():
                raise ValueError("Submodule/directory requires targeted review: " + path)
            return file_path.read_bytes()

        spec = ":" + path if source == "index" else source + ":" + path
        if git("cat-file", "-t", spec).strip() != b"blob":
            raise ValueError("Submodule/non-file requires targeted review: " + path)
        return git("cat-file", "blob", spec)

    # Snapshot every file before launching UI. Unsupported entries should fail
    # before Kaleidoscope opens a partial review. Retain snapshots for the user.
    artifacts = Path(tempfile.mkdtemp(prefix="ksdiff-changeset-"))
    manifest = {
        "repo": str(repo),
        "left": left,
        "right": right,
        "uuid": str(uuid.uuid4()),
        "files": [],
    }

    for number, (status, old_path, new_path) in enumerate(entries):
        directory = artifacts / str(number)
        directory.mkdir()
        before = directory / "before"
        after = directory / "after"

        # Added/deleted files use an empty snapshot for their missing side.
        before.write_bytes(b"" if status[0] == "A" else contents(left, old_path))
        after.write_bytes(b"" if status[0] == "D" else contents(right, new_path))
        manifest["files"].append({
            "status": status,
            "old_path": old_path,
            "path": new_path,
            "before": str(before),
            "after": str(after),
        })

    (artifacts / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print("Comparison snapshots: " + str(artifacts), flush=True)

    # One shared UUID groups all file comparisons into the same changeset.
    # Close it even after a later submission fails, preserving accepted files.
    submitted = False
    try:
        for entry in manifest["files"]:
            subprocess.run(
                [
                    executable,
                    "--partial-changeset",
                    "--UUID", manifest["uuid"],
                    "--relative-path", entry["path"],
                    entry["before"], entry["after"],
                ],
                stdin=subprocess.DEVNULL,
                check=True,
            )
            submitted = True
    finally:
        if submitted:
            subprocess.run(
                [executable, "--mark-changeset-as-closed", manifest["uuid"]],
                stdin=subprocess.DEVNULL,
                check=True,
            )

    print("Submitted " + str(len(entries)) + " file comparison(s) in one changeset.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
