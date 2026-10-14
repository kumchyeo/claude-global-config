# Claude Code 전역 설정 설치 (Windows). bootstrap.ps1 이 호출하거나 install.cmd 더블클릭.
# Windows는 symlink 권한 문제로 복사 방식. 갱신은 SessionStart hook이 pull 후 재실행.
$ErrorActionPreference = "Stop"
$src = $PSScriptRoot
$dst = Join-Path $env:USERPROFILE ".claude"
$ts  = Get-Date -Format "yyyyMMdd-HHmmss"
New-Item -ItemType Directory -Force -Path $dst, "$dst\hooks", "$dst\skills" | Out-Null

# 1. CLAUDE.md
if ((Test-Path "$dst\CLAUDE.md") -and -not (Test-Path "$dst\.managed")) { Copy-Item "$dst\CLAUDE.md" "$dst\CLAUDE.md.bak-$ts" }
Copy-Item "$src\CLAUDE.md" "$dst\CLAUDE.md" -Force

# 2. hooks
Copy-Item "$src\hooks\*.sh" "$dst\hooks\" -Force

# 3. skills — repo에 있는 스킬은 항상 repo 버전으로 덮어씀 (마스터 = repo). repo에 없는 로컬 스킬은 유지.
foreach ($s in Get-ChildItem "$src\skills" -Directory) {
  $t = Join-Path "$dst\skills" $s.Name
  if (Test-Path $t) { Remove-Item $t -Recurse -Force }
  Copy-Item $s.FullName $t -Recurse
}

# 4. settings.json — hooks 블록만 병합
$new = Get-Content "$src\settings.json" -Raw | ConvertFrom-Json
$sp  = "$dst\settings.json"
if (Test-Path $sp) {
  if (-not (Test-Path "$dst\.managed")) { Copy-Item $sp "$sp.bak-$ts" }
  $cur = Get-Content $sp -Raw | ConvertFrom-Json
  if ($cur.PSObject.Properties.Name -contains "hooks") { $cur.hooks = $new.hooks }
  else { $cur | Add-Member -NotePropertyName hooks -NotePropertyValue $new.hooks }
  $cur | ConvertTo-Json -Depth 10 | Set-Content $sp -Encoding UTF8
} else { Copy-Item "$src\settings.json" $sp }

Set-Content "$dst\.managed" "source=$src`ninstalled=$ts"
Write-Host "설치 완료: $dst  (source: $src)"
if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
  Write-Host "주의: bash가 PATH에 없음. hooks(.sh)는 Git Bash 필요. https://git-scm.com"
}
