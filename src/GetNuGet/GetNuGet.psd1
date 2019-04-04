@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'GetNuGet.psm1'

    # Version number of this module.
    ModuleVersion     = '0.0.1'

    # ID used to uniquely identify this module
    GUID              = '247BD3D2-C7A8-4465-A256-E87355CB2A51'

    # Author of this module
    Author            = 'ClrCoder community'

    # Copyright statement for this module
    Copyright         = '(c) 2019 ClrCoder community'

    # Description of the functionality provided by this module
    Description       = 'Helps to obtain NuGet command line tools'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @('Get-NuGet')

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    RequiredModules   = @(
    )
    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('NuGet', "CommandLine", "nuget.exe")

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/ClrCoder/GetNuGet/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/ClrCoder/GetNuGet'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/ClrCoder/GetNuGet/blob/master/CHANGELOG.md'
        }
    }
}
