#!/usr/bin/env bash
# 새 PC 한 줄 설치 (Linux/macOS):
#   curl -fsSL https://raw.githubusercontent.com/kumchyeo/claude-global-config/main/bootstrap.sh | bash
# 또는:  REPO_URL=git@github.com:kumchyeo/claude-global-config.git bash bootstrap.sh
set -euo pipefail
REPO_URL="${REPO_URL:-https://github.com/kumchyeo/claude-global-config.git}"
DIR="$HOME/.claude-config"
if [ -d "$DIR/.git" ]; then
  git -C "$DIR" pull --ff-only
else
  git clone "$REPO_URL" "$DIR"
fi
bash "$DIR/install.sh"
