# Skills Collection

A collection of high-quality LLM Skills I've built, following [skills.sh](https://skills.sh) protocol best practices. Compatible with Claude, and other LLM platforms that support the open skill standard.

## 📦 Skills Available

| Skill Name | Description | Installation |
|------------|-------------|--------------|
| [skill-reviewer](./skill-reviewer) | Review Skill quality against 10 best practices, identify design flaws, and provide actionable improvement suggestions. Supports automated checks and auto-fix. | `npx skills add liwuhou/skills/skill-reviewer` |
| [multi-agent](./multi-agent) | Coordinate multiple agents to execute tasks in parallel. Automatically assesses task parallelizability, splits subtasks, and coordinates execution with isolated environments and flexible merge strategies. | `npx skills add liwuhou/skills/multi-agent` |
| [codex-verify](./codex-verify) | Use OpenAI Codex CLI to independently verify code written by Claude. Two-phase verification (defect detection + quality assessment), safe Bash-array commands, automatic JSONL fallback, and user-approval-only fixes. | `npx skills add liwuhou/skills/codex-verify` |

## 🚀 Installation

### Prerequisites
- Node.js 16+
- Claude Code v0.10+

### Install a single skill
```bash
npx skills add <github-username>/<repo-name>/<skill-folder>

# Example: Install skill-reviewer
npx skills add liwuhou/skills/skill-reviewer
```

### Install all skills (coming soon)
```bash
npx skills add liwuhou/skills
```

## 📝 Usage
After installation, skills are available in supported LLM clients (Claude Code, etc.) via slash commands:
```bash
/skill-reviewer <path-to-skill>  # Review a skill
/skill-reviewer --quick          # Quick check for critical issues
/skill-reviewer --fix            # Auto-fix automatable issues
```

## 🛠️ Development
To add a new skill:
1. Create a new directory for your skill
2. Follow the [Skill Writing Guide](https://docs.anthropic.com/claude/docs/skill-development)
3. Add an entry to the table in this README
4. Add a README.md in your skill's directory

## 📄 License
MIT License - feel free to use and modify these skills for your own projects.

## 🤝 Contributing
Contributions are welcome! Feel free to submit PRs with improvements or new skills.