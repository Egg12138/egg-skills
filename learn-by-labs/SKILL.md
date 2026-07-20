---
name: learn-by-labs
description: design interactive "Learn X by Labs" labs with HTML lectures, makefile hints, and setup git worktree isolation. Use when the user wants to learn a technical topic, design a hands-on course, create a tutorial with experiments, build a coding curriculum, or structure knowledge into modules with labs.This skill is used only to establish an AGENTS.md which explain in details that what the experiemnts should do and what topics the lecture should be.
---

# Learn-by-Labs: Design Interactive Courses with Experiments and HTML Lectures

A content-agnostic methodology for designing hands-on technical courses where learners run real terminal experiments, get progressive hints, and study from a static HTML lecture portal.

## The lifecycle (do NOT skip phases)

```
Phase 1: Blueprint   →  AGENTS.md blueprint chapter + directory skeleton + Makefile
Phase 2: Design      →  AGENTS.md describe intensions of lab scripts/codes + solutions + hints + HTML lectures
Phase 3: Verify      →  AGENTS.md should said that: "run EVERY experiment from scratch, fix everything" ★
Phase 4: Package     →  AGENTS.md should said that: "commit solutions to main, prepare learner worktrees"
```
Note: AGENTS.md should contains a `## PROGRESS` chapter for future agents to record what has been down already.

---

## Phase 1: Blueprint

### 1.1 Understand the domain and the learner

Ask the user these questions, one at a time:
1. **Learning depth**: application-level? protocol/implementation-level? or a mix?
2. **Experiment format**: pure terminal scripts? browser+terminal hybrid?
3. **Organization**: one main topic as spine with subtopics? or并列式 parallel tracks?
4. **Capstone project**: what should the learner build at the end? (a CLI tool? a mini framework? a plugin?)

### 1.2 Decompose into modules

Produce a table of 5-8 sequential modules. Each module covers ONE coherent concept cluster. Order matters — later modules depend on earlier ones.

```
| # | Module | Key topics | Experiment count |
|---|--------|------------|------------------|
```

### 1.3 Bootstrap AGENTS.md

Write `AGENTS.md` with these sections:
- **Project goal**: one paragraph on what this course teaches
- **Target environment**: OS, terminal, shell, tools, browser
- **Learning path**: the module table
- **Directory structure**: the project tree
- **Experiment structure**: lab/ vs solutions/ vs notes.md convention
- **Lecture page anatomy**: the three-chapter design (讲义, 实验指导, 实验)
- **Technical constraints**: no build step, no Docker, static HTML only
- **Key learning objectives**: what the learner should be able to do after each module
- **Capstone deliverables**: what gets built in the final module
- **References**: standards, specs, key reading, source code links
- **The full design paradigm**: paste the paradigm sections from the template (core philosophy, three-chapter design, Makefile, git model, invariants, verification protocol)

### 1.4 Create directory skeleton and Makefile

```
project/
├── AGENTS.md
├── Makefile          # hints, lab, verify, scaffold, check-env, lint, clean, lecture
├── .gitignore        # includes .worktrees/
├── modules/
│   └── NN-topic-name/
│       ├── lab/
│       ├── solutions/
│       └── notes.md
└── lectures/
    ├── index.html
    ├── css/style.css
    └── NN-topic-name.html
```

The Makefile MUST include these targets:
- `check-env` — verify terminal/tools match prerequisites
- `hints` — list all modules
- `hints-MM-XX` — show hints for a specific experiment
- `hints-MM` — show all hints for a module
- `lab-MM-XX` — run a specific experiment
- `verify-MM` — run all labs in a module, diff against solutions, report pass/fail
- `verify-all` — run verify for all modules
- `scaffold-MM-XX-TYPE-NAME` — create new lab+solution skeleton
- `status` — show module completion (lab count vs solution count)
- `lecture` — open the HTML portal
- `lint` — validate scripts
- `clean` — remove artifacts

### 1.5 Git init and initial commit

```bash
git init && git branch -m main
# Create directory structure
git add -A && git commit -m "Initialize X Learning Lab blueprint"
```

Then present the blueprint to the user. Do NOT proceed to Phase 2 until the user confirms the module breakdown is correct.

---

