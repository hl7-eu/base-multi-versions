<#
Usage:
    ./_preProcessAndCheckAll.ps1           -> build both 4.0.1 and 5.0.0
    ./_preProcessAndCheckAll.ps1 4.0.1     -> build only 4.0.1
    ./_preProcessAndCheckAll.ps1 5.0.0     -> build only 5.0.0

Run from the repository root.
#>

param(
    [Parameter(Position = 0)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

$ig_base = "base"

if (-not $Version) {
    $selected_versions = @("4.0.1", "5.0.0")
} elseif ($Version -eq "4.0.1" -or $Version -eq "5.0.0") {
    $selected_versions = @($Version)
} else {
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) [4.0.1|5.0.0]"
    exit 1
}

function Ensure-BuildAssetsForIg {
    param([string]$IgDir)

    $localPublisher = Join-Path $IgDir "input-cache/publisher.jar"
    $parentPublisher = Join-Path (Split-Path $IgDir -Parent) "publisher.jar"

    if ((Test-Path $localPublisher) -or (Test-Path $parentPublisher)) {
        Write-Host "IG Publisher FOUND for $IgDir"
        return $true
    }

    # _updateBuildTools.ps1 downloads the jar to the parent directory of the
    # generated IGs, so that all FHIR versions share a single copy (_build.bat
    # looks for it there as well).
    Write-Host "IG Publisher NOT FOUND for $IgDir. Starting _updateBuildTools.ps1 publisher..."
    & ./_updateBuildTools.ps1 publisher

    if ((Test-Path $localPublisher) -or (Test-Path $parentPublisher)) {
        Write-Host "IG Publisher ready for $IgDir"
        return $true
    }

    Write-Host "IG Publisher still missing for $IgDir. Aborting..."
    return $false
}

function Build-Ig {
    param([string]$Version)

    switch ($Version) {
        "4.0.1" { $igDir = "igs/${ig_base}-r4" }
        "5.0.0" { $igDir = "igs/${ig_base}-r5" }
        default {
            Write-Host "Unsupported version: $Version"
            return
        }
    }

    Write-Host "=================================================================================="
    Write-Host "ensure publisher is available for $igDir"
    if (-not (Ensure-BuildAssetsForIg -IgDir $igDir)) { exit 1 }

    Write-Host "=================================================================================="
    Write-Host "build $igDir using _build.bat $($script:buildArgs -join ' ')"
    Push-Location $igDir
    try {
        # The terminology server is passed explicitly instead of letting _build.bat
        # decide between online and offline: an unrecognized first argument is
        # passed straight through to the publisher, which is how -tx is forwarded here.
        & .\_build.bat @script:buildArgs
    } finally {
        Pop-Location
    }
}

function Get-TxServer {
    # Determine the terminology server to use. A short HTTP probe is used rather
    # than ping, since it reports what actually matters and works where ICMP is
    # blocked (e.g. CI runners).
    try {
        Invoke-WebRequest -Uri "https://tx.fhir.org" -UseBasicParsing -TimeoutSec 10 -Method Head | Out-Null
        Write-Host "Terminology server tx.fhir.org is available"
        $script:buildArgs = @("-tx", "https://tx.fhir.org")
    } catch {
        Write-Host "WARNING: tx.fhir.org is not reachable, building without terminology server."
        Write-Host "         Terminology content will not publish correctly."
        $script:buildArgs = @("-tx", "n/a")
    }
}

Write-Host "=================================================================================="
Write-Host "Preprocessing - generate FHIR version specific IG"
if ($Version) {
    & ./_preprocessMultiVersion.ps1 $Version
} else {
    & ./_preprocessMultiVersion.ps1
}

Write-Host "=================================================================================="
Get-TxServer

foreach ($v in $selected_versions) {
    Build-Ig -Version $v
}
