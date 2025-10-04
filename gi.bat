@echo off
setlocal
chcp 65001 >nul

REM ─────────────────────────────────────────────────────────────
REM  Git reflog 화살표 선택 → git reset --hard <hash> 복구 도구
REM ─────────────────────────────────────────────────────────────

where git >nul 2>&1 || (
  echo [오류] Git이 설치되어 있지 않거나 PATH에 없습니다.
  exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>&1 || (
  echo [오류] 현재 디렉터리는 Git 저장소가 아닙니다.
  exit /b 1
)

REM PowerShell 스크립트 실행
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0gi.ps1"

set ps_exit=%ERRORLEVEL%

if %ps_exit% NEQ 0 (
  if %ps_exit% EQU 2 (
    echo [안내] 처리 가능한 reflog 항목이 없어서 종료합니다.
  ) else (
    echo [오류] PowerShell 실행 중 문제가 발생했습니다. 코드 %ps_exit%
  )
)
endlocal
