# claude-global-config

Claude Code 전역 설정(CLAUDE.md · hooks · skills)을 모든 PC에 동일하게 배포·자동 갱신.

## 새 PC 설치 — 한 줄, 로그인 없음, git 없으면 자동 설치

**Linux / macOS**
```bash
curl -fsSL https://raw.githubusercontent.com/kumchyeo/claude-global-config/main/bootstrap.sh | bash
```
**Windows PowerShell**
```powershell
irm https://raw.githubusercontent.com/kumchyeo/claude-global-config/main/bootstrap.ps1 | iex
```
결과: `~/.claude-config`에 clone, `~/.claude`에 설치 (Linux/mac: symlink, Windows: 복사).
이미 설치된 PC에서 다시 실행하면 pull + 재설치만 한다.

## 자동 갱신
SessionStart hook이 하루 1회 `git pull` → 변경 시 자동 재설치. `~/.claude/CLAUDE.md`가 사라져도 재설치.

## 수정 방법
마스터는 이 repo 하나. `~/.claude/`를 직접 고치지 말고 `~/.claude-config/`에서 고치고 commit → push (push에만 GitHub 로그인 필요).
다른 PC는 다음 세션 시작 때 자동 반영.

## 구성
- `CLAUDE.md` 전역 규칙 (탐색·중복 방지·위임 루프·물리 작업 증명·멀티모델)
- `settings.json` hooks 블록 (기존 settings와 병합)
- `hooks/` session-start(동기화+컨텍스트 주입) · graphify-sync · session-stop
- `skills/` 업무별 매뉴얼 폴더 (`_template`, `robot-eval-campaign`)
- `claude-desktop-project-instructions.md` Claude Desktop Project 지침용
- `bootstrap.sh` / `bootstrap.ps1` git 자동 설치 + clone + install
