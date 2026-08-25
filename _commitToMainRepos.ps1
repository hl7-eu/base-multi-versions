<#
Syncs the generated per-version IGs (igs/base-r4, igs/base-r5) into their
own repos (subigs/base, subigs/base-r5), committing and pushing any changes
on the current branch.

Run from the repository root.
#>

$ErrorActionPreference = "Stop"

# Check if we're inside a git repository
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not inside a git repository."
    exit 1
}

$current_branch = git rev-parse --abbrev-ref HEAD
Write-Host "Current branch: $current_branch"

$src_dir = "igs/"
$subrepo_dir = "subigs/"

$versions = @("r4", "r5")

if (-not (Test-Path $src_dir)) {
    New-Item -ItemType Directory -Force -Path $src_dir | Out-Null
    Write-Host "Created directory ${src_dir}aa."
}

foreach ($version in $versions) {

    if ($version -eq "r4") {
        $full_src_dir = "${src_dir}base-r4"
        $full_tgt_dir = "${subrepo_dir}base"
        $target_repo = "base"
    } else {
        $full_src_dir = "${src_dir}base-r5"
        $full_tgt_dir = "${subrepo_dir}base-r5"
        $target_repo = "base-r5"
    }

    if (-not (Test-Path $full_src_dir)) {
        New-Item -ItemType Directory -Force -Path $full_src_dir | Out-Null
        Write-Host "Created directory $full_src_dir."
    }

    Write-Host "Ensure $full_tgt_dir is a git repo and on the same branch"
    if (Test-Path "$full_tgt_dir/.git") {
        Push-Location $full_tgt_dir

        git show-ref --verify --quiet "refs/heads/$current_branch"
        if ($LASTEXITCODE -eq 0) {
            git checkout $current_branch
            git pull origin $current_branch
        } else {
            git checkout -b $current_branch
        }

        Pop-Location
    } else {
        Write-Host "Directory $full_tgt_dir is not a git repository."
        git clone "git@github.com:hl7-eu/${target_repo}.git" $full_tgt_dir
    }

    # Copy contents from igs/<version> to the target repo
    if (Test-Path $full_src_dir) {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$full_tgt_dir/ig-template"
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$full_tgt_dir/input"
        Copy-Item -Path "$full_src_dir\*" -Destination $full_tgt_dir -Recurse -Force
        Write-Host "Copied contents from $full_src_dir to $full_tgt_dir."
    } else {
        Write-Host "Source directory $full_src_dir does not exist."
        exit 1
    }

    # Get the current commit hash of the main repo
    $main_repo_commit = git rev-parse HEAD
    Write-Host "Current commit hash of main repo: $main_repo_commit"

    $main_repo_url = git config --get remote.origin.url
    Write-Host "Main repo URL: $main_repo_url"

    # Commit content
    Push-Location $full_tgt_dir
    git add .
    git diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "No changes to commit in $full_tgt_dir."
    } else {
        $last_commit_message = git log -1 --pretty=%B

        git commit -m "$last_commit_message" -m "Sync from $main_repo_url for commit $main_repo_commit."
        git push origin $current_branch
        Write-Host "Committed and pushed changes in $full_tgt_dir."
    }
    Pop-Location
}