## Phase 2: Design (per module, sequentially)

For each module, follow this exact order:

### 2.1 Write notes.md (module manifest)

```
# Module NN: <title>

## Learning objectives
- ...

## Experiment inventory
| # | Name | Type (sh/py) | Concept |
|---|------|-------------|---------|

## Key terms
- ...

## References
- ...
```

### 2.2 Write the cheat sheet FIRST (Ch2 of HTML)

Before writing any experiment code, fill the cheat sheet table for this module. It must contain every new command, escape sequence, and API the learner will encounter. If you can't fill a dense one-page cheat sheet, the module scope is wrong.

### 2.3 Design experiments from reflection questions backwards

For each experiment:
1. Start with: "What should the learner understand after this?"
2. Write the **reflection question** — this is the most important element. It forces reasoning, not re-running.
3. Design the **lab scaffold** — the bare script the learner will fill in. It should:
   - Be short (10-40 lines)
   - Have clear TODO markers
   - Fail instructively (not crash mysteriously) when run as-is
   - Focus on exactly one concept
4. Write **3 levels of progressive hints**:
   - Level 1: conceptual direction (no code)
   - Level 2: partial structure or key function name
   - Level 3: near-solution (learner fills last 20%)
5. Write the **annotated solution** in `solutions/`. Every non-obvious line gets a brief `# <-- why` comment.

### 2.4 Write the lecture (Ch1 of HTML) LAST

By the time you've designed all experiments, you know exactly what theory the learner needs. The lecture fills gaps — it does NOT duplicate what the experiments teach. Start with a concrete, observable phenomenon.

### 2.5 Write the experiment guide (Ch2 of HTML)

Five fixed sections:
1. **Prerequisites** — specific terminal state/tools/versions
2. **Workflow** — the canonical loop: `read script → predict → run → observe → stuck? hints → reflect`
3. **Cheat sheet** — the table from step 2.2
4. **Common pitfalls** — each with symptom + fix
5. **Debugging tips** — how to inspect raw output (`xxd`, `od -c`, `script`, `strace`)

### 2.6 Build the HTML lecture page

Follow the three-chapter tab structure exactly:

```html
<!-- Top nav: ← Portal | #01 | #02 | ... | #07 → -->
<!-- In-page tabs: [讲义] [实验指导] [实验] -->
<!-- Ch1: lecture text with ASCII diagrams, .escape-seq styling -->
<!-- Ch2: experiment guide with 5 sections -->
<!-- Ch3: experiment cards, each with:
     Objective → Run command → 3-level <details> hints → Expected output → Reflection question -->
```

Style: terminal dark theme. `#1a1b26` background, `#a9b1d6` body, `#7dcfff` links, `#9ece6a` code. Escape sequences use `.escape-seq` class (yellow bg on dark).

### 2.7 Commit with lab-lecture atomicity

Every commit that creates/modifies a lab script MUST update the HTML lecture page in the same commit. Never commit a lab without its lecture update.

---

## Phase 3: Instructor Verification ★ (CRITICAL)

**This phase is the difference between a course that "should work" and one that has been proven to work. Do not skip it.**

### 3.1 The 7-step verification protocol

For each module, execute these steps in order:

1. **Verify from scratch**. Reset to a clean terminal state. Run exactly `make lab-MM-XX` or `./lab/01-experiment.sh`. Do NOT use internal knowledge to "know" it works.

2. **Verify on the matching environment**. If the target is WSL2 + Zellij, verify there — not on macOS or a CI runner.

3. **Verify the failure path first**. Run the bare `lab/` scaffold. It must fail instructively. If it silently succeeds or crashes incomprehensibly, redesign the scaffold.

4. **Verify hints are progressive and correct**. Work through each hint level as a learner would. Level 1 should nudge without spoiling. Level 2 should reveal structure. Level 3 should get to 80%. If a hint gives away the answer, rewrite or demote it.

5. **Verify the solution produces the claimed output**. Run the `solutions/` version. Its output must match exactly what the HTML lecture shows as "Expected output."

6. **Verify cross-module coherence**. When module N builds on module M, re-run module M's key experiments to confirm they still work.

