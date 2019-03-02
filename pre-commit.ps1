#!/usr/bin/pwsh
param (
    [switch]$ForceFix
)

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot"
$scriptsRoot = "$repoRoot/scripts"
$rulesRoot = "$repoRoot/build/rules"
# ---------------------------------------------------------------------

try{
    # Checking environment
    &"$repoRoot/build/environment-check.ps1"

    if ($ForceFix){
        $fixMode = $true
    }else{

        $changedFiles = &"$scriptsRoot/repo-search.ps1" ** -Status am?
        if ($changedFiles){
            Write-Host "------------------UNCOMMITTED CHANGES----------------------------" -ForegroundColor Yellow
            $changedFiles | Out-Host
            Write-Host "-----------------------------------------------------------------" -ForegroundColor Yellow
            Write-Host "WARNING: Automatic fixes are disabled due to uncommitted changes." -ForegroundColor Yellow
            Write-Host "-----------------------------------------------------------------" -ForegroundColor Yellow
        }
        else{
            $fixMode = $true
        }
    }

    Write-Host
    Write-Host "Checking and applying '*.sln' files rules" -ForegroundColor Green
    &"$rulesRoot/dotnet/sln-no-anycpu-configurations.ps1" -Fix:$fixMode
    &"$rulesRoot/dotnet/sln-vs-version.ps1" -Fix:$fixMode

    Write-Host
    Write-Host "Checking & applying 'eclint' rules" -ForegroundColor Green
    &"$rulesRoot/text/eclint.ps1" -Fix:$fixMode
}
catch{
    throw
}
