# 이 폴더를 git repo로 만들고 GitHub private repo에 올림 (최초 1회, 현재 PC에서).
# 필요: git, gh (GitHub CLI). gh 없으면 수동 절차 출력.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git 없음. winget install Git.Git 후 재실행" }
if (-not (Test-Path ".git")) { git init -b main | Out-Null }
if (-not (git config user.email)) { git config user.email "wlsl3408@gmail.com"; git config user.name "J" }
git add -A
git commit -m "claude global config" 2>$null | Out-Null

# PATH 갱신 (설치 직후 같은 창에서도 gh 찾도록) + 기본 설치 경로 보강
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
foreach ($p in "$env:ProgramFiles\GitHub CLI", "$env:LOCALAPPDATA\Programs\GitHub CLI") {
  if (Test-Path "$p\gh.exe") { $env:Path += ";$p" }
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Host "gh(GitHub CLI) 없음. winget install GitHub.cli 후 재실행하거나,"
  Write-Host "https://github.com/new 에서 private repo claude-global-config 생성 후:"
  Write-Host "  git remote add origin https://github.com/<USER>/claude-global-config.git"
  Write-Host "  git push -u origin main"
  pause; exit 1
}

$ErrorActionPreference = "Continue"
cmd /c "gh auth status >nul 2>&1"
if ($LASTEXITCODE -ne 0) {
  gh auth login --hostname github.com --git-protocol https --web
  if ($LASTEXITCODE -ne 0) { Write-Host "GitHub 로그인 실패"; pause; exit 1 }
}
$ErrorActionPreference = "Stop"
$user = (gh api user -q .login).Trim()
if (-not $user) { Write-Host "GitHub 사용자 조회 실패"; pause; exit 1 }

$hasOrigin = (git remote) -contains "origin"
if (-not $hasOrigin) {
  gh repo create claude-global-config --private --source . --remote origin --push
} else {
  git push -u origin main
}

# GITHUB_USER 자리표시자 치환 (UTF-8 BOM 유지)
$utf8bom = New-Object System.Text.UTF8Encoding $true
foreach ($f in "bootstrap.sh", "bootstrap.ps1", "README.md") {
  $t = [IO.File]::ReadAllText((Join-Path $PSScriptRoot $f)) -replace "GITHUB_USER", $user
  if ($f -like "*.sh") { [IO.File]::WriteAllText((Join-Path $PSScriptRoot $f), $t, (New-Object System.Text.UTF8Encoding $false)) }
  else { [IO.File]::WriteAllText((Join-Path $PSScriptRoot $f), $t, $utf8bom) }
}
git add -A
git commit -m "set github user" 2>$null | Out-Null
git push

# 이 PC도 repo 기준으로 전환 (~/.claude-config clone → 재설치)
$env:REPO_URL = "https://github.com/$user/claude-global-config.git"
& (Join-Path $PSScriptRoot "bootstrap.ps1")

Write-Host ""
Write-Host "완료: https://github.com/$user/claude-global-config"
Write-Host "다른 PC 설치 한 줄:"
Write-Host "  Linux/mac : curl -fsSL https://raw.githubusercontent.com/$user/claude-global-config/main/bootstrap.sh | bash"
Write-Host "  Windows   : irm https://raw.githubusercontent.com/$user/claude-global-config/main/bootstrap.ps1 | iex"
Write-Host ""
pause
