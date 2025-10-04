$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ''
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host ' Git Reflog 복구 도구' -ForegroundColor Cyan
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host ''

# reflog 가져오기
$raw = git reflog --date=iso --format='%h|%gd|%cd|%gs' 2>$null | Select-Object -First 50
if(-not $raw) {
  Write-Host '[안내] reflog 기록이 없습니다.' -ForegroundColor Yellow
  exit 2
}

# 파싱
$entries = @()
foreach($line in $raw) {
  $parts = $line -split '\|',4
  if($parts.Count -lt 4) { continue }
  $obj = [pscustomobject]@{
    Hash = $parts[0].Trim()
    Sel  = $parts[1].Trim()
    Date = $parts[2].Trim()
    Msg  = $parts[3].Trim()
  }
  $entries += $obj
}

if($entries.Count -eq 0) {
  Write-Host '[안내] 파싱 가능한 reflog 항목이 없습니다.' -ForegroundColor Yellow
  exit 2
}

# 목록 표시
Write-Host '복구 가능한 커밋 목록:' -ForegroundColor Green
Write-Host ''

for($i=0; $i -lt $entries.Count; $i++) {
  $e = $entries[$i]
  $num = '{0,3}' -f $i
  Write-Host "  [$num]  " -NoNewline -ForegroundColor DarkGray
  Write-Host "$($e.Sel)  " -NoNewline -ForegroundColor Cyan
  Write-Host "$($e.Date)  " -NoNewline -ForegroundColor DarkGray
  Write-Host "$($e.Hash)  " -NoNewline -ForegroundColor Yellow
  Write-Host "$($e.Msg)"
}

Write-Host ''
Write-Host '─────────────────────────────────────────────────' -ForegroundColor DarkGray
Write-Host ''

# 선택 입력
$chosen = -1
while($true) {
  $input = Read-Host "복구할 커밋 번호를 입력하세요 (0-$($entries.Count-1), 취소=q)"

  if($input -eq 'q' -or $input -eq 'Q') {
    Write-Host '[취소됨] 작업을 중단했습니다.' -ForegroundColor Yellow
    exit 0
  }

  try {
    $chosen = [int]$input
    if($chosen -ge 0 -and $chosen -lt $entries.Count) {
      break
    } else {
      Write-Host "[오류] 0에서 $($entries.Count-1) 사이의 숫자를 입력하세요." -ForegroundColor Red
    }
  } catch {
    Write-Host '[오류] 올바른 숫자를 입력하세요.' -ForegroundColor Red
  }
}

$target = $entries[$chosen]

# 백업 브랜치 생성
Write-Host ''
$ts = (Get-Date).ToString('yyyyMMddHHmmss')
$backupName = 'backup-before-reflog-restore-' + $ts
git branch $backupName 2>$null
Write-Host "[백업] 현재 HEAD를 브랜치로 보존: $backupName" -ForegroundColor Green

# 확인
Write-Host ''
Write-Host '선택한 커밋:' -ForegroundColor Yellow
Write-Host "  $($target.Sel)  $($target.Date)" -ForegroundColor Cyan
Write-Host "  → $($target.Hash)  $($target.Msg)" -ForegroundColor White
Write-Host ''

$confirm = Read-Host '정말로 이 커밋으로 하드 리셋하시겠습니까? (y/N)'

if($confirm -notin @('y','Y','yes','YES')) {
  Write-Host '[중단] 사용자가 취소했습니다.' -ForegroundColor Yellow
  exit 0
}

# reset --hard 실행
Write-Host ''
Write-Host "[실행] git reset --hard $($target.Hash)" -ForegroundColor Magenta
git reset --hard $target.Hash

if($LASTEXITCODE -ne 0) {
  Write-Host '[실패] reset 중 오류가 발생했습니다.' -ForegroundColor Red
  exit 1
}

# 결과
Write-Host ''
Write-Host '[완료] 현재 HEAD:' -ForegroundColor Green
git log -1 --oneline
Write-Host ''
Write-Host "[참고] 작업 전 상태는 브랜치 '$backupName' 로 보존되어 있습니다." -ForegroundColor DarkGray
Write-Host "       필요 시 복구: git reset --hard $backupName" -ForegroundColor DarkGray
Write-Host ''
