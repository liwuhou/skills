#!/usr/bin/env python3
"""
Skill Review Automated Check Script
Automatically checks quantifiable metrics
"""
import os
import re
import yaml
from pathlib import Path

def check_skill_structure(skill_path):
    """Check basic Skill structure"""
    issues = []
    skill_path = Path(skill_path)

    # Check if SKILL.md exists
    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        issues.append(("P0", "SKILL.md file does not exist", "SKILL.md must be created in the Skill root directory"))
        return issues, None

    # Read SKILL.md content
    with open(skill_md, 'r') as f:
        content = f.read()

    # Separate frontmatter and body
    if content.startswith('---'):
        frontmatter_part = content.split('---', 2)[1]
        body = content.split('---', 2)[2]
        try:
            frontmatter = yaml.safe_load(frontmatter_part)
        except yaml.YAMLError as e:
            issues.append(("P0", f"SKILL.md frontmatter format error: {e}", "Fix the YAML format in frontmatter"))
            return issues, None
    else:
        issues.append(("P0", "SKILL.md has no valid frontmatter", "Add YAML frontmatter at the beginning of SKILL.md"))
        return issues, None

    # Check required frontmatter fields
    if 'name' not in frontmatter:
        issues.append(("P0", "Missing 'name' field in frontmatter", "Add 'name' field in frontmatter as the unique identifier for the Skill"))
    if 'description' not in frontmatter:
        issues.append(("P0", "Missing 'description' field in frontmatter", "Add 'description' field in frontmatter explaining the Skill's purpose and trigger scenarios"))

    # Check SKILL.md line count
    line_count = len(content.splitlines())
    if line_count > 500:
        issues.append(("P1", f"SKILL.md is too long ({line_count} lines, exceeds recommended 500 lines)",
                      "Split detailed content into references directory, keep only workflow orchestration in SKILL.md"))

    # Check description quality
    if 'description' in frontmatter:
        desc = frontmatter['description']
        # Check for trigger phrases (at least 3 different trigger phrases in quotes)
        trigger_phrases = re.findall(r"'[^']+'|\"[^\"]+\"", desc)
        if len(trigger_phrases) < 3:
            issues.append(("P1", "Description contains too few trigger keywords",
                          "Add more user trigger phrases in quotes to description, e.g., 'review my code', 'check this PR'"))

        # Check if it contains trigger indications
        if not any(keyword in desc.lower() for keyword in ["when user says", "use when", "trigger", "when to use"]):
            issues.append(("P2", "Description does not clearly state trigger scenarios",
                          "Clearly state when this Skill should be used in the description"))

    # Check directory structure
    references_dir = skill_path / "references"
    scripts_dir = skill_path / "scripts"

    # Check if references directory exists (recommended when SKILL.md exceeds 300 lines)
    if line_count > 300 and not references_dir.exists():
        issues.append(("P2", "SKILL.md has significant content but no references directory",
                      "Create references directory and split detailed reference materials, checklists, etc. into it"))

    # Check for argument-hint
    if 'argument-hint' not in frontmatter and 'parameters' not in frontmatter:
        issues.append(("P3", "No argument-hint or parameters field in frontmatter",
                      "Add argument-hint field to provide parameter suggestions when user types /"))

    # Check for workflow checklist
    if not re.search(r'-\s*\[\s*\]\s*Step', body, re.IGNORECASE) and not re.search(r'checklist', body, re.IGNORECASE):
        issues.append(("P2", "SKILL.md has no clear workflow checklist",
                      "Add step-by-step checklist for the model to follow, improving output consistency"))

    # Check for confirmation nodes
    if not re.search(r'confirm|ask user|required|blocking|user approval', body, re.IGNORECASE):
        issues.append(("P3", "SKILL.md has no explicit user confirmation nodes",
                      "Add user confirmation nodes before critical operations to prevent unintended actions"))

    return issues, frontmatter

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Automatically check basic Skill quality')
    parser.add_argument('skill_path', help='Path to Skill directory')
    args = parser.parse_args()

    issues, frontmatter = check_skill_structure(args.skill_path)

    if frontmatter:
        print(f"Skill Name: {frontmatter.get('name', 'Unknown')}")
        print(f"Description: {frontmatter.get('description', 'None')}\n")

    print("Automatically detected issues:")
    print("=" * 50)

    if not issues:
        print("✅ No basic issues found")
        return

    # Sort by priority
    priority_order = {"P0": 0, "P1": 1, "P2": 2, "P3": 3}
    issues.sort(key=lambda x: priority_order[x[0]])

    for level, issue, suggestion in issues:
        print(f"{level}: {issue}")
        print(f"  Suggestion: {suggestion}\n")

if __name__ == "__main__":
    main()