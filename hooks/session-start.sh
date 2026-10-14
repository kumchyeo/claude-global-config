#!/usr/bin/env bash
# 세션 시작: (1) 설정 repo 자동 pull + 누락 시 재설치 (2) 지난 결정·notes 주입. stdout이 Claude 컨텍스트로 들어감.
set -u
ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
CFG="$HOME/.claude-config"

# (1) 설정 자동 동기화 — 하루 1회만 pull (느려지지 않게), 변경 있으면 재설치
if [ -d "$CFG/.git" ] && command -v git >/dev/null 2>&1; then
  STAMP="$CFG/.last_pull"
  if [ ! -f "$STAMP" ] || [ -n "$(find "$STAMP" -mmin +1440 2>/dev/null)" ]; then
    BEFORE=$(git -C "$CFG" rev-parse HEAD 2>/dev/null)
    timeout 15 git -C "$CFG" pull --ff-only -q 2>/dev/null && touch "$STAMP"
    AFTER=$(git -C "$CFG" rev-parse HEAD 2>/dev/null)
    if [ "$BEFORE" != "$AFTER" ]; then
      echo "[hook] 설정 repo 업데이트됨 ($BEFORE → $AFTER)"
      case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*) powershell -NoProfile -ExecutionPolicy Bypass -File "$CFG/install.ps1" >/dev/null 2>&1 ;;
        *) bash "$CFG/install.sh" >/dev/null 2>&1 ;;
      esac
    fi
  fi
  # 누락 복구 (symlink 깨짐·삭제)
  [ -e "$HOME/.claude/CLAUDE.md" ] || { echo "[hook] CLAUDE.md 누락 → 재설치"; bash "$CFG/install.sh" >/dev/null 2>&1; }
fi

# (2) 컨텍스트 주입
if [ ! -f "$ROOT/CLAUDE.md" ]; then
  echo "[hook] 프로젝트 CLAUDE.md 없음 → 전역 규칙 0-1 (스캔 후 템플릿 생성) 수행할 것"
fi
if [ -f "$ROOT/docs/decisions.md" ]; then
  echo "[hook] 최근 결정 (docs/decisions.md):"; tail -n 10 "$ROOT/docs/decisions.md"
fi
for n in "$ROOT"/.claude/skills/*/notes.md "$HOME"/.claude/skills/*/notes.md; do
  [ -f "$n" ] || continue
  echo "[hook] $(basename "$(dirname "$n")")/notes.md 최근:"; head -n 5 "$n"
done
if [ -d "$ROOT/.git" ] && [ ! -d "$ROOT/graphify-out" ]; then
  echo "[hook] graphify-out/ 없음 → /graphify . 제안"
fi
exit 0
