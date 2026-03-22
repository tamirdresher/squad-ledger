# scripts/squad-init.ps1 — Run once after cloning the repo.
# Bash equivalent: scripts/squad-init.sh (see inline comments)

$RepoName  = Split-Path (git rev-parse --show-toplevel) -Leaf   # Bash: REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
$SquadRepo = "$HOME/squad-state/$RepoName.git"                  # Bash: SQUAD_REPO="$HOME/squad-state/${REPO_NAME}.git"

# Create the local squad state repo if it doesn't exist
if (-not (Test-Path $SquadRepo)) {
    Write-Host "Creating local squad state repo at $SquadRepo"
    New-Item -ItemType Directory -Path $SquadRepo -Force | Out-Null
    git init --bare $SquadRepo
}

# Clone it into .squad/
if (-not (Test-Path ".squad")) {
    git clone $SquadRepo .squad
}

# Keep .squad/ out of the main repo
$ExcludeFile = ".git/info/exclude"
if (-not (Get-Content $ExcludeFile -ErrorAction SilentlyContinue | Select-String "^\.squad$")) {
    Add-Content $ExcludeFile ".squad"
}

Write-Host "✔ Squad state initialized at $SquadRepo"