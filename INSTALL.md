# 설치 (Ubuntu 워크스테이션)

```bash
# 1. 백업
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak 2>/dev/null
cp ~/.claude/settings.json ~/.claude/settings.json.bak 2>/dev/null

# 2. 복사
mkdir -p ~/.claude/hooks ~/.claude/skills
cp CLAUDE.md ~/.claude/CLAUDE.md
cp hooks/*.sh ~/.claude/hooks/ && chmod +x ~/.claude/hooks/*.sh
cp -r skills/_template skills/robot-eval-campaign ~/.claude/skills/

# 3. settings.json — 기존 파일이 있으면 hooks 블록만 병합 (permissions 등 유지)
#    기존 파일 없으면:
cp settings.json ~/.claude/settings.json
```

기존 전역 CLAUDE.md에 다른 내용이 있었으면 `.bak`에서 필요한 줄만 새 파일에 옮기세요.
graphify post-commit 훅을 이미 쓰고 있으면 settings.json의 PostToolUse 블록은 지워도 됩니다.

## Claude Desktop
각 Project의 "프로젝트 지침"에 `claude-desktop-project-instructions.md` 내용을 붙여넣고,
Project 파일에는 해당 업무의 SKILL.md만 업로드 (files/는 올리지 않음).

## 확인
새 터미널에서 아무 git 프로젝트로 가서 `claude` 실행 → 첫 메시지에 `[hook]` 라인이 보이면 정상.
