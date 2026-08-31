<#
Updates the tooling used to build the IGs:

    ./_updateBuildTools.ps1             -> update both
    ./_updateBuildTools.ps1 scripts     -> only _build.sh / _build.bat
    ./_updateBuildTools.ps1 publisher   -> only publisher.jar

The build scripts are maintained by HL7 in
https://github.com/HL7/ig-publisher-scripts. The copies in igs/base-<rx> are
overwritten on every preprocessing run, so they are updated in ig-src, the
source for the generated IGs. Run ./_preprocessMultiVersion.ps1 afterwards to
propagate them to the generated IGs.

The publisher.jar is placed in the parent directory of the generated IGs, so
that all FHIR versions share a single copy.
#>

param(
    [Parameter(Position = 0)]
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

$scriptdlroot = "https://raw.githubusercontent.com/HL7/ig-publisher-scripts/main"
$publisher_dlurl = "https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"
$publisher_jar = "igs/publisher.jar"

$update_scripts = $false
$update_publisher = $false

switch ($Target) {
    "all"       { $update_scripts = $true; $update_publisher = $true }
    "scripts"   { $update_scripts = $true }
    "publisher" { $update_publisher = $true }
    default {
        Write-Host "Usage: $($MyInvocation.MyCommand.Name) [scripts|publisher]"
        exit 1
    }
}

if ($update_scripts) {
    foreach ($script in @("_build.sh", "_build.bat")) {
        Write-Host "Downloading $script"
        Invoke-WebRequest -Uri "$scriptdlroot/$script" -OutFile "ig-src/$script.new"
        Move-Item -Force "ig-src/$script.new" "ig-src/$script"
    }

    Write-Host "Build scripts updated in ig-src."
    Write-Host "Run ./_preprocessMultiVersion.ps1 to propagate them to the generated IGs."
}

if ($update_publisher) {
    $publisherDir = Split-Path $publisher_jar -Parent
    New-Item -ItemType Directory -Force -Path $publisherDir | Out-Null

    Write-Host "Downloading $publisher_jar (~200 MB)"
    # Invoke-WebRequest redraws its progress bar for every chunk it receives,
    # which on a download this size costs far more than the transfer itself.
    $previousProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"
    try {
        Invoke-WebRequest -Uri $publisher_dlurl -OutFile "$publisher_jar.new"
    } catch {
        Remove-Item -Force -ErrorAction SilentlyContinue "$publisher_jar.new"
        Write-Host "Downloading the IG Publisher failed. Aborting..."
        exit 1
    } finally {
        $ProgressPreference = $previousProgressPreference
    }
    Move-Item -Force "$publisher_jar.new" $publisher_jar

    Write-Host "IG Publisher updated: $publisher_jar"
}
