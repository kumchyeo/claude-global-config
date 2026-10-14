#!/usr/bin/env bash
# 세션 종료 시 decisions.md 미기록이면 리마인드.
set -u
ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
F="$ROOT/docs/decisions.md"
mkdir -p "$ROOT/docs"
[ -f "$F" ] || printf '# Decisions\n\n' > "$F"
if [ -z "$(find "$F" -mmin -120 2>/dev/null)" ]; then
  echo "[hook] docs/decisions.md가 2시간 내 갱신되지 않음 → 이번 세션 결정 1~3줄 기록할 것 (전역 규칙 7)"
fi
exit 0
