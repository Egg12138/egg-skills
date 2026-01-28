# Good Commit Message Examples for Linux Rule

## Example 1: Bug Fix
```
driver: fix NULL pointer dereference in probe()

The driver was not checking if the device structure was allocated
before accessing its fields, leading to a crash when the device
ID was not found in the match table.

Fixes: a1b2c3d4e5f6 ("driver: add support for new hardware")
Reported-by: User Name <user@example.com>
Tested-by: Tester <tester@example.com>
```

## Example 2: New Feature
```
mm: add support for transparent huge pages in swap

This patch extends the swap subsystem to handle transparent huge
pages, reducing memory pressure for workloads with large memory
footprints.

The implementation reuses the existing split page mechanism and
adds a new flag to track THP status in swap entries.

Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Developer <dev@example.com>
```

## Example 3: Documentation
```
docs: update getting started guide

Added new section on installation for Windows users and updated
the prerequisites list to reflect recent changes to the build
system.
```

## Example 4: Refactoring
```
net: simplify packet routing logic

The routing code had accumulated several redundant checks over
time. This patch consolidates the validation into a single helper
function, improving both readability and performance.

No functional changes intended.
```

## Example 5: Simple Fix
```
scripts: fix shellcheck warnings in build script

Addressed SC2086 and SC2155 warnings by proper quoting and
separating variable declaration from usage.
```
