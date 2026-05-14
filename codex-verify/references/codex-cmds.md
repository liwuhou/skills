# Codex CLI Reference

Canonical reference for Codex CLI commands used by this skill. Read this when you need detailed option information, fallback strategies, or config details.

## Key distinction: `codex review` vs `codex exec review`

**`codex review`** does NOT support `-o`, `--ephemeral`, or `-s` — it has its own output format and cannot capture output to a file.

**`codex exec review`** runs the review through the exec subsystem, supporting all exec options (`-o`, `--ephemeral`, `-s`, `--skip-git-repo-check`). **Always use this variant for verification — it's the only way to capture output reliably.**

The `codex-run.sh` script uses `codex exec review` internally for diff/branch scopes, so you never need to worry about this distinction when using the script.

## codex exec — Non-interactive execution

```bash
codex exec [OPTIONS] [PROMPT]
```

| Option | Description |
|--------|-------------|
| `-o, --output-last-message <FILE>` | Write final response to file (preferred capture method) |
| `-s, --sandbox <MODE>` | `read-only` / `workspace-write` / `danger-full-access` — always use `read-only` for verification |
| `--ephemeral` | Don't persist session files — always use this to avoid polluting Codex history |
| `-C, --cd <DIR>` | Set working directory |
| `--add-dir <DIR>` | Additional writable directories |
| `--json` | Print events as JSONL to stdout — fallback when `-o` produces empty output |
| `-m, --model <MODEL>` | Override model (default from config) |
| `-i, --image <FILE>` | Attach images to prompt |
| `--skip-git-repo-check` | Allow running outside a git repo — needed when reviewing files not in a repo |

## codex exec review — Review via exec (recommended)

```bash
codex exec review [OPTIONS] [PROMPT]
```

Same functionality as `codex review` but with full exec option support. Use this for all diff/branch scope verification.

| Review-specific option | Description |
|------------------------|-------------|
| `--uncommitted` | Review staged, unstaged, and untracked changes |
| `--base <BRANCH>` | Review changes against a base branch |
| `--commit <SHA>` | Review changes introduced by a commit |
| `--title <TITLE>` | Optional title for the review |

## codex review — Standalone review (do NOT use for verification)

```bash
codex review [OPTIONS] [PROMPT]
```

This variant has limited options and does NOT support `-o` for output capture. Only useful for quick interactive terminal reviews. **Do not use in this skill.**

## Output capture strategies (ordered by preference)

1. **Preferred**: `-o <FILE>` via `codex exec` — writes the agent's final message to a file. Clean, easy to read back.
2. **Fallback**: `--json` — prints JSONL events to stdout. Pipe to file and parse for the final `message` event where `role` equals `assistant`. Codex JSONL events are JSON objects with `type`, `role`, and `content` fields.
3. **Last resort**: redirect stdout — `codex exec ... > output.txt` captures streamed text but may include intermediate tool-call events.

## Fallback procedure for empty output

If `-o` produces an empty file:
1. Generate a unique path: `JSONL_OUT=$(mktemp)`
2. Run: `codex exec --skip-git-repo-check --json --ephemeral -s read-only <PROMPT> > "$JSONL_OUT"`
3. Parse JSONL: `grep '"type":"message"' "$JSONL_OUT" | grep '"role":"assistant"' | tail -1 | jq -r '.content[0].text'`
4. If jq is unavailable: manually scan for the last line containing `"role":"assistant"` and extract the text content

## Config location

`~/.codex/config.toml` — contains model, provider, sandbox, and project settings. Check this file for your local model and provider configuration.