# Claude Code PreToolUse hook: Validates git commit commands (PowerShell)

# Capture stdin as JSON string
$jsonInput = @($input) | Out-String
if ([string]::IsNullOrWhitespace($jsonInput)) { exit 0 }

try {
    $data = $jsonInput | ConvertFrom-Json
}
catch {
    exit 0
}

# Only process git commit commands
$command = $data.tool_input.command
if ($command -notmatch '^git\s+commit') { exit 0 }

# Get staged files
$staged = git diff --cached --name-only 2>$null
if ([string]::IsNullOrWhitespace($staged)) { exit 0 }

$warnings = @()

# Check design documents for required sections
$designFiles = $staged | Where-Object { $_ -match '^design/specs/' }
if ($designFiles) {
    foreach ($file in $designFiles) {
        if (Test-Path $file) {
            $content = Get-Content $file -Raw
            $requiredSections = @("Overview", "User Value", "Detailed", "Formulas", "Edge Cases", "Dependencies", "Configuration", "Acceptance Criteria")
            foreach ($section in $requiredSections) {
                if ($content -notmatch "(?i)$section") {
                    $warnings += "DESIGN: $file missing required section: $section"
                }
            }
        }
    }
}

# Validate JSON data files
$dataFiles = $staged | Where-Object { $_ -match '^assets/data/.*\.json$' }
if ($dataFiles) {
    foreach ($file in $dataFiles) {
        if (Test-Path $file) {
            try {
                Get-Content $file -Raw | ConvertFrom-Json | Out-Null
            }
            catch {
                Write-Error "BLOCKED: $file is not valid JSON"
                exit 2
            }
        }
    }
}

# Check for hardcoded magic numbers
$codeFiles = $staged | Where-Object { $_ -match '^src/' }
if ($codeFiles) {
    foreach ($file in $codeFiles) {
        if (Test-Path $file) {
            $magicMatch = Select-String -Path $file -Pattern '[[:space:]]=[[:space:]]*[0-9]{4,}' 2>$null
            if ($magicMatch) {
                $warnings += "CODE: $file may contain hardcoded magic numbers. Use config files."
            }
        }
    }
}

# STYLE: TODO/FIXME without owner
if ($codeFiles) {
    foreach ($file in $codeFiles) {
        if (Test-Path $file) {
            $todoMatch = Select-String -Path $file -Pattern '(TODO|FIXME|HACK)[^(]' 2>$null
            if ($todoMatch) {
                $warnings += "STYLE: $file has TODO/FIXME without owner tag. Use TODO(name) format."
            }
        }
    }
}

# Print warnings (non-blocking) and allow commit
if ($warnings.Count -gt 0) {
    Write-Host "=== Commit Validation Warnings ==="
    $warnings | ForEach-Object { Write-Host $_ }
    Write-Host "================================"
}

exit 0
