function Get-NuGet {
    param(
        [Parameter(Position = 0)]
        [ValidatePattern("^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")]
        [string]
        $Version)

    if ($null -ne $IsWindows -and !$IsWindows) {
        throw "Currently this command is implemented only for windows"
    }

    $NuGetFolder = "$($env:USERPROFILE)/.nuget/cli/$Version"
    $NuGetPath = "$NuGetFolder/nuget.exe"
    if (!(Test-Path $NuGetPath -PathType Leaf)) {
        if (!(Test-Path $NuGetPath -PathType Container)) {
            New-Item -type Directory -Path $NuGetFolder | Out-Null
        }

        # Downloading nuget.exe
        Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/v$Version/nuget.exe" -OutFile $NuGetPath
        $helpOutput = &$NuGetPath help

        $actualVersion = $helpOutput[0].Split(":")[1].SubString(1, 5);
        if ($actualVersion -ne $Version) {
            throw "Actual version ($actualVersion) of the downloaded nuget.exe does not match to the required version ($Version)."
        }
    }

    $NuGetPath
}

$exportModuleMemberParams = @{
    Function = @(
        'Get-NuGet'
    )

    Variable = @(
    )
}

Export-ModuleMember @exportModuleMemberParams
