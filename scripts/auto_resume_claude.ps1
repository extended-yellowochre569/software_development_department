param(
    [int]$IntervalMinutes = 15
)

Write-Host "=========================================================="
Write-Host " Claude Rate Limit Auto-Resumer (AFK Mode)                "
Write-Host "=========================================================="
Write-Host "This script will send '1' and 'ENTER' to the active window"
Write-Host "every $IntervalMinutes minutes."
Write-Host "Keep your Claude Code window active when you step away!"
Write-Host "Press Ctrl+C to stop."
Write-Host "=========================================================="

Add-Type -AssemblyName System.Windows.Forms

while ($true) {
    $sleepSeconds = $IntervalMinutes * 60
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Waiting for $sleepSeconds seconds..."
    Start-Sleep -Seconds $sleepSeconds
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Sending '1' and 'ENTER' to active window to resume Claude..."
    [System.Windows.Forms.SendKeys]::SendWait("1")
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}
