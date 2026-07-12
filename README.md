# claude-profiles

**Status:** shipped (v0.3)
**Repo:** https://github.com/bobobowis/claude-profiles
**Stack:** bash, Linux/Mac
**Deps:** `python3` (required for MCP server switching — ships on every Mac/Linux by default)

---

## What it does

Switches Claude Code's active agent context — skills, instructions (CLAUDE.md), rules, agents, output styles, workflows, and MCP servers — without touching global config.

Solves the problem of running Claude across multiple contexts (personal brain, work codebase, side projects) where each needs different tools and different instructions.

---

## Install

**Homebrew (Mac/Linux):**

```bash
brew tap bobobowis/claude-profiles
brew install claude-profiles
```

**curl:**

```bash
curl -fsSL https://raw.githubusercontent.com/bobobowis/claude-profiles/main/install.sh | bash
```

---

## Commands

| Command | Description |
|---|---|
| `claude-profiles use <name>` | Switch profile — relinks artifacts, CLAUDE.md, MCP servers |
| `claude-profiles init <name>` | Scaffold new profile with correct folder structure |
| `claude-profiles list` | Show all profiles, active, and artifact counts |
| `claude-profiles validate [name]` | Check integrity — symlinks, dirs, mcp.json, SKILL.md |
| `claude-profiles revert` | Remove current profile from Claude config, restore clean state |
| `claude-profiles uninstall` | Revert + binary removal instructions |

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
      mcp.json        # (optional) MCP servers for this profile
  shared/
    agents/           # always active across all profiles
    rules/
    skills/
    output-styles/
    workflows/
    mcp.json          # MCP servers always present across all profiles
  current -> profiles/<active>
  .mcp-state.json     # tracks which MCP servers we manage
```

### How artifacts map to `~/.claude/`

| Profile file/dir | Target | Mechanism |
|---|---|---|
| `agents/` | `~/.claude/agents/` | symlinks |
| `rules/` | `~/.claude/rules/` | symlinks (supports `paths:` frontmatter) |
| `skills/` | `~/.claude/skills/` | symlinks (folders containing `SKILL.md`) |
| `output-styles/` | `~/.claude/output-styles/` | symlinks |
| `workflows/` | `~/.claude/workflows/` | symlinks |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | symlink |
| `mcp.json` | `~/.claude.json` `mcpServers` | `python3` patch |

Skills link by folder name — invoke as `/skill-name`.

**Shared artifacts** always stay active. Profile wins on name conflict.

**Symlink tracking**: owned links are identified by target path starting with `~/.agents/` — no naming prefixes.

---

## How it works

Claude Code reads configuration from `~/.claude/` at session start. `claude-profiles` manages that directory with symlinks — it never modifies files directly — plus patches `~/.claude.json` for MCP servers.

### On `claude-profiles use <name>`

1. **Clean** — remove all symlinks in managed `~/.claude/` subdirs whose target is inside `~/.agents/`
2. **Link shared** — symlink everything from `~/.agents/shared/<subdir>/` into `~/.claude/<subdir>/`
3. **Link profile** — symlink everything from `~/.agents/profiles/<name>/<subdir>/` into `~/.claude/<subdir>/` (overrides shared on conflict)
4. **Switch** — update `~/.agents/current` symlink
5. **CLAUDE.md** — if the profile has one, symlink it to `~/.claude/CLAUDE.md` (backs up any existing regular file)
6. **MCP** — remove previously managed MCP servers from `~/.claude.json`, inject merged `shared/mcp.json` + profile `mcp.json` servers

### MCP server management

MCP servers live in `~/.claude.json` (not a directory, so symlinks don't work). `claude-profiles` uses `python3` to patch only the `mcpServers` key:

- **Never touches** pre-existing servers you added yourself
- **Tracks ownership** in `~/.agents/.mcp-state.json`
- On switch: removes previous profile's servers, injects new ones
- If new profile has no `mcp.json`, previous profile's servers are still cleaned
- Requires `python3` (ships on every Mac/Linux — no install needed). Hard fails if missing and `mcp.json` is configured, so you always know MCP didn't switch.
- Takes effect on next Claude Code session start

```json
// ~/.agents/profiles/brain/mcp.json
{
  "mcpServers": {
    "my-brain-tool": {
      "command": "npx",
      "args": ["-y", "@example/brain-mcp"],
      "env": { "API_KEY": "${MY_API_KEY}" }
    }
  }
}
```

### What Claude Code sees after `use`

```
~/.claude/skills/classify-inbox  →  ~/.agents/profiles/brain/skills/classify-inbox/
~/.claude/CLAUDE.md              →  ~/.agents/profiles/brain/CLAUDE.md
~/.claude.json mcpServers        =   { ...user_servers, ...shared, ...profile }
```

No plugin, no hook, no extension — just the filesystem Claude Code already reads.

---

## Skill structure

Skills are folders, not single files:

```
skills/
  classify-inbox/
    SKILL.md          # entrypoint — frontmatter + instructions
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

