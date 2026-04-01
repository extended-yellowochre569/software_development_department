---
name: dream
description: Triggers the Memory Consolidation process (Auto-Dream). Reads all memory files in `.claude/memory/`, removes duplicates, merges related files, and ensures `MEMORY.md` stays under the 200-line/25KB limit. Can be run manually or via cron.
argument-hint: "[optional specific topic to consolidate]"
user-invocable: true
allowed-tools: Read, Write, Glob, Bash
effort: 4
when_to_use: "Dọn dẹp và hợp nhất thư mục memory (MEMORY.md và topic files) khi file nhớ quá lớn hoặc dư thừa thông tin"
---

The `/dream` skill acts as the background maintenance worker for Claude's Native Auto-Memory System. Wait until the user approves before proceeding with any file modifications.

## Execution Steps

### 1. Analyze The Memory Directory
1. Read the contents of `.claude/memory/MEMORY.md`. Check if it is approaching the 200-line / 25KB limit.
2. Read the contents of all `.md` files referenced in `MEMORY.md` (the topic files).

### 2. Identify Redundancies & Obsolete Memories
1. Identify any duplicate or overlapping files across the taxonomy (`user`, `feedback`, `project`, `reference`).
2. Spot obsolete constraints or old projects that are no longer relevant.
3. Detect topic files that lack the mandatory YAML frontmatter (name, description, type).

### 3. Consolidate & Rewrite (Dreaming Phase)
1. Merge related files. E.g. if there are `feedback_testing_1.md` and `feedback_testing_2.md`, create a single `feedback_testing_merged.md`.
2. Format each topic file strictly with the frontmatter:
   ```yaml
   ---
   name: [Name]
   description: [One-line summary]
   type: [user|feedback|project|reference]
   ---
   ```
3. Rewrite the `MEMORY.md` index replacing the merged/deleted files with the new ones. Maintain the strictly formatted pointer list: `- [Title](filename.md) - Exact one-line hook`.
4. Delete obsolete files using `rm` via bash command (ensure the user approves first).

### 4. Review & Confirm
Show the user a summary of changes made:
- Files deleted
- Files merged
- New `MEMORY.md` line count and structure

> "The system has successfully consolidated these memories into a more compact state."
