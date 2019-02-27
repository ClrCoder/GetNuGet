#!/usr/bin/pwsh

param(
    [parameter(Mandatory=$true, Position = 0)][string]$slnFilePath
)

try{
    $configSectionStarted = $false
    $result = @();
    foreach ($line in Get-Content $slnFilePath) {
        if ($configSectionStarted) {
            if ($line.Trim().StartsWith("EndGlobalSection")) {
                break;
            }

            $result += $line.Split("=")[0].Trim()
        }
        else {
            if ($line.Trim().StartsWith("GlobalSection(SolutionConfigurationPlatforms)")) {
                $configSectionStarted = $true;
            }
        }
    }

    return $result
}
catch{
    throw;
}
