#!/usr/bin/pwsh

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/../../.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

function Invoke-HgCommand {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, position = 0)]
        [string[]]$Arguments,
        [parameter(Mandatory = $false)]
        [string]$Cwd,
        [parameter(Mandatory = $false)]
        [string]$ErrorDetailsMessage
    )
    process {
        $curEncoding = [Console]::OutputEncoding

        $encodingName = $curEncoding.WebName

        $Arguments += @("--encoding", $encodingName)
        if ($Cwd) {
            $Arguments += @("--cwd", $Cwd)
        }

        $allOutput = hg $Arguments 2>&1
        $stderr = $allOutput | ? { $_ -is [System.Management.Automation.ErrorRecord] }
        $stdout = $allOutput | ? { $_ -isnot [System.Management.Automation.ErrorRecord] }

        $stdout

        if ($LASTEXITCODE -ne 0) {
            $errorMessage = $stderr | Out-String
            $exception = New-Object System.Management.Automation.RemoteException $errorMessage
            $errorID = 'NativeCommandError'
            $category = [Management.Automation.ErrorCategory]::ResourceUnavailable
            $target = "hg"
            $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $category, $target
            if ($ErrorDetailsMessage) {
                $errorRecord.ErrorDetails = New-Object Management.Automation.ErrorDetails $ErrorDetailsMessage
            }
            elseif ($errorMessage.StartsWith("abort: no repository found")) {
                $errorRecord.ErrorDetails = New-Object Management.Automation.ErrorDetails "Hg repository workdir has not been found"
            }
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

function Select-HgCommitMessages {
    $curChangeset = @{}
    $input | % {
        if ($_[0] -eq [char]0) {
            if ($curChangeset.Keys.Count -ne 0) {
                $curChangeset
                $curChangeset = @{}
            }
            $idParts = $_.Split(":")
            $curChangeset.LocalId = $idParts[0].Substring(1, $idParts[0].Length - 1)
            $curChangeset.Hash = $idParts[1]
        }
        else {
            if (!$curChangeset.ContainsKey("Message")) {
                $curChangeset.Message = $_
            }
            else {
                $curChangeset.Message += [Environment]::NewLine + $_
            }
        }
    }
    if ($curChangeset.Keys.Count -ne 0) {
        $curChangeset
    }
}

function Invoke-GitCommand {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, position = 0)]
        [string[]]$Arguments,
        [parameter(Mandatory = $false)]
        [string]$Cwd,
        [parameter(Mandatory = $false)]
        [string]$ErrorDetailsMessage
    )
    process {

        $env:LC_LOCAL = "C.UTF-8"
        if ($null -eq $IsWindows -or $IsWindows) {
            $curEncoding = [Console]::OutputEncoding
            $encodingName = $curEncoding.WebName
            if ($encodingName -ne "utf-8") {
                chcp 65001 | Out-Null
            }
        }

        try {
            Push-Location $repoRoot

            $allOutput = git $Arguments 2>&1
            $stderr = $allOutput | ? { $_ -is [System.Management.Automation.ErrorRecord] }
            $stdout = $allOutput | ? { $_ -isnot [System.Management.Automation.ErrorRecord] }

            $stdout

            if ($LASTEXITCODE -ne 0) {
                $errorMessage = $stderr | Out-String
                $exception = New-Object System.Management.Automation.RemoteException $errorMessage
                $errorID = 'NativeCommandError'
                $category = [Management.Automation.ErrorCategory]::ResourceUnavailable
                $target = "git"
                $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $category, $target
                if ($ErrorDetailsMessage) {
                    $errorRecord.ErrorDetails = New-Object Management.Automation.ErrorDetails $ErrorDetailsMessage
                }
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
        finally {
            Pop-Location | Out-Null
        }
    }
}

function Select-GitCommitMessages {
    $curChangeset = @{}
    $input | % {
        if ($_[0] -eq [char]0) {
            if ($curChangeset.Keys.Count -ne 0) {
                $curChangeset
                $curChangeset = @{}
            }
            $curChangeset.Hash = $_.Substring(1, $_.Length - 1)
        }
        else {
            if (!$curChangeset.ContainsKey("Message")) {
                $curChangeset.Message = $_
            }
            else {
                $curChangeset.Message += [Environment]::NewLine + $_
            }
        }
    }
    if ($curChangeset.Keys.Count -ne 0) {
        $curChangeset
    }
}

try {

    if (Test-Path "$repoRoot/.hg" -Type Container) {
        $changeSets = Invoke-HgCommand -Arguments "log", "--template", "\0{rev}:{node}\n{desc}\n" -Cwd $repoRoot | Select-HgCommitMessages
    }
    elseif (Test-Path "$repoRoot/.git" -Type Container) {
        $changeSets = Invoke-GitCommand -Arguments "log", "--pretty=format:%x00%H%n%B" -Cwd $repoRoot | Select-GitCommitMessages
    }
    else {
        throw "Unknown repository type."
    }

    foreach ($commit in $changeSets) {
        if ($commit.Message -match " \#\d+") {
            Write-Warning "Changeset with error: $($commit.Message)"
            throw "All '#<number>' references should be prefixed by a repository name. ChangeSet Hash=$($commit.Hash)"
        }
    }
}
catch {
    throw
}
