---
name: composio
description: Composio integration for OpenCode. Use when a task involves third-party app tool calls (Gmail, GitHub, Slack, Notion, Linear, Stripe, etc.), connecting a user account to an external app, authoring code that uses the Composio SDK or REST API, or inspecting tool/toolkit/connected-account state. Triggers on phrases like "use composio", "connect github", "send via gmail", "list linear issues", "run composio tool", or any request to call an action in another app from this repo.
argument-hint: "[search|link|execute|proxy|run|sdk|dev] [args]"
metadata:
  author: opencode
  version: "1.0.0"
  composio-api: v3.1
---

# Composio

Drive third-party apps from OpenCode via the Composio CLI or SDK. Preferred: install the CLI once (`curl -fsSL https://composio.dev/install | sh`) and let OpenCode call `composio search|link|execute|proxy|run` through the `bash` tool. Fallback: author code against the Python `composio` package or the TS `@composio/core` package.

> Windows host: the installer needs `sh`. Run it inside WSL, or skip the CLI and use the SDK directly from PowerShell.

## When to Activate

- Any task that calls a third-party API on the user's behalf (Gmail, GitHub, Slack, Notion, Linear, Stripe, Sentry, Supabase, Google Calendar, etc.).
- Authoring or reviewing code that imports `composio` / `@composio/core`.
- Inspecting toolkits, auth configs, or connected accounts (`composio dev toolkits ...`, `composio dev auth-configs ...`, `composio dev connected-accounts ...`).
- Listening to webhook/trigger events (`composio dev listen --toolkits ...`).

## CLI Path (preferred when installed)

Discover, connect, execute:

```bash
composio search "summarize my unread gmail"
composio execute GMAIL_FETCH_EMAILS --get-schema
composio link gmail
composio execute GMAIL_FETCH_EMAILS -d '{ query: "is:unread newer_than:1d", max_results: 10 }'
composio proxy https://gmail.googleapis.com/gmail/v1/users/me/profile --toolkit gmail
```

Workflows and sub-agents:

```bash
composio run '
const issues = await execute("GITHUB_LIST_REPOSITORY_ISSUES", {
  owner: "composiohq", repo: "composio", state: "open"
});
console.log(issues);
'
```

Inspect state:

```bash
composio dev toolkits list
composio dev toolkits info github
composio dev auth-configs list --toolkits github,gmail
composio dev connected-accounts list --status ACTIVE
composio dev playground-execute GMAIL_SEND_EMAIL -d '{ ... }'
composio dev logs tools --toolkit gmail --limit 20
composio dev listen --toolkits gmail --table
composio generate ts --toolkits github
composio generate py --toolkits github
```

Login once after install: `composio login`.

## SDK Path (fallback / scripted agents)

Current integration mode is **sessions**. Native-tools providers (`composio_openai_agents`, `@composio/openai-agents`) accept a session; OpenAI/Anthropic helpers do too. Other providers call `session.execute(tool_slug, arguments)`.

Python:

```python
from composio import Composio

composio = Composio()
session = composio.create(user_id="user_123")
tools = session.tools()
# pass `tools` to your agent/framework

result = session.execute("GITHUB_CREATE_ISSUE", arguments={
    "owner": "composiohq",
    "repo": "composio",
    "title": "bug: ...",
})
```

TypeScript:

```typescript
import { Composio } from "@composio/core";

const composio = new Composio();
const session = await composio.create("user_123");
const tools = await session.tools();

const result = await session.execute("GITHUB_CREATE_ISSUE", {
  owner: "composiohq",
  repo: "composio",
  title: "bug: ...",
});
```

MCP transport (any MCP client, no provider package):

```python
session = composio.sessions.create(user_id="user_123", mcp=True)
mcp_url = session.mcp.url
mcp_headers = session.mcp.headers
```

## Conventions (v3)

- `user_id` (not "entity id"). Pass to `composio.create(...)`; do NOT pass on individual `session.execute(...)` calls.
- `toolkit` (not "app"/"appType"). Each tool slug is namespaced: `GITHUB_CREATE_ISSUE`, `GMAIL_FETCH_EMAILS`.
- `auth_config_id` / `connected_accounts` (not "integration" or "connection").
- `provider` package name = framework, not model vendor. For OpenAI Agents SDK: `composio_openai_agents` / `@composio/openai-agents` (NOT `composio_openai` for that framework).
- REST API: `https://backend.composio.dev/api/v3.1`. v3 frozen but still supported.
- Tool execution must go through the session (`session.execute`, `provider.handle_tool_calls(session=...)`, or `provider.handleToolCalls(session, response)`). Binding helper to a user ID uses the direct path and breaks session meta-tools.

## Decision Tree

1. Has the user asked for a one-off action in another app, with the CLI installable? -> CLI.
2. Authoring or modifying app code that calls Composio? -> SDK, session mode.
3. Connecting an existing MCP-compatible agent? -> hosted `session.mcp.url` after creating a session with `mcp=True`.
4. Need production runtime? -> SDK/API. CLI is for personal-agent and bootstrap use only (no SLA).

## References

- `references/cli.md` — full CLI command surface and flag index.
- https://docs.composio.dev/docs/agent-plugins — Codex/Claude Code plugin install.
- https://docs.composio.dev/docs/cli — CLI reference.
- https://docs.composio.dev/docs/quickstart — SDK quickstart.
