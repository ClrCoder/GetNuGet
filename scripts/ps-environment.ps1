#!/usr/bin/pwsh

param (
    [parameter(ParameterSetName = "check", Mandatory = $true, Position = 0)][switch] $Check,
    [parameter(ParameterSetName = "fix", Mandatory = $true, Position = 0)][switch] $Fix
)

try {
    if ($PSVersionTable.PSVersion -lt "5.1") {
        throw "The minimum supported PowerShell version is 5.1"
    }

    $loadedModule = Get-Module PowerShellGet
    if($loadedModule){
        # Using fast detection method
        $curPSGetVersion = $loadedModule.Version
    }
    else{
        # This is slow detection method
        $curPSGetVersion = (Get-Module -ListAvailable PowerShellGet | Sort-Object -Property Version -Descending)[0].Version
    }
    $minPSGetVersion = "1.6.0"
    if ($Check) {
        if ($curPSGetVersion -lt $minPSGetVersion) {
            Write-Warning "Unsopported PowerShellGet version $curPSGetVersion < $minPSGetVersion"
            Write-Warning "Use this script to upgrade it: "
            Write-Warning "   scripts/ps-environment.ps1 -Fix"
            throw "Unsopported PowerShellGet version $curPSGetVersion < $minPSGetVersion"
        }
    }
    elseif ($Fix) {
        if ($curPSGetVersion -lt $minPSGetVersion) {
            Install-Module PowerShellGet -Force -AllowClobber -Scope CurrentUser
            Remove-Module PowerShellGet, PackageManagement -Force
        }
    }
}
catch {
    throw
}
