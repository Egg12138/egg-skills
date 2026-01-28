---
name: mpcs-reverse
description: Find the Minimal Prerequisite Commit Sets (MPCS) of a feature in Target Commit, in a git repo between StartCommit and TargetCommit(Ahead of start commit)
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---


# Workflow

BFS is our principle:

For each layer, we start from TargetCommit, seeking for MPCS, from future to past.

0. start from TargetCommit
1. source toolchain env
2. `make` to build kernel, stderr to `error_<commit>.log`
3. invoke subagent, use "c-compilation-error-analyse" to summarize `error_<commit>.log`, and wait for its output
4. use

# Analyse rules

1. ONE candidate is the best -- we got one shot
2. Date matters, we have to filter commits by date between StartCommit and TargetCommit
3. 

# Tools

## git ss

In general, we can use `git log -S` to locate the commit where counts of a specific string changed. For efficiency, you need to use `git ss <pattern> <path>` to get output `<full_commit_hash> <commit title> <commit date>` once. 

For example, if you wanna search a removed string `gen->stat` under directory ABC, you can use `git ss "gen->stat" ABC`, you will get output like:
```
ec3ddb160f2f830f9a89cd9dda5d44377311c20d  remove the deprecated .stat field 2026-01-28
dace1ce201ac207b260aaa193d1ef629ddc91b12  add definition of stat field 2020-01-27
```

And you will find ec3ddb160f2f830f9a89cd9dda5d44377311c20d is what you need.


