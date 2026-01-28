---
name: gitmsg
description: Generate and manage localized git commit message rules with interactive configuration, linting scripts, and semantic validation
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

AskUserQuestion is your favorate tools, you are preferred to use it. Always try to AskUserQuestion. Let user prompt only if  AskUserQuestion is not proper.


# Git Message Generator

## Purpose
1. Generate and manage localized git commit message rules with interactive configuration, linting scripts, and semantic validation.
2. Generate a git message using rules managed by gitmsg skill

## Triggers and flags

- `/gitmsg` - No parameter, generate commit message using the default rule (priority: repo default rule > global default rule), use author and email in gitmsg.json (if exists)
- `/gitmsg --default-rule <NAME>` - Set default rule for this repo
- `/gitmsg --default-rule <NAME> -g` - Set default rule for global
- `/gitmsg --rule <NAME> [--author <AUTHOR>]` - Use specific rule with optional author override
- `/gitmsg --new` - Interactive creation of a new message rule
- `/gitmsg --list` list all managed rules, just show dir names under skills/gitmsg/rules, and add (default global) and (default for CWD) after global default rule and repo default rule
- "create git commit message rule"
- "generate commit msg"
- "setup git message linting"

### Quick command shortcuts

To save tokens/time when the user explicitly asks for `/gitmsg --help`, `/gitmsg --list`, or `/gitmsg --set-default <NAME>`, invoke the bundled script rather than re-generating instructions. The script lives at `gen-gitmsg/scripts/gitmsg.sh`, so:

- `/gitmsg --help` → run `./gen-gitmsg/scripts/gitmsg.sh --help`
- `/gitmsg --list` → run `./gen-gitmsg/scripts/gitmsg.sh --list`
- `/gitmsg --set-default <NAME>` → run `./gen-gitmsg/scripts/gitmsg.sh --default-rule <NAME>` (or `gitmsg --default-rule <NAME>` when already inside the script)

These direct script invocations let the model answer immediately using the script output instead of explaining the process step-by-step.

## Inputs when creating a new rule
- **Rule name**: Identifier for the rule (e.g., Linux, Kpatch, Personal)
- **Rule description**: Natural language description with examples (multi-line input supported)
- **Author metadata**: Optional author name and email (from ~/.gitconfig or manual input)
- **Linting preference**: Whether to generate lint rules
- **Interactive mode**: Whether the rule requires interactive prompts

## Steps

### For `/gitmsg --new` (Interactive Rule Creation):

Ask User pararallel below:

1. **Ask for rule description**
   - Prompt: "Please provide your git rule description in natural language. You may include examples."
   - Parse existing CI/git-msg configs if provided

2. **Ask for rule name**
   - Prompt: "Name this rule"
   - Validate: alphanumeric + hyphen/underscore only

3. **Ask for author/email storage**
   - Use AskUserQuestion:
     ```
     Store default author and email for this rule?
     [From ~/.gitconfig] - Auto-fill from git config
     [Manual input] - Enter author and email manually
     [Not stored] - Prompt on each commit
     ```
   - If "From ~/.gitconfig" or "Manual input" selected:
     - Toggle: "Store author?"
     - Toggle: "Store email?"

4. **Ask for lint rule generation**
   - Prompt: "Generate lint rule for this rule? (saved to skills/gitmsg/rules/<RULE_NAME>/)"

5. **Ask for interactive mode**
   - Prompt: "Should this rule requires interactive prompts by default when generating a new commit message use the rule?"

6. **Generate rule structure**
   - Create `skills/gitmsg/rules/<RULE_NAME>/`
   - Write rule metadata, templates, validation scripts

Finally, **Check for duplicates**
   - Search in `skills/gitmsg/rules/<RULE_NAME>/`
   - If duplicate found, use AskUserQuestion:
     ```
     A rule named "{name}" already exists. What would you like to do?
     [Override it(dangerous)] - Replace existing rule with this one
     [Rename mine] - Choose a different name for the new rule
     ```

     **Handle rename loop**
   - If "Rename mine" chosen, prompt for new name
   - After 2 rename attempts, auto-suffix with `-<id>` to prevent infinite rename logic


### For `/gitmsg` (Message Generation):

1. Load rule (default or specified)
2. Check author/email configuration
3. If interactive mode: prompt for required fields using AskUserQuestion
4. Generate commit message following rule pattern
> if git commit generation related skills was triggered, invoke them and use their commit message body as content
> else, read modifications (fallback order:staged only > tracked modified only > no  any tracked was modified, AskQuestion: do you wanna gen commit message for all these  untracked new files?)
5. Apply linting if enabled
6. Store metadata (author, email)

### For `/gitmsg --default-rule <NAME>`:

1. Validate rule exists
if not `-g`:
2+. Update `.gitmsg.json` with default rule
if with `-g`:
2+. override `skills/gitmsg/default_rule` with default rule
3. Skill self-update to reflect new default

## Outputs

### Generated Rule Dir Structure:
```
skills/gitmsg/rules/<RULE_NAME>/
├── rule.md              # Ignore it when generating commit message
├── rule.json            # Machine-readable rule config, read it ONLY AFTER lint failed.
├── pattern.yaml         # Regex/pattern definitions for linting
├── template.md          # Commit message template
├── lint.sh              # Linting script
├── metadata.json        # Author, email, created_at, version
└── examples_good.md    # Good commit message examples 
```

### Commit Message Output:

**What to read only**: lint.sh, and rule.json(when message failed)

- Formatted commit message following the rule
- Metadata stored in `.claude/gitmsg-history.json`
- Lint results (pass/fail with details)

## Refusal & Escalation
- Refuse to create rules that conflict with security policies
- Escalate if git config cannot be read and manual input fails
- Refuse to overwrite existing rules without explicit user confirmation

## Evaluation Checklist
- ✓ Rule name is valid and unique (or user confirmed override)
- ✓ Author/email are properly configured or marked as prompt-required 
- ✓ Linting script is executable and produces valid exit codes if required linting
- ✓ Template contains all required placeholders (e.g., {scope}, {subject})
- ✓ Examples demonstrate both compliance and violations
- ✓ Metadata.json contains created_at timestamp and version

## Internal Commands

### When user runs `/gitmsg --new`:
You MUST use AskUserQuestion for all branching decisions. Example:
```python
AskUserQuestion(
    questions=[
        {
            "question": "A rule named 'RTOS' already exists. What would you like to do?",
            "header": "Duplicate",
            "options": [
                {"label": "Override it", "description": "Replace existing rule with this one"},
                {"label": "Rename mine", "description": "Choose a different name for the new rule"}
            ],
            "multiSelect": False
        }
    ]
)
```

### When parsing multi-line rule descriptions:
Accept input until user signals completion (e.g., empty line or EOF marker).

### When reading ~/.gitconfig:
Parse user.name and user.email fields. Handle missing values gracefully.
