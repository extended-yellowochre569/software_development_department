# Claude Code SessionStart hook: Load project context at session start (PowerShell)
# Outputs context information that Claude sees when a session begins

Write-Host "=== Claude Code Software Development Department — Session Context (PS) ==="

# Current branch
$branch = git rev-parse --abbrev-ref HEAD 2>$null
if ($branch) {
    Write-Host "Branch: $branch"

    # Recent commits
    Write-Host ""
    Write-Host "Recent commits:"
    git log --oneline -5 2>$null | ForEach-Object {
        Write-Host "  $_"
    }
}

# Current sprint (find most recent sprint file)
$latestSprint = Get-ChildItem "production/sprints/sprint-*.md" 2>$null | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestSprint) {
    Write-Host ""
    Write-Host "Active sprint: $($latestSprint.BaseName)"
}

# Current milestone
$latestMilestone = Get-ChildItem "production/milestones/*.md" 2>$null | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestMilestone) {
    Write-Host "Active milestone: $($latestMilestone.BaseName)"
}

# Open bug count
$bugCount = 0
$targetDirs = @("tests/playtest", "production")
foreach ($dir in $targetDirs) {
    if (Test-Path $dir) {
        $count = (Get-ChildItem -Path $dir -Filter "BUG-*.md" -Recurse 2>$null).Count
        if ($null -eq $count) { $count = 0 }
        $bugCount += $count
    }
}
if ($bugCount -gt 0) {
    Write-Host "Open bugs: $bugCount"
}

# Code health quick check
if (Test-Path "src") {
    $todoCount = (Select-String -Path "src/*" -Pattern "TODO" -Recurse 2>$null).Count
    $fixmeCount = (Select-String -Path "src/*" -Pattern "FIXME" -Recurse 2>$null).Count
    if ($null -eq $todoCount) { $todoCount = 0 }
    if ($null -eq $fixmeCount) { $fixmeCount = 0 }
    
    if ($todoCount -gt 0 -or $fixmeCount -gt 0) {
        Write-Host ""
        Write-Host "Code health: $todoCount TODOs, $fixmeCount FIXMEs in src/"
    }
}

# --- Active session state recovery ---
$stateFile = "production/session-state/active.md"
if (Test-Path $stateFile) {
    Write-Host ""
    Write-Host "=== ACTIVE SESSION STATE DETECTED ==="
    Write-Host "A previous session left state at: $stateFile"
    Write-Host "Read this file to recover context and continue where you left off."
    Write-Host ""
    Write-Host "Quick summary:"
    Get-Content $stateFile -TotalCount 20 2>$null
    $totalLines = (Get-Content $stateFile 2>$null).Count
    if ($totalLines -gt 20) {
        Write-Host "  ... ($totalLines total lines — read the full file to continue)"
    }
    Write-Host "=== END SESSION STATE PREVIEW ==="
}

Write-Host "==================================="
exit 0
