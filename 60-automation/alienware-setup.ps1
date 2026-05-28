# ============================================================
# Hermes Agent — Alienware Setup Script
# ============================================================
# Run this on the Alienware 17R4 laptop (192.168.8.21)
# Configures Ollama for network access, pulls hermes3,
# clones the vault, and optionally installs Hermes Agent.
#
# Decision refs: D-013, D-014, D-015
# Created: 2026-05-28 by claude_cowork
# ============================================================

Write-Host "=== Hermes Agent — Alienware Setup ===" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------------
# Step 1: Configure Ollama to listen on all interfaces
# ----------------------------------------------------------
Write-Host "[1/5] Configuring Ollama to listen on 0.0.0.0..." -ForegroundColor Yellow

# Set the environment variable permanently for the current user
[Environment]::SetEnvironmentVariable("OLLAMA_HOST", "0.0.0.0", "User")

# Set context length to 64K (Hermes Agent minimum requirement)
[Environment]::SetEnvironmentVariable("OLLAMA_CONTEXT_LENGTH", "64000", "User")

# Also set both for the current session
$env:OLLAMA_HOST = "0.0.0.0"
$env:OLLAMA_CONTEXT_LENGTH = "64000"

Write-Host "  OLLAMA_HOST set to 0.0.0.0 (all interfaces)" -ForegroundColor Green
Write-Host "  OLLAMA_CONTEXT_LENGTH set to 64000 (Hermes Agent minimum)" -ForegroundColor Green
Write-Host "  Ollama will need a restart to pick this up." -ForegroundColor Gray
Write-Host ""

# ----------------------------------------------------------
# Step 2: Restart Ollama service
# ----------------------------------------------------------
Write-Host "[2/5] Restarting Ollama..." -ForegroundColor Yellow

# Stop Ollama if running (handles both service and tray app)
$ollamaProcess = Get-Process -Name "ollama*" -ErrorAction SilentlyContinue
if ($ollamaProcess) {
    Stop-Process -Name "ollama*" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "  Stopped existing Ollama process." -ForegroundColor Gray
}

# Start Ollama serve in background
Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
Start-Sleep -Seconds 3
Write-Host "  Ollama restarted with network access enabled." -ForegroundColor Green
Write-Host ""

# ----------------------------------------------------------
# Step 3: Pull hermes3:8b model
# ----------------------------------------------------------
Write-Host "[3/5] Pulling hermes3:8b model (this may take a while)..." -ForegroundColor Yellow
Write-Host "  This is Nous Research's model built for Hermes Agent." -ForegroundColor Gray

& ollama pull hermes3

if ($LASTEXITCODE -eq 0) {
    Write-Host "  hermes3:8b pulled successfully." -ForegroundColor Green
} else {
    Write-Host "  WARNING: Failed to pull hermes3. Check network/disk space." -ForegroundColor Red
    Write-Host "  You can retry manually: ollama pull hermes3" -ForegroundColor Gray
}
Write-Host ""

# ----------------------------------------------------------
# Step 4: Clone the Hermes vault via git
# ----------------------------------------------------------
Write-Host "[4/5] Setting up vault git sync..." -ForegroundColor Yellow

$vaultPath = "C:\Hermes"

if (Test-Path $vaultPath) {
    Write-Host "  $vaultPath already exists — skipping clone." -ForegroundColor Gray
    Write-Host "  To sync: cd $vaultPath && git pull" -ForegroundColor Gray
} else {
    Write-Host "  Where is your git remote for the Hermes vault?" -ForegroundColor Gray
    Write-Host "  You'll need to set up a remote first if you haven't." -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Option A — If you have a git remote (GitHub/Gitea/etc):" -ForegroundColor White
    Write-Host "    git clone <remote-url> $vaultPath" -ForegroundColor White
    Write-Host ""
    Write-Host "  Option B — Direct clone from desktop over network:" -ForegroundColor White
    Write-Host "    git clone //DESKTOP-NAME/20 - Project Hermes $vaultPath" -ForegroundColor White
    Write-Host ""
    Write-Host "  Option C — Manual copy + git init:" -ForegroundColor White
    Write-Host "    Copy E:\20 - Project Hermes from desktop to $vaultPath" -ForegroundColor White
    Write-Host "    Then set up a shared remote both machines push to." -ForegroundColor White
}
Write-Host ""

# ----------------------------------------------------------
# Step 5: Install Hermes Agent (optional — for dual-machine setup)
# ----------------------------------------------------------
Write-Host "[5/5] Hermes Agent installation..." -ForegroundColor Yellow
Write-Host "  Per D-013, Hermes Agent runs on both machines." -ForegroundColor Gray

$installAgent = Read-Host "  Install Hermes Agent on the Alienware now? (y/n)"
if ($installAgent -eq "y") {
    Write-Host "  Running Hermes Agent installer..." -ForegroundColor Yellow
    Invoke-RestMethod https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1 | Invoke-Expression
} else {
    Write-Host "  Skipped. Run this later to install:" -ForegroundColor Gray
    Write-Host '  irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1 | iex' -ForegroundColor White
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Verify Ollama is accessible from desktop:" -ForegroundColor White
Write-Host "     curl http://192.168.8.21:11434/api/tags" -ForegroundColor White
Write-Host "  2. If firewall blocks it, run:" -ForegroundColor White
Write-Host '     netsh advfirewall firewall add rule name="Ollama" dir=in action=allow protocol=TCP localport=11434' -ForegroundColor White
Write-Host "  3. Set up git remote for vault sync between machines" -ForegroundColor White
Write-Host "  4. Update Hermes Agent config.yaml on desktop (see 60-automation/hermes-config-template.yaml)" -ForegroundColor White
