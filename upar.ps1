# ==================================================
#  u.p.a.r — Update, Push And Rebuild APK
#  Usage: .\upar.ps1
#     or: .\upar.ps1 "Your commit message here"
# ==================================================

param(
    [string]$CommitMessage = ""
)

$Red    = "Red"
$Green  = "Green"
$Yellow = "Yellow"
$Cyan   = "Cyan"
$White  = "White"

Write-Host ""
Write-Host "================================================" -ForegroundColor $Cyan
Write-Host "  u.p.a.r  —  Update · Push · And · Rebuild" -ForegroundColor $Cyan
Write-Host "================================================" -ForegroundColor $Cyan
Write-Host ""

# Make sure we are in the right directory
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

# ── Step 1: Stage all changes ──────────────────────
Write-Host "[1/3] Staging all changes..." -ForegroundColor $Yellow
git add .

# Check for staged changes
$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Host ""
    Write-Host "  Nothing to commit — working tree is already clean." -ForegroundColor $Green
    Write-Host ""
    Write-Host "  Pushing anyway in case remote is behind..." -ForegroundColor $Yellow
} else {
    Write-Host "  Staged files:" -ForegroundColor $White
    $staged | ForEach-Object { Write-Host "    + $_" -ForegroundColor $White }

    # ── Step 2: Commit ───────────────────────────────
    Write-Host ""
    Write-Host "[2/3] Committing..." -ForegroundColor $Yellow

    $timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm"
    $finalMsg   = if ($CommitMessage) { $CommitMessage } else { "Update: $timestamp" }

    git commit -m $finalMsg
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "  ERROR: Commit failed. Fix the issues above and try again." -ForegroundColor $Red
        exit 1
    }
    Write-Host "  Committed: $finalMsg" -ForegroundColor $Green
}

# ── Step 3: Push to GitHub ─────────────────────────
Write-Host ""
Write-Host "[3/3] Pushing to GitHub (main)..." -ForegroundColor $Yellow
git push origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  ERROR: Push failed. Check your internet connection or branch protection rules." -ForegroundColor $Red
    exit 1
}

# ── Done ───────────────────────────────────────────
Write-Host ""
Write-Host "================================================" -ForegroundColor $Green
Write-Host "  DONE!  APK rebuild triggered on GitHub." -ForegroundColor $Green
Write-Host "================================================" -ForegroundColor $Green
Write-Host ""
Write-Host "  Track build progress:" -ForegroundColor $Cyan
Write-Host "  https://github.com/Uzair625/hunger-point-app/actions" -ForegroundColor $Cyan
Write-Host ""
Write-Host "  Download APK after build:" -ForegroundColor $Cyan
Write-Host "  GitHub Actions > Latest run > Artifacts" -ForegroundColor $Cyan
Write-Host ""
