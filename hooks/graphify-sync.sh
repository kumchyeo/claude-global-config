#!/usr/bin/env bash
# Edit/Write 후 graphify 증분 갱신. post-commit 훅을 이미 쓰면 이 파일은 settings.json에서 빼도 됨.
set -u
ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
[ -d "$ROOT/graphify-out" ] || exit 0
command -v graphify >/dev/null 2>&1 || exit 0
# 디바운스: 30초 내 재실행 방지
STAMP="$ROOT/graphify-out/.last_sync"
if [ -f "$STAMP" ] && [ $(( $(date +%s) - $(stat -c %Y "$STAMP") )) -lt 30 ]; then exit 0; fi
( cd "$ROOT" && graphify update . >/dev/null 2>&1 && touch "$STAMP" ) &
exit 0
