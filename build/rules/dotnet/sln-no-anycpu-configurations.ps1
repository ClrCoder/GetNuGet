#!/usr/bin/pwsh

param (
    [switch]$Fix
)

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/../../.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

try {
    if (!$Fix) {
        $wrongSlnFiles = @()

        foreach ($slnFile in &"$PSScriptRoot/config/sln-files.ps1") {
            $slnFilePath = Join-Path $repoRoot $slnFile
            if (&"$scriptsRoot/sln-configurations.ps1" -Get $slnFilePath `
                    | Select-String "\|Any CPU") {
                $wrongSlnFiles += $slnFile
            }
        }

        if ($wrongSlnFiles) {
            Write-Host "Solution files with Any CPU configurations:"
            $wrongSlnFiles
            throw "Found solution files with Any CPU configuration."
        }
    }
    else {
        foreach ($slnFile in &"$PSScriptRoot/config/sln-files.ps1") {
            $slnFilePath = Join-Path $repoRoot $slnFile
            $configurations = &"$scriptsRoot/sln-configurations.ps1" -Get $slnFilePath
            $badCfgs = $configurations | Select-String "\|Any CPU"
            if ($badCfgs) {
                if ($badCfgs.Count -lt $configurations.Count) {
                    &"$scriptsRoot/sln-configurations.ps1" -Remove $badCfgs $slnFilePath
                    Write-Host "`Any CPU` configurations has been removed from $slnFile"
                }
                else {
                    throw "Fix of $slnFile is impossible because it contains only `Any CPU` configurations."
                }
            }
        }
    }
}
catch {
    throw
}
