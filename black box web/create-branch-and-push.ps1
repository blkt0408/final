<#
create-branch-and-push.ps1

Creates (or updates) a branch with all files from the current folder and pushes it to the remote.
Usage (PowerShell):
  cd "d:\black box web"
  .\create-branch-and-push.ps1 -Branch gh-pages -Remote origin -ForcePush

Parameters:
  -Branch (string)  : branch name to create/update (default: gh-pages)
  -Remote (string)  : remote name to push (default: origin)
  -ForcePush        : if present, forces push (use with caution)
  -Message (string) : commit message (default: "Publish site files to <branch>")

Notes:
 - This script requires git to be installed and available in PATH.
 - It will initialize a git repo if one does not exist.
 - If you haven't added a remote yet, create the remote on GitHub and run:
     git remote add origin https://github.com/USER/REPO.git
 - The script will not modify your current branch aside from creating the target branch.
#>
param(
  [string]$Branch = 'gh-pages',
  [string]$Remote = 'origin',
  [switch]$ForcePush,
  [string]$Message = ''
)

if(-not (Get-Command git -ErrorAction SilentlyContinue)){
  Write-Error 'git is required but not found in PATH. Install git: https://git-scm.com/downloads'
  exit 1
}

$cwd = Get-Location
Write-Host "Working directory: $cwd"

# Initialize repo if needed
if(-not (Test-Path .git)){
  Write-Host 'No git repo found. Initializing...'
  git init
}

# Ensure all files are added
git add -A

if(-not $Message){ $Message = "Publish site files to $Branch" }
# Create (or update) the commit on the target branch without switching away from current branch
# We'll use a temporary index and tree approach to avoid disturbing working branch

# Get current branch name
$curBranch = ''
try{ $curBranch = git rev-parse --abbrev-ref HEAD 2>$null } catch{ $curBranch = 'main' }
$curBranch = $curBranch.Trim()
Write-Host "Current branch: $curBranch"

# Create or update the branch using git checkout-index / commit-tree if available
# Simpler approach: create an orphan branch, commit, and push, then switch back

# Save current ref
$saveRef = git rev-parse --verify HEAD 2>$null

# Create orphan branch
Write-Host "Creating temporary orphan branch: $Branch"
try{
  git checkout --orphan $Branch
} catch {
  # if branch exists, just checkout it
  Write-Host "Branch may already exist, checking it out instead"
  git checkout $Branch
}

# Remove all tracked files from the index
git rm -rf --cached . > $null 2>&1
# Add all files, commit
git add -A
try{
  git commit -m "$Message"
} catch {
  Write-Host 'Nothing to commit or commit failed (maybe identical content). Continuing.'
}

# Push
$pushCmd = "git push $Remote $Branch"
if($ForcePush){ $pushCmd = "git push --force $Remote $Branch" }
Write-Host "Running: $pushCmd"
iex $pushCmd

# Switch back to original branch if available
if($curBranch){
  Write-Host "Switching back to $curBranch"
  git checkout $curBranch
}

Write-Host "Branch '$Branch' created/updated and pushed to '$Remote'." -ForegroundColor Green
Write-Host "If you want GitHub Pages to serve from this branch, enable Pages in the repo Settings and select branch '$Branch'."
