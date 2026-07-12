BINARY="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)/claude-profiles"

setup_dirs() {
  CLAUDE_PROFILES_DIR="$(mktemp -d)"
  CLAUDE_DIR="$(mktemp -d)"
  CLAUDE_JSON="$(mktemp)"
  export CLAUDE_PROFILES_DIR CLAUDE_DIR CLAUDE_JSON
  mkdir -p "$CLAUDE_PROFILES_DIR/profiles"
  mkdir -p "$CLAUDE_PROFILES_DIR/shared"
  echo '{"mcpServers":{}}' > "$CLAUDE_JSON"
}

teardown_dirs() {
  rm -rf "$CLAUDE_PROFILES_DIR" "$CLAUDE_DIR"
  rm -f "$CLAUDE_JSON"
}
