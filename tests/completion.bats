#!/usr/bin/env bats
load 'test_helper'

setup()    { setup_dirs; }
teardown() { teardown_dirs; }

@test "--completion-bash outputs bash completion function" {
  run "$BINARY" --completion-bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"_claude_profiles_complete"* ]]
  [[ "$output" == *"complete -F"* ]]
}

@test "--completion-zsh outputs zsh completion function" {
  run "$BINARY" --completion-zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"_claude_profiles"* ]]
  [[ "$output" == *"compdef _claude_profiles"* ]]
}

@test "--completion-bash completes profile names" {
  [[ "$("$BINARY" --completion-bash)" == *'CLAUDE_PROFILES_DIR'* ]]
}
