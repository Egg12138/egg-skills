# Linux Kernel-Style Commit Message Rule

## Overview

Standard Linux kernel commit message format as documented in
`Documentation/process/submitting-patches.rst`.

## Format

```
<component>: <subject>

<paragraph explaining what and why>

<optional additional paragraphs>

<trailers if any>
```

## Rules

1. **Subject Line**: `<component>: <summary in imperative mood>`
   - Max 70 characters
   - No period at the end
   - Use imperative mood ("fix", "add", not "fixes", "added")
   - Component should be lowercase with hyphens/numbers allowed

2. **Body**: Explain **what** and **why**, not **how**
   - Wrap at 72 characters
   - Blank line between subject and body
   - Use present tense

3. **Trailers**: Use standard format at the end
   - `Fixes: <hash> ("<summary>")`
   - `Cc: <person>`
   - `Reported-by: <person>`
   - `Tested-by: <person>`
   - `Reviewed-by: <person>`
   - `Signed-off-by: <person>`
   - `Acked-by: <person>`
   - `Suggested-by: <person>`

## Examples

### Good Example
```
driver: fix NULL pointer dereference in probe()

The driver was not checking if the device structure was allocated
before accessing its fields, leading to a crash when the device
ID was not found in the match table.

Fixes: a1b2c3d4 ("driver: add support for new hardware")
Reported-by: User Name <user@example.com>
Tested-by: Tester <tester@example.com>
```

### Good Example (Simple)
```
docs: update getting started guide

Added new section on installation for Windows users.
```

### Bad Examples
```
❌ Fixed the bug
❌ driver: Fixed NULL pointer.
❌ Added new feature that does X, Y, Z and is very long and exceeds the character limit
❌ component: Mixed case component name
```
