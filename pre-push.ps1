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
    Write-Host "Checking commits history rules" -ForegroundColor Green
    # This check is mostly required for ClrSeed development itself
    #&"$rulesRoot/vcs/no-relative-issue-refs.ps1"

    Write-Host
    Write-Host "Checking & applying 'eclint' rules" -ForegroundColor Green
    &"$rulesRoot/text/eclint.ps1" -Fix:$fixMode

    Write-Host
    Write-Host "=================================================================" -ForegroundColor Green
    Write-Host "            Congratulation! You are ready to PUSH!"                -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Green
}
catch{
    throw
}
