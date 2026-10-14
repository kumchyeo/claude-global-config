# claude-global-config

Claude Code 전역 설정(CLAUDE.md · hooks · skills)을 모든 PC에 동일하게 배포·자동 갱신.

## 새 PC 설치 (한 줄)
```
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/kumchyeo/claude-global-config/main/bootstrap.sh | bash
# Windows PowerShell
irm https://raw.githubusercontent.com/kumchyeo/claude-global-config/main/bootstrap.ps1 | iex
```
repo가 `~/.claude-config`에 clone되고 `~/.claude`에 설치됨 (Linux/mac: symlink, Windows: 복사).

## 자동 갱신
SessionStart hook이 하루 1회 `git pull` → 변경 시 자동 재설치. `~/.claude/CLAUDE.md`가 사라지면 재설치.

## 수정 방법
마스터는 이 repo 하나. `~/.claude/` 안을 직접 고치지 말고 `~/.claude-config/`에서 고치고 commit → push.
다른 PC는 다음 세션 시작 때 자동 반영.

## 구성
- `CLAUDE.md` 전역 규칙 (탐색·중복 방지·위임 루프·물리 작업 증명·멀티모델)
- `settings.json` hooks 블록 (기존 settings와 병합)
- `hooks/` session-start(동기화+컨텍스트 주입) · graphify-sync · session-stop
- `skills/` 업무별 매뉴얼 폴더 (`_template`, `robot-eval-campaign`)
- `claude-desktop-project-instructions.md` Claude Desktop Project 지침용

## 최초 publish (현재 PC)
`publish.cmd` 더블클릭 → GitHub private repo 생성·push·kumchyeo 자동 치환. (gh CLI 필요)
