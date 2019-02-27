#!/usr/bin/pwsh

param(
    [switch]$Fix
)

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/../../.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

try{
    Push-Location $repoRoot/scripts

    try {
        &"$scriptsRoot/fast-npm-update.ps1"

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
