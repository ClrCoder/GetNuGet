#!/usr/bin/pwsh

param(
    [parameter(ParameterSetName = "Get", Mandatory = $true, Position = 0)][switch] $Get,
    [parameter(ParameterSetName = "Remove", Mandatory = $true, Position = 0)][string[]] $Remove,
    [parameter(Mandatory = $true, Position = 1)][string]$Path
)

try {
    $lines = Get-Content $Path -ErrorAction Stop

    if ($Get) {
        $configSectionStarted = $false
        $result = @();
        foreach ($line in $lines) {
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
    elseif ($Remove) {
        $projectConfigPattern = ""
        foreach ($cfgName in $Remove) {
            if ($projectConfigPattern -ne "") {
                $projectConfigPattern += "|"
            }
            $projectConfigPattern += "($($cfgName.Replace("|", "\|")))"
        }

        $solutionConfigPattern = ""
        foreach ($cfgName in $Remove) {
            if ($solutionConfigPattern -ne "") {
                $solutionConfigPattern += "|"
            }
            $cfgPattern = $cfgName.Replace("|", "\|")
            $solutionConfigPattern += "($cfgPattern\s*=\s*$cfgPattern)"
        }

        $guidPattern = "{[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}}"

        $outLines = New-Object System.Collections.Generic.List[System.Object]
        $projCfgLinePattern = "$guidPattern\.$projectConfigPattern.+=";
        foreach ($line in $lines) {
            if ($line -notmatch $projCfgLinePattern -and $line -notmatch $solutionConfigPattern) {
                $outLines.Add($line)
            }
        }

        $outLines | Out-File $Path -Encoding utf8 -ErrorAction Stop
    }
}
catch {
    throw;
}
