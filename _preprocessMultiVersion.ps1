<#
Optional CLI usage:
    ./_preprocessMultiVersion.ps1           -> build both 4.0.1 and 5.0.0
    ./_preprocessMultiVersion.ps1 4.0.1     -> build only 4.0.1
    ./_preprocessMultiVersion.ps1 5.0.0     -> build only 5.0.0

Run from the repository root.
#>

param(
    [Parameter(Position = 0)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

if (-not $Version) {
    $versions = @("4.0.1", "5.0.0")
} else {
    $versions = @($Version)
}

$ig_base = "base"

# Warm the liquidjs package into the npx cache once, serially, before the
# parallel processing loop below. On a cold cache, multiple concurrent
# `npx --yes liquidjs` calls race to install the package and can produce empty
# output.
Write-Host "Ensuring liquidjs is available (warming npx cache)"
try { npx --yes liquidjs --help *> $null } catch {}

foreach ($version in $versions) {
    if ($version -eq "4.0.1") {
        $context_version = "R4"
        $build_dir = "igs/${ig_base}-r4"
    } elseif ($version -eq "5.0.0") {
        $context_version = "R5"
        $build_dir = "igs/${ig_base}-r5"
    }

    New-Item -ItemType Directory -Force -Path $build_dir | Out-Null

    Write-Host "remove all files from $build_dir"
    Write-Host "Setting read-only permissions on $build_dir"
    Get-ChildItem -Path $build_dir -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Attributes -band [IO.FileAttributes]::ReadOnly } |
        ForEach-Object { $_.Attributes = $_.Attributes -band (-bnot [IO.FileAttributes]::ReadOnly) }
    Get-ChildItem -Path $build_dir -File -Force -ErrorAction SilentlyContinue | Remove-Item -Force
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$build_dir/input"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$build_dir/output"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$build_dir/ig-template"

    Write-Host "copy all files to $build_dir"
    Get-ChildItem -Path "ig-src" -File -Force | Copy-Item -Destination $build_dir -Force
    Copy-Item -Recurse -Force "ig-src/input" $build_dir
    Copy-Item -Recurse -Force "ig-src/ig-template" $build_dir

    # Process all liquid files
    Write-Host "Processing liquid files"
    # The names are matched here rather than with -Filter, which is the Windows
    # filesystem matcher and not the exact glob `find -name` applies: it lets a
    # trailing .* match a name that has nothing after the dot at all. Every hit
    # is deleted after rendering, so it is worth being precise.
    $liquidFiles = Get-ChildItem -Path $build_dir -Recurse -File |
        Where-Object { $_.Name -like "*.liquid.*" }

    # liquidjs writes UTF-8 to stdout (templates can contain box-drawing
    # characters, e.g. sushi-config.liquid.yaml). Without this, PowerShell
    # decodes native-command output using the legacy OEM/ANSI codepage, which
    # corrupts any multi-byte characters into garbage that later trips up the
    # FHIR IG Publisher's UTF-8 reader.
    $previousOutputEncoding = [Console]::OutputEncoding
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    # Write back out as UTF-8 without a BOM (Set-Content's default encoding
    # would re-corrupt the same characters on the way out).
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false

    # The bash script forks a subshell per file, which is cheap. Start-Job is
    # not that: it starts a whole PowerShell process per file, and with thirty
    # templates that is thirty runspaces, each starting npx on top, so on
    # Windows the process creation costs more than the parallelism saves. The
    # files are rendered one after another instead.
    try {
        foreach ($file in $liquidFiles) {
            $filePath = $file.FullName
            $cleanFilePath = $filePath -replace '\.liquid\.', '.'
            Write-Host "- $filePath --> $cleanFilePath"

            $content = npx --yes liquidjs -t "@$filePath" --context "@context-$context_version.json"
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Failed to process liquid file: $filePath"
                exit 1
            }

            [System.IO.File]::WriteAllLines($cleanFilePath, $content, $utf8NoBom)
            Remove-Item -Force $filePath
        }
    } finally {
        [Console]::OutputEncoding = $previousOutputEncoding
    }

    # make readonly (kept disabled to mirror the original script)
    # Write-Host "Setting read-only permissions on $build_dir"
}
