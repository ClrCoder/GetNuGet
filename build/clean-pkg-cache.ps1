#!/usr/bin/pwsh

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

try{
    $assetFiles = &"$scriptsRoot/repo-search.ps1" "**/project.assets.json" -NoDir -Status !
    foreach ($assetFile in $assetFiles){
        $assetFilePath = Join-Path $repoRoot $assetFile
        Remove-Item -LiteralPath $assetFilePath -ErrorAction:Stop
        "$assetFile  deleted"
    }
}
catch{
    throw;
}
