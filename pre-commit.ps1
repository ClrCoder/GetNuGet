#!/usr/bin/pwsh


Push-Location $PSScriptRoot/build

try {
    powershell/fast-npm-update.ps1

    npm run eclint-check
}
finally {
    Pop-Location > $null
}
