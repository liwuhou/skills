---
name: skill-reviewer
description: "Review Skill quality against best practices. Use when user says 'review this skill', 'check skill quality', 'audit skill design', 'skill code review', 'improve this skill', 'check if this skill follows best practices'. Supports 10 core dimensions: progressive loading, trigger design, workflow structure, script encapsulation, instruction design, confirmation nodes, pre-delivery checks, parameter system, references organization, and overall design."
argument-hint: "[skill-path] [--quick] [--detailed] [--fix]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Skill Review Expert

Systematically review Skill quality against 10 Skill design best practices, identify design flaws, and provide actionable improvement suggestions.

## Workflow Checklist
Copy this checklist and check off items as you complete them:

Skill Review Progress:
- [ ] Step 0: Load review criteria ⛔ BLOCKING
  - [ ] Read full review criteria from references/checklist.md
  - [ ] Confirm Skill path to review: use user-provided path if given, otherwise use current directory
- [ ] Step 1: Basic structure check
  - [ ] Verify Skill directory structure follows conventions (SKILL.md exists, references/scripts/assets directories exist as needed)
  - [ ] Count SKILL.md lines, determine if content should be split into references
- [ ] Step 2: Progressive loading check
  - [ ] Verify non-essential content is split into references directory
  - [ ] Verify SKILL.md is under 500 lines
  - [ ] Verify reference files are loaded only when needed, not all at once
- [ ] Step 3: Description trigger design check
  - [ ] Verify frontmatter description contains sufficient trigger keywords
  - [ ] Verify usage scenarios and trigger phrases are clearly stated
  - [ ] Verify "when to use" information is in description, not in SKILL.md body
- [ ] Step 4: Workflow checklist check
  - [ ] Verify clear step-by-step checklist exists
  - [ ] Verify required/blocking nodes are marked
  - [ ] Verify conditional branches are annotated
- [ ] Step 5: Script encapsulation check
  - [ ] Verify deterministic operations are encapsulated as scripts in scripts/ directory
  - [ ] Identify duplicate code that could be encapsulated as scripts
- [ ] Step 6: Instruction design check
  - [ ] Verify instructions use specific guiding questions rather than abstract requirements
  - [ ] Verify model is guided to analyze with specific questions rather than vague instructions
- [ ] Step 7: Confirmation node check
  - [ ] Verify user confirmation nodes exist before critical operations
  - [ ] Verify model cannot perform irreversible operations without user approval
- [ ] Step 8: Pre-delivery checklist check
  - [ ] Verify output-focused Skills have Pre-Delivery Checklist
  - [ ] Verify checklist items are specific and verifiable, not vague requirements
- [ ] Step 9: Parameter system check
  - [ ] Verify flexible parameter system is designed
  - [ ] Verify frontmatter has argument-hint for parameter suggestions
- [ ] Step 10: References organization check
  - [ ] Verify references are organized by domain
  - [ ] Verify only relevant domain files are loaded, not all references at once
- [ ] Step 11: Generate review report ⚠️ REQUIRED
  - [ ] Prioritize issues by P0-P3 severity
  - [ ] Provide specific improvement suggestions and examples for each issue
  - [ ] Summarize overall quality score (1-10)
- [ ] Step 12: Confirm auto-fix
  - [ ] If user used --fix parameter, automatically fix automatable issues
  - [ ] Otherwise ask user if they want automatic fixes for applicable issues

## Issue Severity Definitions
| Severity | Meaning | Recommendation |
|----------|---------|----------------|
| P0 | Critical defect, completely violates best practices, prevents Skill from working or triggering | Must fix immediately |
| P1 | Important defect, severely impacts user experience, trigger rate, or output quality | Should fix with high priority |
| P2 | Medium issue, impacts maintainability or extensibility | Recommended to fix |
| P3 | Optimization suggestion, doesn't affect functionality but could be improved | Optional fix |

## Report Format
ALWAYS use this exact template:

# Skill Review Report
## Basic Information
- Skill Name: {skill-name}
- Review Date: {current-date}
- Overall Score: {score}/10

## Core Strengths
{List 2-3 well-implemented aspects}

## Issue Summary
### P0 Critical Issues
{List all P0 issues, each includes: issue description, improvement suggestion}

### P1 Important Issues
{List all P1 issues, each includes: issue description, improvement suggestion}

### P2 Medium Issues
{List all P2 issues, each includes: issue description, improvement suggestion}

### P3 Optimization Suggestions
{List all P3 optimization suggestions}

## Improvement Plan
{Provide overall improvement direction and priority recommendations}