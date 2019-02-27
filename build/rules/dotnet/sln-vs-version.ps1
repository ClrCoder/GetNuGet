#!/usr/bin/pwsh
param (
    [switch]$Fix
)

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/../../.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

try{
    foreach ($slnFile in &"$PSScriptRoot/config/sln-files.ps1") {
        if ($Fix){
            &"$scriptsRoot/sln-vsversion.ps1" -Fix (Join-Path $repoRoot $slnFile)
        }
        else{
            &"$scriptsRoot/sln-vsversion.ps1" -Check (Join-Path $repoRoot $slnFile)
        }
    }
}
catch{
    throw
}
