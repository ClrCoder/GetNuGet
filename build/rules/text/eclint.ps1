#!/usr/bin/pwsh

param(
    [switch]$Fix
)

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/../../.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

try{
    &"$scriptsRoot/ensure-deps.ps1"

    Push-Location $repoRoot/scripts

    try {
        if ($Fix){
            # Fix last line and trim spaces
            npm run eclint-fix
        }

        # Checking everything else
        npm run eclint-check
    }
    finally {
        Pop-Location > $null
    }
}
catch{
    throw
}
