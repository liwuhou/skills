# skill-reviewer

A LLM Skill for reviewing other Skills against 10 industry best practices, inspired by the article "10 Patterns for Writing High-Quality Skills". Compatible with any LLM client that supports the skills.sh protocol.

## ✨ Features

- **10-Dimensional Review**: Covers all aspects of Skill design:
  - Progressive loading implementation
  - Description trigger design
  - Workflow checklist structure
  - Script encapsulation for deterministic tasks
  - Instruction design quality
  - Confirmation node placement
  - Pre-delivery checklist presence
  - Parameter system design
  - References directory organization
  - Overall design quality

- **Automated Checks**: Built-in script to automatically validate quantifiable metrics
- **Severity Classification**: Issues categorized as P0 (Critical) to P3 (Optimization)
- **Auto-Fix Support**: Automatically resolve common issues
- **Structured Reports**: Clear, actionable output with improvement suggestions

## 🚀 Installation

```bash
npx skills add liwuhou/skills/skill-reviewer
```

## 📖 Usage

### Basic Review
```bash
/skill-reviewer <path-to-skill-directory>
```

### Quick Check (Only P0/P1 Issues)
```bash
/skill-reviewer <path> --quick
```

### Detailed Review
```bash
/skill-reviewer <path> --detailed
```

### Review + Auto-Fix
```bash
/skill-reviewer <path> --fix
```

## 📊 Output Example

```
# Skill Review Report
## Basic Information
- Skill Name: example-skill
- Review Date: 2026/05/13
- Overall Score: 7/10

## Core Strengths
1. Good script encapsulation of repetitive tasks
2. Clear workflow with blocking nodes marked

## Issue Summary
### P1 Important Issues
- Description lacks trigger keywords: Add user phrases like 'review my skill'

### P2 Medium Issues
- SKILL.md is 620 lines: Split content to references directory
```

## 🛠️ Best Practices Followed
This skill itself follows all the best practices it checks for:
- ✅ SKILL.md under 100 lines (far under 500 line limit)
- ✅ Detailed criteria split into references/checklist.md (progressive loading)
- ✅ Description contains 6+ trigger keywords for high trigger rate
- ✅ Clear step-by-step workflow checklist
- ✅ Automated checks encapsulated as a standalone script
- ✅ Uses guiding questions rather than abstract instructions
- ✅ Includes user confirmation nodes before auto-fix operations
- ✅ Supports multiple parameters for flexible usage

## 📝 License
MIT