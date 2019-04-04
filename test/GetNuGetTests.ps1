# Reloading Module
Remove-Module GetNuGet -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/../src/GetNuGet/GetNuGet.psm1"


Get-NuGet 4.8.2
