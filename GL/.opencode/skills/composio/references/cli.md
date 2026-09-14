# Composio CLI Quick Reference

Source of truth: https://docs.composio.dev/docs/cli. This is a condensed index.

## Install

```bash
curl -fsSL https://composio.dev/install | sh
```

Pin a version:

```bash
curl -fsSL https://composio.dev/install | sh -s -- @composio/cli@0.3.1
```

Useful env vars at install time: `COMPOSIO_INSTALL_VERSION`, `COMPOSIO_INSTALL_PLUGINS=1`, `COMPOSIO_INSTALL_SHELL=zsh|bash|fish|none`, `COMPOSIO_INSTALL_DIR`, `COMPOSIO_BIN_DIR`, `COMPOSIO_QUIET=1`, `COMPOSIO_DEBUG=1`.

Windows: use WSL.

## Login + Agent Setup

```bash
composio login
composio setup --target auto        # detect codex + claude
composio setup --target codex
composio setup --target claude
composio setup --target auto --yes  # non-interactive
```

Install only the standalone skill (no plugin):

```bash
composio --install-skill composio-cli claude
composio --install-skill composio-cli codex
```

## Core Commands

| Command                      | Purpose                                       |
| ---------------------------- | --------------------------------------------- |
| `composio search "..."`      | Find tools by natural language                |
| `composio execute <SLUG>`    | Run a known tool; `--get-schema` for input    |
| `composio link <toolkit>`    | Connect an app account (OAuth / API key)      |
| `composio proxy <url>`       | Hit provider API with Composio-managed auth   |
| `composio run '<inline>'`    | Multi-step TS/JS workflow with subagents      |
| `composio run --file ./wf.ts`| Run a checked-in workflow file                |
| `composio generate [ts|py]`  | Generate type defs from tool schemas          |
| `composio dev init`          | Initialize developer project context          |
| `composio dev toolkits ...`  | Inspect toolkits + versions                   |
| `composio dev auth-configs`  | Manage auth configs (list/info/create)        |
| `composio dev connected-accounts` | Manage per-user connections              |
| `composio dev playground-execute` | Direct tool exec via dev namespace      |
| `composio dev logs`          | Tool + trigger execution logs                 |
| `composio dev listen`        | Stream trigger events (table/json/forward)    |

## Execute Flags (essentials)

```bash
composio execute GMAIL_SEND_EMAIL \
  --user-id user_123 \
  -d '{ "recipient_email": "a@b.c", "subject": "hi", "body": "..." }'
composio execute GITHUB_CREATE_ISSUE --get-schema    # print input schema
composio execute GITHUB_CREATE_ISSUE --version latest
```

## Scripting Notes

- `composio run` injects: `execute()`, `search()`, `proxy()`, `experimental_subAgent()`, `result.prompt()`, `z` (zod).
- Use `--logs-off` to suppress internal log lines when scripting.
- Pass-through args after `--`: `composio run --file ./wf.ts -- --repo foo/bar`.

## Uninstall

```bash
rm -f "$HOME/.local/bin/composio" "$HOME/.composio/composio" \
      "$HOME/.composio/release-tag.txt" "$HOME/.composio/run-helpers-runtime.mjs" \
      "$HOME/.composio/run-subagent-shared.mjs" "$HOME/.composio/run-subagent-acp.mjs" \
      "$HOME/.composio/run-subagent-legacy.mjs" "$HOME/.composio/run-subagent-output-mcp.mjs"
rm -rf "$HOME/.composio/services" "$HOME/.composio/acp-adapters" \
       "$HOME/.composio/local-tools-binaries"
```

Full reset (also deletes credentials + caches):

```bash
rm -rf "${COMPOSIO_INSTALL_DIR:-$HOME/.composio}"
```
