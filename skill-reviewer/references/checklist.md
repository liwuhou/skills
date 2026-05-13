# Skill Review Checklist

## 1. Progressive Loading Check
Ask yourself:
- Is SKILL.md longer than 500 lines?
- Are large reference materials, checklists, or templates directly embedded in SKILL.md?
- Are reference files loaded only when needed, rather than all at once?
- Does the references directory exist and is its content well-organized?

**Pass Criteria**: SKILL.md only contains workflow orchestration, detailed content is split into references directory, and SKILL.md is kept under 500 lines.

## 2. Description Trigger Design Check
Ask yourself:
- Does the description contain all possible trigger keywords?
- Are usage scenarios and trigger phrases clearly stated?
- Is "when to use" information in the description, not in the SKILL.md body?
- Can users find this Skill when searching for related functionality?
- Will the model automatically trigger this Skill in relevant scenarios?

**Pass Criteria**: Description is a "trigger keyword net" containing three parts: function description, usage scenarios, and trigger phrases.

**Bad Example**: `description: Code review tool`
**Good Example**: `description: "Code review. Use when user says 'review my code', 'check this PR', 'audit code quality', 'look for bugs in this code'."`

## 3. Workflow Checklist Check
Ask yourself:
- Is there a clear step-by-step checklist for the model to follow?
- Are critical/blocking nodes marked with ⚠️/⛔ to indicate which steps cannot be skipped?
- Are complex steps broken down into sub-steps?
- Are conditional branches annotated (e.g., (conditional))?
- Does the workflow follow the logical order of how humans would perform the same task?

**Pass Criteria**: Workflow is clear and traceable, critical nodes are explicit, and the model won't execute steps randomly.

## 4. Script Encapsulation Check
Ask yourself:
- Are deterministic operations (like file processing, data querying, format conversion) implemented directly via instructions for the model to recreate each time?
- Are there duplicate code snippets appearing in multiple places?
- Are scripts placed in the scripts/ directory with clear usage instructions?
- Does the model only need to know the script's purpose and parameters, not its implementation details?

**Pass Criteria**: All deterministic operations that don't require AI to rethink each time are encapsulated as scripts.

## 5. Instruction Design Check
Ask yourself:
- Are instructions abstract requirements, or specific guiding questions?
- Does the model know where to focus its attention and what content to analyze?
- Are vague instructions like "pay attention to security issues" or "ensure code quality" avoided?
- Is the "Ask yourself: XXX" format used to guide the model to find answers with specific questions?

**Pass Criteria**: Instructions are specific questions that the model can directly analyze to produce concrete conclusions.

**Bad Example**: `Check if the code violates the Single Responsibility Principle`
**Good Example**: `Ask yourself: How many different reasons for modification does this module have? If more than one, it may violate SRP.`

## 6. Confirmation Node Check
Ask yourself:
- Are there user confirmation nodes before critical operations involving generation, modification, or deletion?
- Is the model prevented from executing fully automatically without user intervention?
- Is there a preference setup node for first-time use?
- Do critical parameters require user confirmation rather than using default values directly?

**Pass Criteria**: Confirmation nodes are required before critical operations, and the model cannot perform unwanted operations without user approval.

## 7. Pre-Delivery Checklist Check
Ask yourself:
- Do output-focused Skills have a Pre-Delivery Checklist?
- Are checklist items specific and verifiable, not vague requirements?
- Is there an issue priority classification standard (e.g., P0-P3)?
- Does the model know how to judge the severity of issues?

**Pass Criteria**: There is a specific delivery checklist with verifiable items and clear priority standards.

**Bad Example**: `Ensure good accessibility`
**Good Example**: `[ ] All images have alt text`

## 8. Parameter System Check
Ask yourself:
- Is a flexible parameter system designed to support users to combine features as needed?
- Are common parameters supported, such as partial operations, phased execution, quick mode?
- Is there an argument-hint in frontmatter to provide parameter suggestions?
- Can users see parameter descriptions when typing /?

**Pass Criteria**: Skill is a configurable tool, not a single-function process that can only run from start to finish.

## 9. References Organization Check
Ask yourself:
- Are references organized by domain rather than being dumped all together?
- Does the model only need to load files relevant to the current scenario, not all references at once?
- Is the references directory only nested one level deep, with all files directly referenced from SKILL.md?
- Is it clearly stated when each reference file should be loaded?

**Pass Criteria**: Organized by domain, loaded on demand, with clear structure.

## 10. Overall Design Check
Ask yourself:
- Does this Skill's design follow the three principles of "save, accurate, stable"?
  - Save: Does it minimize context space usage?
  - Accurate: Are instructions precise so the model knows what to do?
  - Stable: Is output consistent and as expected?
- Is there over-engineering with unnecessary features added?
- Are there areas that could be simplified?