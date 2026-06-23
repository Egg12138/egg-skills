---
name: vibenotes
description: according to previous talkings, write learning notes for both beginer and experts into target location
allowed-tools: Read,Find,Write,Grep,Edit,Bash,AskUserQuestion
---

# Code & Concept Explanation Skill

Educational explanations with adaptive depth and format.

## Quick Start

```bash
# vibenote with specifying note target location
/vibenote  --dir ~/source/vibenotes
```

## Behavioral Flow

1. **Summary** - Based on memory, summary a theme
2. **Check AND Reorgnize** - According to summary, find what directory current topic belongs to, if not, design a big category, and current topic should be under this category. If there is some files about current topic, consider is it needed to relocate them:
>> if previous notes are a single file, try to mkdir to store new notes and the previous notes with the same topic
3. **File Handling**: create directory, or touch file if needed
4. **Write** - Write output to target file, extension is .md
> each markdown needs a [toc]
> If current source code workspace is a git repo, add footer comment about current  version (priority tag > remote branch > commit hash) and timestamp

## Flag

Without flags, just do as what user said.
With flag, consider:

`--org`, `--root-dir`, `--dir`, `--commit`, `--compact <TOPIC>`, `--update <note>`

`--org`: this is an option toggling vibenote skill to check and relocation vibenotes:
1. make sure files of same topic are not spread everywhere, assemble them in a directory
2. try to rename some directory or file, to make their name more exact 
3. notice, you need only read [toc] of each .md, for saving token and efficiency
4. relocation principle: is not necessary, keep unchanged
5. symlink relocation: sometimes some notes can be subitem of different parts, use symlink to mark them.

`--update <note>`: update content of note file <note>:  but this could be a fuzzy maching if <note> file is not found.

`--root-dir: default to be ~/source/vibenotes`, is --root-dir is given, consider vibenote root directory as the target directory
`--dir`: specific a subdir under the root directory, fuzz name, mainly about "topic"
`--commit`: generate commit message for current newly-added notes in vibenote repo:
1. commit unit is about "TOPIC"
2. add files created by current vibenote sessions and about the same topic
3. add hunks(if necessary) about our current TOPIC. for example: vibenotes repo has file X, containing unstaged content about TopicA and TopicB, and our current vibenote topic is also about TopicA. We can simply add (best effort) all hunks about TopicA in fileX. leaving TopicB not added

`--compact <TOPIC>`

1. argument <TOPIC> is necassary, if empty, analyse topic first, `AskUserQuestion` for #what topic should be compacted, #topic should be more coarse-grained #topic should be more fine-grained or #not to compact; 
2. after TOPIC is given, find notes about the topic, read them and give options to use, `AskUserQuestion` "which level of compact do you want?" (4options: light/medium/deep/Show partition breakdown first, mutual exclusively)
3. generated compacted notes and explain its partitions (where does this part from from?)
4. if user accepet the compacted notes, move raw notes into vibenotes directory .archive/
5. principles:
light/meidum level compact should try best to not lose information; make expression simpler, remove redundant expression are the keys;

format of topic question
```
{
  "questions": [
    {
      "question": "Which topic would you like to compact? Or do you want a coarse-grained or fine-grained topic?",
      "header": "Compact Topic",
      "options": [
        { "label": "fine-grained", "description": "More Brief Topics List" },
        { "label": "coarse-grained", "description": "More Detailed Topics List" },
        {
            "label": "<TOPIC>", "description": "<DESRIPTION>"
        },...
      ],
      "multiSelect": true
    }
  ]
}
```

