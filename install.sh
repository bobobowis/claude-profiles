#!/usr/bin/env bash
set -euo pipefail

REPO="bobobowis/claude-profiles"
INSTALL_DIR="${CLAUDE_PROFILES_INSTALL_DIR:-/usr/local/bin}"
BINARY="claude-profiles"
RAW_URL="https://raw.githubusercontent.com/$REPO/main/$BINARY"

echo "Installing claude-profiles..."

if ! curl -fsSL "$RAW_URL" -o "/tmp/$BINARY"; then
  echo "Download failed. Check your connection or the repo URL."
  exit 1
fi

chmod +x "/tmp/$BINARY"

if [ -w "$INSTALL_DIR" ]; then
  mv "/tmp/$BINARY" "$INSTALL_DIR/$BINARY"
else
  echo "Need sudo to write to $INSTALL_DIR"
  sudo mv "/tmp/$BINARY" "$INSTALL_DIR/$BINARY"
fi

echo "Installed: $INSTALL_DIR/$BINARY"
echo ""
echo "Get started:"
echo "  claude-profiles init brain"
echo "  claude-profiles use brain"
echo "  claude-profiles list"
echo ""
echo "Enable shell completion:"
echo "  bash:  echo 'eval \"\$(claude-profiles --completion-bash)\"' >> ~/.bashrc"
echo "  zsh:   echo 'eval \"\$(claude-profiles --completion-zsh)\"'  >> ~/.zshrc"
