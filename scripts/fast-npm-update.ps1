#!/usr/bin/pwsh

param (
    [string]$Path = $null
)

if (!$Path) {
    $Path = Get-Location
}
else {
    $Path = Resolve-Path $Path
}

$packageJsonFile = "$Path/package.json";
$nodeModulesPath = "$Path/node_modules";

# if (! (Test-Path $packageJsonFile)) {
#     throw "This is not a npm package directory."
# }

# TODO: Check time difference between two times
if (!(Test-Path $nodeModulesPath) `
        -or (
        (((Get-Item $packageJsonFile).LastWriteTimeUtc -
                (Get-Item $nodeModulesPath).LastWriteTimeUtc).TotalSeconds) -gt 3)) {

    npm install --cwd $Path
    if ($LASTEXITCODE) {
        throw "Error updating npm package"
    }
}
