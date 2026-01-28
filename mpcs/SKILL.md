---
name: mpcs
description: Find the Minimal Prerequisite Commit Sets (MPCS) of a feature in Target Commit, in a git repo between StartCommit and TargetCommit(Ahead of start commit)
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---


# Workflow

alias PC as "Prerequisite Commit"
BFS is our principle, once SKILL was called, only collect "ONE-LAYER" of PCs.

For each layer, we start from TargetCommit
0. start from TargetCommit
1. source toolchain env, if needed
2. `make` to build kernel, stderr to `error_<commit>.log`, if needed
3. invoke subagent, use "c-compilation-error-analyse" to summarize `error_<commit>.log`, and wait for its output
4. according to error message, analyse required modifications(e,g: introduction,renaming,removing,refactoring,...)
5. design GOOD git log searching patterns
6. search multi strings in background, waiting for their response
7. use `git show` to read PC candidates, analyse if the candidates is what we need
7. handle response, get PCs
8. check if all "required modifications" in step 4 now can be fit by PCs
9. In one layer, we order PC by date from old the new
10. once checklists done, update MPCS.md, ordered by date

# Analyse rules

we need to analyse three things:
1. build errors => subagent will finished
2. design a greate `git ss` search pattern:
> unique and short, usually with some symbols in sentence like (->, !;), multi-line is good only when there are too many candidates 
3. analyse if the searched pattern fix an error (e.g. the PC define a new variable, which used by TargetCommit)

What is good pattern? see the result:
1. ONE candidate is the best -- we got one shot
2. Date matters, we have to filter commits by date between StartCommit and TargetCommit, which makes candidates less


# Tools

## Flags

--target abcdefg # TargetCommit = abcdefg,
--start cbnm1231 # StartCommit = cbnm1231

--log @logfile # this is a build error log, if --log is given, DO NOT make, you need only do steps3 to steps10

## git ss

In general, we can use `git log -S` to locate the commit where counts of a specific string changed. For efficiency, you need to use `git ss <pattern> <path>` to get output `<full_commit_hash> <commit title> <commit date>` once. 

For example, if you wanna search a removed string `gen->stat` under directory ABC, you can use `git ss "gen->stat" ABC`, you will get output like:
```
ec3ddb160f2f830f9a89cd9dda5d44377311c20d  remove the deprecated .stat field 2026-01-28
dace1ce201ac207b260aaa193d1ef629ddc91b12  add definition of stat field 2020-01-27
```

And you will find ec3ddb160f2f830f9a89cd9dda5d44377311c20d is what you need.


