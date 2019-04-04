#!/usr/bin/pwsh
param (
    [ValidateSet("PrePush", "CI", "Dev")]
    [string]$Mode = "Dev",
    [string]$Configuration = "Debug",
    [string]$Platform = "x64"
)

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

try{

    Write-Host "Building $Configuration|$Platform confiuration" -ForegroundColor Green
    Write-host "---------------------------------------------------------" -ForegroundColor Green

    # Working from the root of the repository
    Push-Location $repoRoot

    if ($Mode -eq "Dev"){
        &"$repoRoot/build/clean-pkg-cache.ps1"
        dotnet msbuild -restore /t:rebuild /p:Configuration=$Configuration /p:Platform=$Platform
    }
    elseif ($Mode -eq "CI"){
        dotnet msbuild -restore /t:rebuild /p:Configuration=$Configuration /p:Platform=$Platform /warnaserror
    }
    elseif ($Mode -eq "PrePush"){
        &"$repoRoot/build/clean-pkg-cache.ps1"
        dotnet msbuild -restore /t:rebuild /p:Configuration=$Configuration /p:Platform=$Platform /warnaserror
    }
    if ($LASTEXITCODE) {
        throw "Build failed."
    }
}
catch{
    throw
}
finally{
    Pop-Location | Out-Null
}
