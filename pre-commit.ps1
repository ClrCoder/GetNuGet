#!/usr/bin/pwsh


Push-Location $PSScriptRoot/build

try {
    ../scripts/fast-npm-update.ps1

    npm run eclint-check
}
finally {
    Pop-Location > $null
}
