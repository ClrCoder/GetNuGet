# GetNuGet
## Introduction
```PowerShell
# Downloads (with the local cache) the nuget.exe and returns path
$NuGet = Get-NuGet -Version 4.9.3

# Restores packages
&$NuGet restore

# Should print under windows:
#   c:\users\<user>\.nuget\cli\4.9.3\nuget.exe
Write-Host $NuGet
```
#### Supported Operating Systems
* Windows
* *Linux (Planned)*

### See Also
* [CHANGELOG](CHANGELOG.md)
* [LICENSE](LICENSE)
