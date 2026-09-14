---
name: composio
description: Composio AI agent toolkit — 1500+ app integrations (Gmail, GitHub, Linear, Slack, Notion, etc.). Use when user asks to manage email, create GitHub PRs, sync Calendar, post to Slack, query Notion, or any connected-app action. Trigger keywords: composio, email, github, slack, gmail, calendar, notion, linear, connected apps, app integrations.
---

# Composio Skill

Composio gives OpenCode tools to act across 1500+ apps with managed OAuth auth.

## Setup (One-time)

### 1. Install Composio CLI

```bash
curl -fsSL https://composio.dev/install | sh
```

### 2. Login and setup

```bash
composio login
composio setup --target auto
```

### 3. Get your MCP URL

```python
from composio import Composio

composio = Composio()
session = composio.create(user_id="opencode-user")
print(f"URL: {session.mcp.url}")
print(f"Headers: {session.mcp.headers}")
```

Or via CLI after setup:

```bash
composio dev mcp list
```

### 4. Configure OpenCode MCP

Add to `~/.config/opencode/opencode.jsonc`:

```json
{
  "mcp": {
    "composio": {
      "type": "remote",
      "url": "YOUR_MCP_URL_FROM_STEP_3",
      "headers": {
        "x-api-key": "YOUR_COMPOSIO_API_KEY"
      }
    }
  }
}
```

Restart OpenCode after saving.

## Usage

After setup, Composio tools available via MCP. Example tasks:

- "Summarize my unread emails from today"
- "Create a GitHub PR for the latest commit"
- "List all open Linear issues assigned to me"
- "Post to #engineering channel in Slack"
- "Create a Notion page with meeting notes"

## Key Concepts

| Term | Meaning |
|------|---------|
| Toolkit | App integration (e.g., `github`, `gmail`) |
| Tool | Single action (e.g., `GITHUB_CREATE_PR`) |
| Session | Per-user context for tool access + auth |
| Auth config | Pre-configured OAuth credentials (optional) |

Composio manages OAuth flow at runtime. User gets a Connect Link when auth needed.

## CLI Commands

```bash
composio search "find tool"       # Find tools
composio execute TOOL_SLUG        # Run a tool
composio link gmail               # Connect Gmail account
composio dev logs                 # Inspect execution logs
```

## Error: "can only be called inside a tool-router session"

Using direct execution API with session-only tools. Use session mode:

```python
session.execute("GITHUB_CREATE_ISSUE", arguments={...})
```

Not:

```python
composio.tools.execute("GITHUB_CREATE_ISSUE", ...)
```
