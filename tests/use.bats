#!/usr/bin/env bats
load 'test_helper'

setup() {
  setup_dirs
  "$BINARY" init brain >/dev/null
  echo "# agent" > "$CLAUDE_PROFILES_DIR/profiles/brain/agents/test-agent.md"
  echo "# rule"  > "$CLAUDE_PROFILES_DIR/profiles/brain/rules/test-rule.md"
  mkdir -p "$CLAUDE_PROFILES_DIR/profiles/brain/skills/test-skill"
  echo "---" > "$CLAUDE_PROFILES_DIR/profiles/brain/skills/test-skill/SKILL.md"
}

teardown() { teardown_dirs; }

@test "use switches to existing profile" {
  run "$BINARY" use brain
  [ "$status" -eq 0 ]
}

@test "use sets current symlink" {
  "$BINARY" use brain
  [ -L "$CLAUDE_PROFILES_DIR/current" ]
  [[ "$(readlink "$CLAUDE_PROFILES_DIR/current")" == *"/brain" ]]
}

@test "use symlinks agents" {
  "$BINARY" use brain
  [ -L "$CLAUDE_DIR/agents/test-agent.md" ]
}

@test "use symlinks rules" {
  "$BINARY" use brain
  [ -L "$CLAUDE_DIR/rules/test-rule.md" ]
}

@test "use symlinks skill folder" {
  "$BINARY" use brain
  [ -L "$CLAUDE_DIR/skills/test-skill" ]
}

@test "use symlinks CLAUDE.md" {
  "$BINARY" use brain
  [ -L "$CLAUDE_DIR/CLAUDE.md" ]
}

@test "use fails for nonexistent profile" {
  run "$BINARY" use nonexistent
  [ "$status" -ne 0 ]
}

@test "use cleans up previous profile symlinks when switching" {
  "$BINARY" init work >/dev/null
  echo "# work" > "$CLAUDE_PROFILES_DIR/profiles/work/agents/work-agent.md"
  "$BINARY" use brain >/dev/null
  [ -L "$CLAUDE_DIR/agents/test-agent.md" ]
  "$BINARY" use work >/dev/null
  [ ! -L "$CLAUDE_DIR/agents/test-agent.md" ]
  [ -L "$CLAUDE_DIR/agents/work-agent.md" ]
}

@test "use backs up existing CLAUDE.md and restores on switch" {
  echo "my custom instructions" > "$CLAUDE_DIR/CLAUDE.md"
  "$BINARY" use brain >/dev/null
  [ -f "$CLAUDE_DIR/CLAUDE.md.bak" ]
  grep -q "my custom instructions" "$CLAUDE_DIR/CLAUDE.md.bak"
}
