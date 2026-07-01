---
name: jira
description: Create a Jira ticket assigned to Jim Boulter. Defaults to MF (Mobile Foundation) project. Use IOSDBAPP for iOS tickets or ANDROIDDBAPP for Android tickets. Handles sprint assignment and status transitions.
---

Create a Jira ticket using the Atlassian MCP tools with the following defaults and reference data.

## Reference Data

- **Cloud ID**: `dropbox.atlassian.net`
- **Jim Boulter's account ID**: `5ee8e71253e5390aba718e89`
- **Default project**: `MF` (Mobile Foundation)
- **iOS project**: `IOSDBAPP`
- **Android project**: `ANDROIDDBAPP`

## Finding the Current Sprint

Always query the MF project for the active sprint (the sprint lives on the MF board regardless of which project the ticket is in):

```
project = MF AND sprint in openSprints() ORDER BY created DESC
```

Request `customfield_10020` in the fields to get the sprint object. The sprint ID is in `customfield_10020[0].id` (a number). Pass it as `additional_fields: {"customfield_10020": <sprint_id>}` when creating the issue.

## Creating the Ticket

Use `mcp__atlassian__createJiraIssue` with:

- `cloudId`: `dropbox.atlassian.net`
- `projectKey`: `MF` (or `IOSDBAPP`/`ANDROIDDBAPP` if specified)
- `issueTypeName`: `Task` (or `Bug`, `Story` as appropriate)
- `summary`: concise title
- `description`: markdown description of the work
- `assignee_account_id`: `5ee8e71253e5390aba718e89`
- `contentFormat`: `markdown`
- `additional_fields`: `{"customfield_10020": <sprint_id>}` to assign to current sprint

## Setting Status

After creation, transition the ticket using `mcp__atlassian__transitionJiraIssue`:

- **In Progress**: transition ID `71`
- **In Review**: transition ID `101`
- **Done**: transition ID `91`
- **Blocked**: transition ID `41`

Default to "In Progress" when creating a ticket for active work.

## Keeping Subtasks in Sync

**Whenever you transition a task, always check for subtasks and transition them to match the parent's new status.** Fetch the issue's `subtasks` (include it in the query fields) before transitioning so you know what's beneath it, then apply the same transition to each subtask.

The same transition IDs apply to subtasks as to parents (71/101/91/41). When auditing existing tickets, reconcile each subtask against its parent's status, not just the parents.

## Workflow

1. Find the current sprint (if assigning to sprint)
2. Create the ticket
3. Transition to the requested status (default: In Progress)
4. Report the ticket key and URL to the user
