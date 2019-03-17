#!/usr/bin/pwsh

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

try {
    # Checking powershell environment
    &"$scriptsRoot/ps-environment.ps1" -Check

    # Checking PSSolution module version
    $pssModule = Get-Module PSSolutions
    if ($pssModule) {
        $curPssVersion = $pssModule.Version
    }else{
        $availablePssModules = Get-Module -ListAvailable PSSolutions | Sort-Object -Property Version -Descending
        if ($availablePssModules){
            $curPssVersion = $availablePssModules[0].Version
        }
    }

    $minPssVersion = "0.0.3"
    if (!$curPssVersion -or $curPssVersion -lt $minPssVersion){
        if ($pssModule){
            Remove-Module PSSolutions -Force -ErrorAction Stop
        }
        Install-Module PSSolutions -Scope CurrentUser -Force
    }

    # Activating ClrSeed PSSolution
    Import-PSSolution -Name ClrSeed $scriptsRoot

    &"$scriptsRoot/fast-npm-update.ps1" -Path $scriptsRoot | Out-Host
}
catch {
    throw
}
