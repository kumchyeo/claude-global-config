#!/usr/bin/env bash
# 새 PC 한 줄 설치 (Linux/macOS) — git 없으면 자동 설치, 로그인 불필요(public repo):
#   curl -fsSL https://raw.githubusercontent.com/kumchyeo/claude-global-config/main/bootstrap.sh | bash
set -euo pipefail
REPO_URL="https://github.com/kumchyeo/claude-global-config.git"
DIR="$HOME/.claude-config"

if ! command -v git >/dev/null 2>&1; then
  echo "git 없음 → 설치"
  if   command -v apt-get >/dev/null; then sudo apt-get update -qq && sudo apt-get install -y git
  elif command -v dnf     >/dev/null; then sudo dnf install -y git
  elif command -v pacman  >/dev/null; then sudo pacman -Sy --noconfirm git
  elif command -v brew    >/dev/null; then brew install git
  elif command -v xcode-select >/dev/null; then xcode-select --install; echo "Xcode CLT 설치 후 재실행"; exit 1
  else echo "패키지 관리자 없음. git 수동 설치 후 재실행"; exit 1; fi
fi

if [ -d "$DIR/.git" ]; then
  git -C "$DIR" pull --ff-only
else
  git clone "$REPO_URL" "$DIR"
fi
bash "$DIR/install.sh"
