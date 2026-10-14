# 새 PC 한 줄 설치 (Windows PowerShell) — git 없으면 winget으로 자동 설치, 로그인 불필요(public repo):
#   irm https://raw.githubusercontent.com/kumchyeo/claude-global-config/main/bootstrap.ps1 | iex
$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/kumchyeo/claude-global-config.git"
$Dir = Join-Path $env:USERPROFILE ".claude-config"

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
  if (Test-Path "$env:ProgramFiles\Git\cmd") { $env:Path += ";$env:ProgramFiles\Git\cmd" }
}
Refresh-Path
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "git 없음 → winget으로 설치"
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw "winget 없음. Microsoft Store에서 '앱 설치 관리자' 설치 후 재실행" }
  winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
  Refresh-Path
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git 설치됨. PowerShell을 새로 열어 같은 명령을 다시 실행" }
}

if (Test-Path "$Dir\.git") { git -C $Dir pull --ff-only } else { git clone $RepoUrl $Dir }
& "$Dir\install.ps1"
