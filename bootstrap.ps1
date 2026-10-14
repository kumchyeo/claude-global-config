# 새 PC 한 줄 설치 (Windows PowerShell):
#   irm https://raw.githubusercontent.com/GITHUB_USER/claude-global-config/main/bootstrap.ps1 | iex
$ErrorActionPreference = "Stop"
$RepoUrl = if ($env:REPO_URL) { $env:REPO_URL } else { "https://github.com/GITHUB_USER/claude-global-config.git" }
$Dir = Join-Path $env:USERPROFILE ".claude-config"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git 없음. https://git-scm.com 설치 후 재실행" }
if (Test-Path "$Dir\.git") { git -C $Dir pull --ff-only } else { git clone $RepoUrl $Dir }
& "$Dir\install.ps1"