7. **Record verification evidence**. Write `VERIFICATION.md` in the module directory:
   ```markdown
   # Module NN verification
   - Date: YYYY-MM-DD
   - Environment: <OS, terminal, shell version>
   - Results: X/Y experiments pass
   - Quirks: <any environment-specific behavior>
   ```

### 3.2 Fix everything that breaks

If an experiment fails, fix the lab script and re-verify. If a hint is misleading, rewrite it. If the solution output doesn't match the lecture, update one or the other. Do NOT proceed to the next module until the current module passes all 7 steps.

### 3.3 Run `make verify-MM`

Use the Makefile target to automate diff-checking:
```bash
make verify-01   # Verify module 01
make verify-all  # Verify all modules
```

### 3.4 Only then commit solutions to main

Solutions stay as working drafts in the instructor's worktree during verification. They graduate to `main` only after passing verification.

---

## Phase 4: Package for learners

### 4.1 Finalize main

All verified content lives on `main`. This is the canonical, protected branch. Learners read from it but never commit to it.

### 4.2 Create learner worktrees

For each module the learner will work through:
```bash
git worktree add .worktrees/exp-01 -b exp/01-topic-name
```

The learner works in `.worktrees/exp-01/`, isolated from `main`. They can discard the worktree when done without losing reference solutions.

### 4.3 Explain the learner workflow

Tell the learner:
```
1. Open lectures/index.html in your browser
2. Read Ch1 (讲义) for theory, Ch2 (实验指导) for the cheat sheet
3. In your terminal, run: make lab-01-01
4. Try to solve it. If stuck: make hints-01-01
5. Compare with solutions/ when done
6. Reflect on the thinking question
7. Repeat for each experiment
```

---

## The six invariants (enforce these always)

1. **Lab-Lecture atomicity**: same commit, always. No exceptions.
2. **Static HTML only**: `file://` protocol, no bundlers, no frameworks.
3. **Terminal-agnostic experiments**: use terminfo (`tput`) when possible.
4. **Solutions are annotated, not just code**: `# <-- why` on every non-obvious line.
5. **Hints are progressive, not exhaustive**: Level 3 still requires one insight.
6. **Instructor verification before student release**: no unverified solution enters `main`.

---

## Quick-reference: file templates

### Lab scaffold (Bash)
```bash
#!/usr/bin/env bash
# Experiment MM-XX: <title>
set -euo pipefail

# TODO: <what the learner needs to do>
# Hint: make hints-MM-XX
```

### Lab scaffold (Python)
```python
#!/usr/bin/env python3
"""Experiment MM-XX: <title>"""

# TODO: <what the learner needs to do>
# Hint: make hints-MM-XX
```

### Solution (Bash)
```bash
#!/usr/bin/env bash
# SOLUTION: Experiment MM-XX: <title>
set -euo pipefail

# <implementation with # <-- why annotations>
```

### Solution (Python)
```python
#!/usr/bin/env python3
"""SOLUTION: Experiment MM-XX: <title>"""

# <implementation with # <-- why annotations>
```

---

## How the three-chapter lecture page renders

```
┌──────────────────────────────────────────────────┐
│  ← Portal | #01 | #02 | ... | #07 →              │
│  [ 讲义 Lecture ] [ 实验指导 Guide ] [ 实验 Labs ] │
├──────────────────────────────────────────────────┤
│                                                   │
│  Ch1: Theory, ASCII diagrams, protocol dumps      │
│  Ch2: Prereqs, workflow, cheat sheet, pitfalls    │
│  Ch3: Experiment cards with folded hints          │
│                                                   │
└──────────────────────────────────────────────────┘
```

Each experiment card in Ch3:
```
┌─ Experiment 01: <title> ─────────────────────────┐
│  Objective: <one sentence>                        │
│  ▶ Run: ./lab/01-experiment.sh                    │
│  ┌ Hints ────────────────────────────────────┐   │
│  │ <details>Level 1: direction</details>      │   │
│  │ <details>Level 2: structure</details>      │   │
│  │ <details>Level 3: near-solution</details>  │   │
│  └────────────────────────────────────────────┘   │
│  Expected: <ASCII mockup or description>          │
│  Think: <one reflection question>                 │
└───────────────────────────────────────────────────┘
```
