#!/usr/bin/pwsh
param (
    [string]$Path = $null
)
try {
    if (!$Path) {
        $Path = Get-Location
    }
    else {
        $Path = Resolve-Path $Path
    }

    $packageJsonFile = "$Path/package.json";
    $nodeModulesPath = "$Path/node_modules";

    if (! (Test-Path $packageJsonFile)) {
        throw "This is not a npm package directory."
    }

    if (!(Test-Path $nodeModulesPath) `
            -or ((Get-Item $nodeModulesPath).LastWriteTimeUtc) -lt (Get-Item $packageJsonFile).LastWriteTimeUtc) {
        npm install --cwd $Path
    }
}
catch {
    Write-Host "$($_.Exception.Message)"
    exit 1
}
