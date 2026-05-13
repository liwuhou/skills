# Configuration Options
## Generic Configuration
Users can configure these options via their LLM client's settings system:

```json
{
  "multi-agent": {
    "max_parallel_agents": 5,
    "use_git_worktree": true,
    "auto_cleanup": false,
    "worktree_base": "./worktrees",
    "output_base": "./outputs",
    "default_timeout_minutes": 30
  }
}
```

## Platform-Specific Configuration
### Claude Code
Store in `.claude/settings.json`:
```json
{
  "multi-agent": {
    "max_parallel_agents": 5,
    "use_git_worktree": true,
    "auto_cleanup": false
  }
}
```

### Other Platforms
Refer to your LLM client's documentation for how to configure skill settings. The configuration options above are standard and should be adaptable to any skills.sh compatible client.

## Configuration Options Explained
- `max_parallel_agents`: Maximum number of agents to run in parallel (default: 5)
- `use_git_worktree`: Whether to use git worktree for environment isolation (default: true, disable if not in a git repository)
- `auto_cleanup`: Whether to automatically delete worktrees and branches after task completion (default: false)
- `worktree_base`: Base directory for storing worktrees (default: "./worktrees")
- `output_base`: Base directory for storing subtask outputs (default: "./outputs")
- `default_timeout_minutes`: Default timeout for subtasks in minutes (default: 30)