---
name: trace-code-path
description: Trace code plumbing from an entry point to terminal behavior, with ordered source links and exact snippets. Use when asked to show a call path, dependency wiring, or how a value reaches its effect. For explanation, not general code review or implementation.
---

Produce a source-backed trace in the format below. Keep it concise; make every connection inspectable. The workflow is read-only: source edits, branch changes, PR comments, and fixes require a separate request.

## Trace

1. Resolve the question, entry point, and terminal behavior. Pin one revision. For a PR, query its current head and base; honor an explicitly pinned ref. Read all source from that same full commit, using `git show <commit>:<path>` or equivalent repository tools. State any unavailable revision verification. For requested working-tree changes, identify them as local and use local links rather than attributing them to a commit.
   Complete when the relevant repository, revision, and requested path or branches are identified.

2. Follow actual calls and value flow through constructors, injected providers, generated routes, dispatch, and asynchronous boundaries as relevant. Resolve the concrete implementation selected on this path. Include bridge evidence connecting each caller to its implementation and the operation that produces the final effect. A helper's definition alone does not prove it is called. Follow requested alternate branches separately; mark inferred or unresolved edges explicitly rather than completing them by naming similarity.
   Complete when every necessary edge from entry to terminal behavior is supported by source, or its precise evidence gap is identified.

3. Extract short verbatim snippets from the pinned source. Verify each snippet and its starting line against that revision. Use several link/snippet pairs for a hop that crosses files. Preserve exact source; split noncontiguous excerpts into separate blocks and identify omitted spans outside the blocks. Keep only lines needed to prove the edge or effect.
   Complete when every displayed snippet matches its linked source and every claimed edge has evidence or an explicit uncertainty.

4. Write the ordered trace below, then answer the original question in one short conclusion. Check that the flow, headings, snippets, and conclusion describe the same path and revision.
   Complete when a reader can follow all claimed connections to the actual terminal operation, with every requested branch covered and evidence limits visible.

## Source links

- Verify the repository host and owner/repository from its remote or repository metadata. For GitHub, use immutable links: `https://HOST/OWNER/REPO/blob/FULL_COMMIT/ENCODED_PATH#LNN`. URL-encode the path while preserving `/`; anchor the snippet's actual starting line. Use the equivalent immutable source permalink on other hosts.
- Use PR review links only when diff context is requested, with verified diff lines and side. A PR URL or search result is not a source permalink.
- For local-only source, use `[File.ext:NN](/absolute/path/File.ext:NN)`. Local links show current files: verify their contents match the excerpt; disclose local modifications. If the local file differs from pinned source, use a revision-matching source view and disclose that limitation.

## Required answer format

Lead with revision verification and a one-line flow. For a verified live PR: `Verified on current PR head [shortsha]. The path is:` followed by the flow in backticks. Otherwise name the verified commit, pinned ref, or local source accurately.

Use numbered headings describing what each hop does. Immediately follow each with a descriptive source link and a short fenced block in the source language. Add a brief explanation only where the connection needs it. Adapt the number of hops and language to the code; retain this structure rather than replacing it with a diagram or prose-only explanation.

The following is a format template; replace bracketed values with verified source, never present template text as code:

````markdown
Verified on current PR head [shortsha]. The path is:
`Entry → provider → client → transport → terminal behavior`

### 1. Entry resolves provider

[Entry.ext:line](https://HOST/OWNER/REPO/blob/FULL_COMMIT/PATH#LNN)

```language
[exact source proving this connection]
```

### 2. Provider calls the concrete client

[Provider.ext:line](https://HOST/OWNER/REPO/blob/FULL_COMMIT/PATH#LNN)

```language
[exact source proving the next connection]
```

[Continue through the terminal operation, with additional links/snippets where needed.]

[Short conclusion answering the question; state any remaining uncertainty.]
````
