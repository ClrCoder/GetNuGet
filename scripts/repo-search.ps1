param(
    [parameter(Mandatory = $true, Position = 0)][string[]]$Path,
    [switch]$NoDir,
    [switch]$IncludeIgnored,
    [string]$Status
)

try {
    # Searching root directories
    # --------------------------------
    $repoRoot = $PSScriptRoot;
    while (!(Test-Path "$repoRoot/.hg") -and !(Test-Path "$repoRoot/.git")) {
        $repoRoot = Split-Path -Path $repoRoot
        if (!$repoRoot) {
            throw "The repository root hasn't been found."
        }
    }
    $scriptsRoot = "$repoRoot/scripts"

    # Refreshing scripts npm package
    &"$scriptsRoot/ensure-deps.ps1"

    $arguments = @(
        "node_modules/gulp/bin/gulp.js",
        "--silent",
        "repo-search"
    )

    if ($NoDir) {
        $arguments += '--nodir'
    }

    if ($Status) {
        $arguments += "--status"
        $arguments += $Status
    }

    foreach ($p in $Path) {
        $arguments += '--src'
        $arguments += $p
    }

    # Running script in the scripts directory

    Push-Location $scriptsRoot
    try {
        $files = node $arguments
        if ($LASTEXITCODE) {
            throw "Error executing gulp 'repo-search' task"
        }

        return $files
    }
    finally {
        Pop-Location
    }

}
catch {
    # We needs to rethrow, to stop execution on first error.
    throw;
}
