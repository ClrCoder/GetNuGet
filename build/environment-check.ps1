#!/usr/bin/pwsh
param (
    [switch]$Silent
)

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

function Invoke-Simple {
    param(
        [string]$Cmd,
        [string[]] $CmdArgs)
    try {
        $result = &$Cmd $CmdArgs 2>&1
        if ($LASTEXITCODE) {
            return $null
        }
    }
    catch {
    }

    return $result
}

function Write-SimpleReport {
    param(
        [string]$Dependency,
        [string[]] $Version)

}
try {

    Write-Host "PowerShell environment check..." -ForegroundColor Green
    Write-Host
    &"$scriptsRoot/ps-environment.ps1" -Check

    # TODO: Add varnings
    $dependenciesReport = @()
    $nodeVersion = Invoke-Simple -Cmd "node" -CmdArgs "--version"
    if ($nodeVersion) {
        if ([int]($nodeVersion.Replace("v", "").Split(".")[0]) -lt 8) {
            $nodeError = "Error - $nodeVersion < 8.0"
        }
    }
    $dependenciesReport += [pscustomobject]@{
        Name    = "Node.JS";
        Version = $nodeVersion
        Error = $nodeError
    }

    $dotnetCoreVersion = Invoke-Simple -Cmd "dotnet" -CmdArgs "--version"
    if ($dotnetCoreVersion) {
        if ([int]($dotnetCoreVersion.Substring(0, 3).Replace(".", "")) -lt 21) {
            $dotnetError = "Error - $dotnetCoreVersion < 2.1"
        }
    }
    $dependenciesReport += [pscustomobject]@{
        Name    = ".Net Core";
        Version = $dotnetCoreVersion
        Error   = $dotnetError
    }

    if (!$Silent) {
        Write-Host "Build environment check" -ForegroundColor Green
        Write-Host "-------------------------------------------" -ForegroundColor Green
    }

    $faultedDependencies = @()
    foreach ($reportItem in $dependenciesReport) {
        if (!$reportItem.Version) {
            $error = "NOT FOUND"
        }
        else {
            $error = $reportItem.Error
        }

        if ($error) {
            $faultedDependencies += $reportItem.Name
        }

        if (!$Silent) {
            $depName = $reportItem.Name.PadRight(20);
            Write-Host "$depName - " -NoNewline -ForegroundColor White

            if (!$error) {
                Write-Host $reportItem.Version -ForegroundColor DarkGreen
            }
            else {
                Write-Host $error -ForegroundColor DarkRed
            }
        }
    }

    if (!$Silent) {
        Write-Host "-------------------------------------------" -ForegroundColor Green
        Write-Host
    }

    if ($faultedDependencies) {
        throw "Following dependencies are not met: $($faultedDependencies -join ', ')"
    }
}
catch {
    throw
}
