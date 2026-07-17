#Requires -Version 5.1
<#
.SYNOPSIS
    One-shot publish of this project to a new GitHub repository.

.DESCRIPTION
    Initializes git (if needed), commits everything respecting .gitignore,
    and creates + pushes a GitHub repo via the GitHub CLI (`gh`).
    Requires `gh auth login` to have been run already (gh auth status
    must report "Logged in").

.PARAMETER RepoName
    Name for the new GitHub repository. Defaults to "sql-practice-lab".

.PARAMETER Private
    Create the repo as private instead of public.

.EXAMPLE
    .\scripts\publish-to-github.ps1
    .\scripts\publish-to-github.ps1 -RepoName my-sql-lab -Private
#>

param(
    [string]$RepoName = "sql-practice-lab",
    [switch]$Private
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host "==> Publishing to GitHub" -ForegroundColor Cyan

# 1. Verify gh is installed and authenticated
$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
    throw "GitHub CLI ('gh') not found. Install it from https://cli.github.com/ and run 'gh auth login' first."
}

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host $authStatus
    throw "gh is not authenticated. Run 'gh auth login' first, then re-run this script."
}
Write-Host "gh auth OK." -ForegroundColor Green

# 2. Initialize git if this isn't already a repo
if (-not (Test-Path ".git")) {
    Write-Host "Initializing git repository..."
    git init -b main
} else {
    Write-Host "Git repository already initialized."
}

# 3. Stage and commit (respects .gitignore -- .env, generated CSVs, __pycache__ excluded)
git add -A
$pending = git status --porcelain
if ($pending) {
    git commit -m "SQL practice lab: Oracle XE"
    Write-Host "Committed changes." -ForegroundColor Green
} else {
    Write-Host "Nothing new to commit."
}

# 4. Create the GitHub repo (if it doesn't already exist) and push
$visibility = if ($Private) { "--private" } else { "--public" }

$existing = gh repo view $RepoName 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Repo '$RepoName' already exists on GitHub -- pushing to it."
    git remote remove origin 2>$null
    git remote add origin "https://github.com/$(gh api user --jq .login)/$RepoName.git"
    git push -u origin main
} else {
    Write-Host "Creating GitHub repo '$RepoName' ($visibility) and pushing..."
    gh repo create $RepoName $visibility --source=. --remote=origin --push
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
gh repo view --web --json url --jq .url 2>$null
gh repo view $RepoName --json url --jq .url
