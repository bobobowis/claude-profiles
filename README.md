# claude-profiles

**Status:** shipped (v0.1)
**Repo:** https://github.com/bobobowis/claude-profiles
**Stack:** bash, Linux/Mac

---

## What it does

Switches Claude Code's active agent context: skills, instructions (CLAUDE.md), and profile metadata — without touching global config.

Solves the problem of running Claude across multiple contexts (personal brain, work codebase, side projects) where each needs different skills and different CLAUDE.md instructions.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/bobobowis/claude-profiles/main/install.sh | bash
```

---

## Commands

| Command | Description |
|---|---|
| `claude-profiles use <name>` | Switch to profile — relinks skills and CLAUDE.md |
| `claude-profiles init <name>` | Scaffold a new profile with correct folder structure |
| `claude-profiles list` | Show all profiles and which is active |
| `claude-profiles validate [name]` | Check profile integrity — symlinks, dirs, CLAUDE.md |

---

## Convention

```
~/.agents/
  profiles/
    <name>/
      agents/       # agent definitions
      mcp/          # MCP server configs
      prompts/      # reusable prompts
      skills/       # .md skill files → linked to ~/.claude/skills/
      templates/    # note/doc templates
      CLAUDE.md     # (optional) profile-level instructions
  shared/
    skills/         # always active across all profiles
  current -> profiles/<active>
```

**Skills** get symlinked to `~/.claude/skills/` with prefixes:
- Profile skills: `profile-<name>.md`
- Shared skills: `shared-<name>.md`

**CLAUDE.md**: if a profile has one, it's symlinked to `~/.claude/CLAUDE.md` on `use`. An existing regular file is backed up as `CLAUDE.md.bak`.

---

## Environment variables

| Variable | Default |
|---|---|
| `CLAUDE_PROFILES_DIR` | `~/.agents` |
| `CLAUDE_SKILLS_DIR` | `~/.claude/skills` |

---

## Scope decisions

- **v1:** bash only — Linux/Mac. No Windows.
- **Team sharing:** convention-only. Teams can store profiles in a repo and symlink/copy into `~/.agents/profiles/`. No `import` command yet.
- **Shared skills** (`~/.agents/shared/skills/`): always linked on top of profile skills on every `use`.

---

## Roadmap

- [ ] `claude-profiles import <path|url>` — pull profile from git repo
- [ ] Shell completion (bash/zsh)
- [ ] Homebrew formula
- [ ] Go rewrite for Windows + richer UX
