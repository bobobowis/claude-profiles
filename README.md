# claude-profiles

**Status:** shipped (v0.2)
**Repo:** https://github.com/bobobowis/claude-profiles
**Stack:** bash, Linux/Mac

---

## What it does

Switches Claude Code's active agent context — skills, instructions (CLAUDE.md), rules, agents, output styles, and workflows — without touching global config.

Solves the problem of running Claude across multiple contexts (personal brain, work codebase, side projects) where each needs different skills and different instructions.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/bobobowis/claude-profiles/main/install.sh | bash
```

---

## Commands

| Command | Description |
|---|---|
| `claude-profiles use <name>` | Switch profile — relinks all artifacts and CLAUDE.md |
| `claude-profiles init <name>` | Scaffold new profile with correct folder structure |
| `claude-profiles list` | Show all profiles and which is active |
| `claude-profiles validate [name]` | Check integrity — symlinks, dirs, SKILL.md presence |

---

## Convention

```
~/.agents/
  profiles/
    <name>/
      agents/         # subagent .md files
      rules/          # instruction .md files (supports paths: frontmatter)
      skills/         # skill folders — each contains SKILL.md
      output-styles/  # output style .md files
      workflows/      # workflow .js files
      CLAUDE.md       # (optional) profile instructions
  shared/
    agents/           # always active across all profiles
    rules/
    skills/
    output-styles/
    workflows/
  current -> profiles/<active>
```

### How artifacts map to `~/.claude/`

| Profile subdir | Claude Code dir | Item type |
|---|---|---|
| `agents/` | `~/.claude/agents/` | `.md` files |
| `rules/` | `~/.claude/rules/` | `.md` files (supports `paths:` frontmatter for file-scoped loading) |
| `skills/` | `~/.claude/skills/` | **folders** containing `SKILL.md` |
| `output-styles/` | `~/.claude/output-styles/` | `.md` files |
| `workflows/` | `~/.claude/workflows/` | `.js` files |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | symlinked directly |

Skills link by folder name — invoke as `/skill-name`, not `/profile-skill-name`.

**CLAUDE.md**: if a profile has one, it's symlinked to `~/.claude/CLAUDE.md` on `use`. An existing regular file is backed up as `CLAUDE.md.bak`.

**Shared artifacts** always stay linked. Profile wins on name conflict.

**Symlink tracking**: links are owned/cleaned by checking if their target is inside `~/.agents/` — no naming prefixes needed.

---

## Skill structure

Skills must be folders, not single files:

```
skills/
  classify-inbox/
    SKILL.md          # entrypoint, frontmatter + instructions
    checklist.md      # optional supporting files
```

`SKILL.md` frontmatter:
```markdown
---
description: Classify inbox notes into the knowledge system
disable-model-invocation: true   # user-only (omit to allow Claude auto-invoke)
argument-hint: <note-path>
---
```

---

## Environment variables

| Variable | Default |
|---|---|
| `CLAUDE_PROFILES_DIR` | `~/.agents` |
| `CLAUDE_DIR` | `~/.claude` |

---

## Scope decisions

- **v1:** bash only — Linux/Mac. No Windows.
- **Team sharing:** convention-only. Store profiles in a repo, symlink/copy into `~/.agents/profiles/`.
- **MCP servers:** not managed — configure in `~/.claude.json` (user scope) or `.mcp.json` (project root) per Claude Code spec.

---

## Roadmap

- [ ] `claude-profiles import <path|url>` — pull profile from git repo
- [ ] Shell completion (bash/zsh)
- [ ] Homebrew formula
- [ ] Go rewrite for Windows + richer UX
