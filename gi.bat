@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM ─────────────────────────────────────────────────────────────
REM  Git reflog 화살표 선택 → git reset --hard <hash> 복구 도구
REM  사용법: 저장소 루트에서 git-reflog-restore.bat 실행
REM  기능:
REM   • reflog 항목을 위/아래 화살표로 이동, Enter로 선택
REM   • 선택 전 자동 백업 브랜치 생성 (backup-before-reflog-restore-YYYYMMDDHHmmss)
REM   • 선택 커밋으로 git reset --hard 수행
REM ─────────────────────────────────────────────────────────────

where git >nul 2>&1 || (
  echo [오류] Git이 설치되어 있지 않거나 PATH에 없습니다.
  exit /b 1
)

REM 저장소 체크
git rev-parse --is-inside-work-tree >nul 2>&1 || (
  echo [오류] 현재 디렉터리는 Git 저장소가 아닙니다.
  exit /b 1
)

REM PowerShell 기반 TUI 호출
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass ^
  -Command ^
  "$ErrorActionPreference='Stop';" ^
  "[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
  "function Read-ArrowSelection {" ^
  "  param([string[]]`$items, [int]`$startIndex = 0, [string]`$title = 'reflog에서 복구할 지점을 선택하세요 (↑/↓, Enter=확정, Esc=취소)');" ^
  "  if(-not `$items -or `$items.Count -eq 0){ throw '목록이 비어있습니다.' }" ^
  "  `$index = `$startIndex;" ^
  "  `$max = `$items.Count - 1;" ^
  "  `$visible = [Console]::WindowHeight - 4; if(`$visible -lt 5){ `$visible = 10 }" ^
  "  [Console]::CursorVisible = `$false;" ^
  "  try {" ^
  "    while(`$true) {" ^
  "      Clear-Host;" ^
  "      Write-Host `$title;" ^
  "      `$top = [Math]::Max(0, [Math]::Min(`$index - [int]([double]`$visible/2), `$max - `$visible + 1));" ^
  "      `$bottom = [Math]::Min(`$top + `$visible - 1, `$max);" ^
  "      for(`$i=`$top; `$i -le `$bottom; `$i++) {" ^
  "        if(`$i -eq `$index) {" ^
  "          Write-Host ('> ' + `$items[`$i]) -NoNewline;" ^
  "          Write-Host '' -BackgroundColor DarkCyan;" ^
  "        } else {" ^
  "          Write-Host ('  ' + `$items[`$i]);" ^
  "        }" ^
  "      }" ^
  "      `$key = [Console]::ReadKey($true);" ^
  "      switch (`$key.Key) {" ^
  "        'UpArrow'   { if(`$index -gt 0){ `$index-- } }" ^
  "        'DownArrow' { if(`$index -lt `$max){ `$index++ } }" ^
  "        'Enter'     { return `$index }" ^
  "        'Escape'    { return -1 }" ^
  "      }" ^
  "    }" ^
  "  } finally { [Console]::CursorVisible = `$true }" ^
  "}" ^
  "" ^
  "# reflog 가져오기 (짧은 해시, 셀렉터, 날짜, 요약)" ^
  "`$raw = git reflog --date=iso --format='%%h|%%gd|%%cd|%%gs' 2>&1 | Select-Object -First 300" ^
  "if(-not `$raw){ Write-Host '[안내] reflog 기록이 없습니다.'; exit 2 }" ^
  "" ^
  "# 파싱 및 표시용 문자열 구성" ^
  "`$entries = @();" ^
  "foreach(`$line in `$raw) {" ^
  "  `$parts = `$line -split '\|',4;" ^
  "  if(`$parts.Count -lt 4){ continue }" ^
  "  `$obj = [pscustomobject]@{" ^
  "    Hash = `$parts[0].Trim();" ^
  "    Sel  = `$parts[1].Trim();" ^
  "    Date = `$parts[2].Trim();" ^
  "    Msg  = `$parts[3].Trim();" ^
  "  }" ^
  "  `$entries += `$obj" ^
  "}" ^
  "if(`$entries.Count -eq 0){ Write-Host '[안내] 파싱 가능한 reflog 항목이 없습니다.'; exit 2 }" ^
  "" ^
  "# 시각적 목록 문자열(한 줄)" ^
  "`$list = for(`$i=0; `$i -lt `$entries.Count; `$i++) {" ^
  "  `$e = `$entries[`$i];" ^
  "  ('['+('{0,3}' -f `$i)+'] ' + `$e.Sel + ' | ' + `$e.Date + ' | ' + `$e.Hash + ' | ' + `$e.Msg)" ^
  "}" ^
  "" ^
  "# 선택" ^
  "`$chosen = Read-ArrowSelection -items `$list -startIndex 0 -title 'reflog에서 복구할 지점을 선택하세요 (↑/↓ 이동, Enter=확정, Esc=취소)'" ^
  "if(`$chosen -lt 0){ Write-Host '[취소됨] 작업을 중단했습니다.'; exit 0 }" ^
  "`$target = `$entries[`$chosen]" ^
  "" ^
  "# 현재 HEAD 백업 브랜치 생성" ^
  "`$ts = (Get-Date).ToString('yyyyMMddHHmmss')" ^
  "`$backupName = 'backup-before-reflog-restore-' + `$ts" ^
  "git branch `$backupName" ^
  "Write-Host ('[백업] 현재 HEAD를 브랜치로 보존: ' + `$backupName)" ^
  "" ^
  "# 확인" ^
  "Write-Host ''" ^
  "Write-Host ('선택: ' + `$target.Sel + ' ' + `$target.Date)" ^
  "Write-Host ('→ ' + `$target.Hash + ' | ' + `$target.Msg)" ^
  "Write-Host ''" ^
  "Write-Host '정말로 이 커밋으로 하드 리셋하시겠습니까? (y/N) ' -NoNewline;" ^
  "`$ans = (Read-Host)" ^
  "if(`$ans -notin @('y','Y','yes','YES')){ Write-Host '[중단] 사용자가 취소했습니다.'; exit 0 }" ^
  "" ^
  "# reset --hard 실행" ^
  "Write-Host ('[실행] git reset --hard ' + `$target.Hash)" ^
  "git reset --hard `$target.Hash" ^
  "if(`$LASTEXITCODE -ne 0){ Write-Host '[실패] reset 중 오류가 발생했습니다.'; exit 1 }" ^
  "" ^
  "# 결과 표시" ^
  "Write-Host ''" ^
  "Write-Host '[완료] 현재 HEAD:'" ^
  "git log -1 --oneline" ^
  "Write-Host ''" ^
  "Write-Host ('[참고] 작업 전 상태는 브랜치 ' + `$backupName + ' 로 보존되어 있습니다. 필요 시 복구:  git reset --hard ' + `$backupName)" ^
  ""

set ps_exit=%ERRORLEVEL%
if %ps_exit% NEQ 0 (
  if %ps_exit% EQU 2 (
    echo [안내] 처리 가능한 reflog 항목이 없어서 종료합니다.
  ) else (
    echo [오류] PowerShell 실행 중 문제가 발생했습니다. 코드 %ps_exit%
  )
)
endlocal
