#!/usr/bin/env bats
load 'test_helper'

setup() {
  setup_dirs
  "$BINARY" init brain >/dev/null
  echo "# agent" > "$CLAUDE_PROFILES_DIR/profiles/brain/agents/test-agent.md"
  "$BINARY" use brain >/dev/null
}

teardown() { teardown_dirs; }

@test "revert exits 0" {
  run "$BINARY" revert
  [ "$status" -eq 0 ]
}

@test "revert removes managed symlinks" {
  "$BINARY" revert
  [ ! -L "$CLAUDE_DIR/agents/test-agent.md" ]
}

@test "revert removes current symlink" {
  "$BINARY" revert
  [ ! -L "$CLAUDE_PROFILES_DIR/current" ]
}

@test "revert removes CLAUDE.md symlink" {
  "$BINARY" revert
  [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]
}

@test "revert restores CLAUDE.md from backup" {
  # Start fresh — no existing use from setup's perspective
  # Manually place a regular CLAUDE.md, then use will back it up
  setup_dirs
  echo "original content" > "$CLAUDE_DIR/CLAUDE.md"
  "$BINARY" init myprofile >/dev/null
  "$BINARY" use myprofile >/dev/null
  [ -f "$CLAUDE_DIR/CLAUDE.md.bak" ]
  "$BINARY" revert
  [ -f "$CLAUDE_DIR/CLAUDE.md" ]
  grep -q "original content" "$CLAUDE_DIR/CLAUDE.md"
}