## Risks and safeguards

### What claude-profiles touches

| Target | How | Safeguard |
|---|---|---|
| `~/.claude/agents/`, `rules/`, `skills/`, `output-styles/`, `workflows/` | Creates/removes symlinks | Only removes symlinks whose target is inside `~/.agents/`. Other tools' symlinks are never touched. |
| `~/.claude/CLAUDE.md` | Replaces with symlink | Backs up existing regular file as `CLAUDE.md.bak` before symlinking. Restored by `revert`. |
| `~/.claude.json` `mcpServers` | `python3` patch — replaces key in-place | Only removes servers it previously added (tracked in `.mcp-state.json`). Pre-existing servers never touched. Writes to a temp file then atomic `os.replace()` — avoids partial writes. |

### What it never touches

- `~/.claude/settings.json`, `keybindings.json`, `themes/`, `projects/` (auto memory)
- Any part of `~/.claude.json` other than `mcpServers`
- Files inside `~/.claude/` subdirs (only creates/removes top-level symlinks)
- Symlinks created by other tools (identified by target path — only absolute paths inside `~/.agents/` are ours)

### Known risks

**Race condition on `~/.claude.json`**: if Claude Code is writing to `~/.claude.json` at the same moment `use` patches it, the `python3` output could be stale. Mitigation: run `use` when Claude Code is not actively running a session. The `mv` from a tempfile is atomic on the same filesystem, so no partial writes.

**`.mcp-state.json` loss**: if `~/.agents/.mcp-state.json` is deleted or corrupted, the next `use` won't know which servers to remove. Managed servers from the previous profile stay in `~/.claude.json` until removed manually or until `revert` is run (which clears based on state file — so if state is gone, MCP servers from the previous profile won't be auto-cleaned). Fix: run `claude-profiles revert` then `claude-profiles use <name>` to reset cleanly.

**`CLAUDE.md.bak` overwrite**: if `CLAUDE.md.bak` already exists (e.g. from a previous backup), it is silently overwritten. If you have a custom `CLAUDE.md` you care about, copy it somewhere safe before first use.

**Relative symlinks from other tools**: our ownership check (`readlink` starts with `~/.agents/`) only catches absolute symlinks we create. Tools that create relative symlinks into `~/.agents/` would not be cleaned. This is intentional — we don't create relative symlinks ourselves.

### Reverting

`claude-profiles revert` removes all managed state from Claude Code without deleting your profiles:

- Removes managed symlinks from `~/.claude/` subdirs
- Restores `~/.claude/CLAUDE.md` from `.bak` if available
- Removes managed MCP servers from `~/.claude.json`
- Deletes `.mcp-state.json` and the `current` symlink
- `~/.agents/` left intact — profiles preserved

`claude-profiles uninstall` does the same then prints binary removal instructions.

---

## Scope decisions

- **v1:** bash only — Linux/Mac. No Windows.
- **Team sharing:** convention-only. Store profiles in a git repo, symlink/copy into `~/.agents/profiles/`.
- **MCP:** patches `~/.claude.json` via `python3`. User-added servers are never touched.

---

## Roadmap

- [ ] `claude-profiles import <path|url>` — pull profile from git repo
- [ ] Shell completion (bash/zsh)
- [x] Homebrew formula
- [ ] Go rewrite for Windows + richer UX
