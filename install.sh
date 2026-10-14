#!/usr/bin/env bash
# Linux/macOS 설치. repo를 ~/.claude-config 에 두고 ~/.claude 에 symlink.
# 사용: bash install.sh   (repo 안에서 실행하거나, bootstrap.sh 가 호출)
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST="$HOME/.claude"
TS="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DST/hooks" "$DST/skills"

link() { # link <src> <dst>  — 기존 일반 파일/폴더는 .bak 으로
  local s="$1" d="$2"
  if [ -L "$d" ]; then rm "$d"
  elif [ -e "$d" ]; then mv "$d" "$d.bak-$TS"; fi
  ln -s "$s" "$d"
}

link "$SRC/CLAUDE.md" "$DST/CLAUDE.md"
for h in "$SRC"/hooks/*.sh; do chmod +x "$h"; link "$h" "$DST/hooks/$(basename "$h")"; done
for s in "$SRC"/skills/*/; do s="${s%/}"; link "$s" "$DST/skills/$(basename "$s")"; done

# settings.json: hooks 블록만 병합 (python3 or jq)
SP="$DST/settings.json"
if [ -f "$SP" ]; then cp "$SP" "$SP.bak-$TS"; else echo '{}' > "$SP"; fi
if command -v python3 >/dev/null; then
python3 - "$SP" "$SRC/settings.json" <<'EOF'
import json,sys
cur=json.load(open(sys.argv[1])); new=json.load(open(sys.argv[2]))
cur["hooks"]=new["hooks"]; json.dump(cur,open(sys.argv[1],"w"),indent=2,ensure_ascii=False)
EOF
elif command -v jq >/dev/null; then
  jq -s '.[0] * {hooks: .[1].hooks}' "$SP" "$SRC/settings.json" > "$SP.tmp" && mv "$SP.tmp" "$SP"
else
  cp "$SRC/settings.json" "$SP"; echo "python3/jq 없음: settings.json 통째로 교체됨 (백업: $SP.bak-$TS)"
fi

echo "설치 완료 → $DST (symlink → $SRC)"
ls -la "$DST" | grep -E 'CLAUDE.md|hooks|skills|settings'
