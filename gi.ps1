$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ''
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host ' Git Reflog Recovery Tool' -ForegroundColor Cyan
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host ''

# Get reflog entries
$raw = git reflog --date=iso --format='%h|%gd|%cd|%gs' | Select-Object -First 50

if(-not $raw) {
  Write-Host '[INFO] No reflog entries found.' -ForegroundColor Yellow
  exit 2
}

# Parse entries
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
  Write-Host '[INFO] No valid reflog entries found.' -ForegroundColor Yellow
  exit 2
}

# Display list
Write-Host 'Available commits:' -ForegroundColor Green
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

# Get user selection
$chosen = -1
while($true) {
  $input = Read-Host "Enter commit number (0-$($entries.Count-1), q=cancel)"

  if($input -eq 'q' -or $input -eq 'Q') {
    Write-Host '[CANCELED] Operation aborted.' -ForegroundColor Yellow
    exit 0
  }

  try {
    $chosen = [int]$input
    if($chosen -ge 0 -and $chosen -lt $entries.Count) {
      break
    } else {
      Write-Host "[ERROR] Please enter a number between 0 and $($entries.Count-1)." -ForegroundColor Red
    }
  } catch {
    Write-Host '[ERROR] Please enter a valid number.' -ForegroundColor Red
  }
}

$target = $entries[$chosen]

# Create backup branch
Write-Host ''
$ts = (Get-Date).ToString('yyyyMMddHHmmss')
$backupName = 'backup-before-reflog-restore-' + $ts
git branch $backupName 2>$null | Out-Null
Write-Host "[BACKUP] Current HEAD saved as branch: $backupName" -ForegroundColor Green

# Confirm
Write-Host ''
Write-Host 'Selected commit:' -ForegroundColor Yellow
Write-Host "  $($target.Sel)  $($target.Date)" -ForegroundColor Cyan
Write-Host "  -> $($target.Hash)  $($target.Msg)" -ForegroundColor White
Write-Host ''

$confirm = Read-Host 'Are you sure you want to reset --hard to this commit? (y/N)'

if($confirm -notin @('y','Y','yes','YES')) {
  Write-Host '[CANCELED] User aborted operation.' -ForegroundColor Yellow
  exit 0
}

# Execute reset --hard
Write-Host ''
Write-Host "[EXECUTE] git reset --hard $($target.Hash)" -ForegroundColor Magenta
git reset --hard $target.Hash

if($LASTEXITCODE -ne 0) {
  Write-Host '[FAILED] Reset operation failed.' -ForegroundColor Red
  exit 1
}

# Show result
Write-Host ''
Write-Host '[COMPLETED] Current HEAD:' -ForegroundColor Green
git log -1 --oneline
Write-Host ''
Write-Host "[INFO] Previous state saved in branch '$backupName'." -ForegroundColor DarkGray
Write-Host "       To restore: git reset --hard $backupName" -ForegroundColor DarkGray
Write-Host ''
