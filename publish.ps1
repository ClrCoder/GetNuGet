param(
    [parameter(Position=0, Mandatory = $true)]
    $ApiKey
)


Publish-Module -Path $PSScriptRoot/src/GetNuGet -NuGetApiKey $ApiKey
