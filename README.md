# statusline

My Claude Code status line setup.

- `statusline.sh` — the active status line script (referenced by `~/.claude/settings.json`).
- `statusline-command.sh` — an alternate, simpler variant.

## Install

```sh
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Then point Claude Code at it in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash \"$HOME/.claude/statusline.sh\""
  }
}
```

Requires `jq` and `git` on `PATH`.
