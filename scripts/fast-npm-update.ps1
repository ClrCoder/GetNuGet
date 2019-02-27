#!/usr/bin/pwsh

param (
    [string]$Path = $null
)

try{
    if (!$Path) {
        $Path = Get-Location
    }
    else {
        $Path = Resolve-Path $Path
    }

    $packageJsonFile = "$Path/package.json";
    $nodeModulesPath = "$Path/node_modules";

    if (!(Test-Path $packageJsonFile)) {
        throw "This is not a npm package directory."
    }

    # TODO: Check time difference between two times
    if (!(Test-Path $nodeModulesPath) `
            -or (
            (((Get-Item $packageJsonFile).LastWriteTimeUtc -
                    (Get-Item $nodeModulesPath).LastWriteTimeUtc).TotalSeconds) -gt 3)) {

        Push-Location $Path
        try{
            npm install
            if ($LASTEXITCODE) {
                throw "Error updating npm package"
            }
        }
        finally
        {
            Pop-Location > $null
        }
    }
}
catch{
    # We needs to rethrow, to stop execution on first error.
    throw;
}
