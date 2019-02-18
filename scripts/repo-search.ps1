param(
    [parameter(Mandatory = $true, Position = 0)][string[]]$Path,
    [switch]$NoDir
)

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
&"$scriptsRoot/fast-npm-update.ps1" -Path $scriptsRoot

$arguments = @(
    "node_modules/gulp/bin/gulp.js",
    "--silent",
    "repo-search"
)

if ($NoDir){
    $arguments+='--nodir'
}

foreach ($p in $Path) {
    $arguments+= '--src'
    $arguments+= $p
}

# Running script in the scripts directory

Push-Location $scriptsRoot
try {
    $files = node $arguments
    if ($LASTEXITCODE) {
        throw "Error executing gulp 'repo-search' task"
    }

    $files
}
finally {
    Pop-Location
}
