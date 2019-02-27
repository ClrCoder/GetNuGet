#!/usr/bin/pwsh

param (
    [parameter(ParameterSetName="show", Mandatory=$true, Position = 0)][switch] $Show,
    [parameter(ParameterSetName="check", Mandatory=$true, Position = 0)][switch] $Check,
    [parameter(ParameterSetName="fix", Mandatory=$true, Position = 0)][switch] $Fix,
    [parameter(Mandatory=$true, Position = 1)][string]$Path
)

try
{
    $lines = Get-Content $Path

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim().StartsWith("VisualStudioVersion")){
            $vsVersionLineNumber = $i
        }
        if ($lines[$i].Trim().StartsWith("MinimumVisualStudioVersion")){
            $minimalVsVersionLineNumber = $i
            break;
        }
    }

    if (!$vsVersionLineNumber -or !$minimalVsVersionLineNumber){
        throw "Invalid SLN format. Cannot parse VisualStudioVersion or MinimalVisualStudioVersion";
    }

    $vsVersion = $lines[$vsVersionLineNumber].Split("=")[1].Trim();
    $minimalVsVersion = $lines[$minimalVsVersionLineNumber].Split("=")[1].Trim();

    if ($Show){
        "VsVersion = $vsVersion"
        "MinimalVsVersion = $minimalVsVersion"
    }
    elseif ($Check){
        if ($vsVersion -ne $minimalVsVersion){
            throw "MinimalVisualStudioVersion should match VisualStudioVersion to avoid merge conflicts."
        }
    }
    elseif ($Fix){
        if ($vsVersion -ne $minimalVsVersion){
            $lines[$vsVersionLineNumber] = $lines[$vsVersionLineNumber].Replace($vsVersion, $minimalVsVersion);
            Write-Host (Resolve-Path $Path) -NoNewline -ForegroundColor White
            Write-Host ": VisualStudioVersion = " -NoNewline
            Write-Host "$vsVersion" -NoNewline -ForegroundColor White
            Write-Host " has been replaced to " -NoNewline
            Write-Host "$minimalVsVersion" -ForegroundColor White

            $lines | Out-File "$($Path)" -Encoding utf8
        }
    }
}
catch
{
    throw
}
