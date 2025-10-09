$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ''
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host ' Git Reflog Recovery Tool' -ForegroundColor Cyan
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host ''

# Get reflog entries
$raw = git reflog --date=iso --format='%h|%gd|%cd|%gs' | Select-Object -First 10

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

# Arrow key selection UI
$index = 0
$max = $entries.Count - 1
$pageSize = [Math]::Min(15, $entries.Count)

[Console]::CursorVisible = $false

try {
  while($true) {
    Clear-Host

    Write-Host ''
    Write-Host '==================================================' -ForegroundColor Cyan
    Write-Host ' Git Reflog Recovery Tool' -ForegroundColor Cyan
    Write-Host '==================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Use UP/DOWN arrows to select, ENTER to confirm, ESC to cancel' -ForegroundColor DarkGray
    Write-Host ''

    # Calculate visible range
    $start = [Math]::Max(0, [Math]::Min($index - [int]($pageSize/2), $max - $pageSize + 1))
    $end = [Math]::Min($start + $pageSize - 1, $max)

    # Display commits
    for($i=$start; $i -le $end; $i++) {
      $e = $entries[$i]
      $num = '{0,3}' -f $i

      if($i -eq $index) {
        # Selected item
        Write-Host '  > ' -NoNewline -ForegroundColor Green
        Write-Host "[$num]  " -NoNewline -ForegroundColor White
        Write-Host "$($e.Sel)  " -NoNewline -ForegroundColor Cyan
        Write-Host "$($e.Date)  " -NoNewline -ForegroundColor White
        Write-Host "$($e.Hash)  " -NoNewline -ForegroundColor Yellow
        Write-Host "$($e.Msg)" -ForegroundColor White
      } else {
        # Normal item
        Write-Host '    ' -NoNewline
        Write-Host "[$num]  " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($e.Sel)  " -NoNewline -ForegroundColor DarkCyan
        Write-Host "$($e.Date)  " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($e.Hash)  " -NoNewline -ForegroundColor DarkYellow
        Write-Host "$($e.Msg)" -ForegroundColor Gray
      }
    }

    Write-Host ''
    Write-Host '-------------------------------------------------' -ForegroundColor DarkGray
    Write-Host ''

    # Read key
    $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

    switch($key.VirtualKeyCode) {
      38 { # Up arrow
        if($index -gt 0) { $index-- }
      }
      40 { # Down arrow
        if($index -lt $max) { $index++ }
      }
      13 { # Enter
        break
      }
      27 { # Escape
        [Console]::CursorVisible = $true
        Write-Host '[CANCELED] Operation aborted.' -ForegroundColor Yellow
        exit 0
      }
    }

    if($key.VirtualKeyCode -eq 13) { break }
  }
} finally {
  [Console]::CursorVisible = $true
}

Clear-Host

$target = $entries[$index]

# Create backup branch
Write-Host ''
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host ' Confirm Reset' -ForegroundColor Cyan
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host ''

$ts = (Get-Date).ToString('yyyyMMddHHmmss')
$backupName = 'backup-before-reflog-restore-' + $ts
git branch $backupName 2>$null | Out-Null
Write-Host "[BACKUP] Current HEAD saved as branch: $backupName" -ForegroundColor Green

# Show selection
Write-Host ''
Write-Host 'Selected commit:' -ForegroundColor Yellow
Write-Host ''
Write-Host "  $($target.Sel)  $($target.Date)" -ForegroundColor Cyan
Write-Host "  -> $($target.Hash)  $($target.Msg)" -ForegroundColor White
Write-Host ''

$confirm = Read-Host 'Are you sure you want to reset --hard to this commit? (y/N)'

if($confirm -notin @('y','Y','yes','YES')) {
  Write-Host ''
  Write-Host '[CANCELED] User aborted operation.' -ForegroundColor Yellow
  exit 0
}

# Execute reset --hard
Write-Host ''
Write-Host "[EXECUTE] git reset --hard $($target.Hash)" -ForegroundColor Magenta
git reset --hard $target.Hash

if($LASTEXITCODE -ne 0) {
  Write-Host ''
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
