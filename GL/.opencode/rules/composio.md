# Composio Rules

- Activate the `composio` skill for any third-party app action or SDK authoring task.
- Prefer the CLI (`composio search|link|execute|proxy|run`) when installed; fall back to the Python/TS SDK otherwise.
- Use **v3 terminology**: `user_id`, `toolkit`, `tool`, `auth_config_id`, `connected_account`. Translate from old terms if seen.
- For Sessions mode: `composio.create(user_id)` then call `session.execute(slug, arguments)`. Do not pass `user_id` per call.
- Provider packages name the **framework**, not the model. For OpenAI Agents SDK use `composio_openai_agents` / `@composio/openai-agents`.
- REST base: `https://backend.composio.dev/api/v3.1`. v3 still works but is frozen.
- Windows host: Composio CLI install needs WSL. Do not attempt native shell install from this environment.
- Never paste user credentials into commands or code; let `composio link` / `composio login` handle OAuth.
