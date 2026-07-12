#!/usr/bin/env bats
load 'test_helper'

setup()    { setup_dirs; }
teardown() { teardown_dirs; }

@test "init creates profile directory structure" {
  run "$BINARY" init brain
  [ "$status" -eq 0 ]
  [ -d "$CLAUDE_PROFILES_DIR/profiles/brain/agents" ]
  [ -d "$CLAUDE_PROFILES_DIR/profiles/brain/rules" ]
  [ -d "$CLAUDE_PROFILES_DIR/profiles/brain/skills" ]
  [ -d "$CLAUDE_PROFILES_DIR/profiles/brain/output-styles" ]
  [ -d "$CLAUDE_PROFILES_DIR/profiles/brain/workflows" ]
}

@test "init creates CLAUDE.md" {
  run "$BINARY" init brain
  [ "$status" -eq 0 ]
  [ -f "$CLAUDE_PROFILES_DIR/profiles/brain/CLAUDE.md" ]
}

@test "init creates mcp.json with mcpServers key" {
  "$BINARY" init brain
  run python3 -c "
import json
d = json.load(open('$CLAUDE_PROFILES_DIR/profiles/brain/mcp.json'))
assert 'mcpServers' in d
"
  [ "$status" -eq 0 ]
}

@test "init fails if profile already exists" {
  "$BINARY" init brain
  run "$BINARY" init brain
  [ "$status" -ne 0 ]
}

@test "init requires a name" {
  run "$BINARY" init
  [ "$status" -ne 0 ]
}
