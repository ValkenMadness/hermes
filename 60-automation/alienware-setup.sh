#!/bin/bash
# ============================================================
# Hermes Agent — Alienware Setup (Ubuntu/Bash)
# ============================================================
# Run this on the Alienware 17R4 (192.168.8.21) via SSH
# Configures Ollama for network access, pulls hermes3,
# and prepares for vault git sync.
#
# Decision refs: D-013, D-014, D-015
# Created: 2026-05-28 by claude_cowork
# ============================================================

set -e

echo "=== Hermes Agent — Alienware Setup ==="
echo ""

# ----------------------------------------------------------
# Step 1: Configure Ollama to listen on all interfaces
# ----------------------------------------------------------
echo "[1/4] Configuring Ollama to listen on 0.0.0.0 with 64K context..."

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "  ERROR: Ollama not found. Install it first:"
    echo "    curl -fsSL https://ollama.com/install.sh | sh"
    exit 1
fi

# Check if Ollama runs as a systemd service
if systemctl is-active --quiet ollama 2>/dev/null; then
    echo "  Ollama is running as a systemd service."

    # Create override file for environment variables
    sudo mkdir -p /etc/systemd/system/ollama.service.d
    sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_CONTEXT_LENGTH=64000"
EOF

    echo "  Created systemd override with OLLAMA_HOST=0.0.0.0 and OLLAMA_CONTEXT_LENGTH=64000"

    # Reload and restart
    sudo systemctl daemon-reload
    sudo systemctl restart ollama
    echo "  Ollama restarted with network access enabled."
else
    echo "  Ollama is not running as a systemd service."
    echo "  Setting environment variables in ~/.bashrc..."

    # Add to .bashrc if not already there
    if ! grep -q "OLLAMA_HOST" ~/.bashrc; then
        echo 'export OLLAMA_HOST=0.0.0.0' >> ~/.bashrc
    fi
    if ! grep -q "OLLAMA_CONTEXT_LENGTH" ~/.bashrc; then
        echo 'export OLLAMA_CONTEXT_LENGTH=64000' >> ~/.bashrc
    fi

    export OLLAMA_HOST=0.0.0.0
    export OLLAMA_CONTEXT_LENGTH=64000

    echo "  You'll need to restart Ollama manually:"
    echo "    ollama serve &"
fi

echo ""

# ----------------------------------------------------------
# Step 2: Pull hermes3 model
# ----------------------------------------------------------
echo "[2/4] Pulling hermes3 model (this may take a while)..."

ollama pull hermes3

echo "  hermes3 pulled successfully."
echo ""

# ----------------------------------------------------------
# Step 3: Verify Ollama is listening on network
# ----------------------------------------------------------
echo "[3/4] Verifying Ollama is accessible..."

sleep 2

if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "  Ollama is responding on localhost."
else
    echo "  WARNING: Ollama not responding. It may need a moment to start."
fi

# Check if firewall might block access
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null | head -1)
    if echo "$UFW_STATUS" | grep -q "active"; then
        echo "  UFW firewall is active. Adding rule for port 11434..."
        sudo ufw allow 11434/tcp comment "Ollama API"
        echo "  Firewall rule added."
    else
        echo "  UFW firewall is inactive — no rule needed."
    fi
fi

echo ""

# ----------------------------------------------------------
# Step 4: GPU info
# ----------------------------------------------------------
echo "[4/4] GPU check..."

if command -v nvidia-smi &> /dev/null; then
    echo "  GPU detected:"
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader 2>/dev/null || echo "  Could not query GPU details."
else
    echo "  nvidia-smi not found — GPU may not be configured."
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. From your desktop, verify connectivity:"
echo "     curl http://192.168.8.21:11434/api/tags"
echo ""
echo "  2. Check hermes3 is loaded:"
echo "     ollama list"
echo ""
echo "  3. Set up vault git sync (when ready):"
echo "     mkdir -p ~/hermes && cd ~/hermes"
echo "     git clone <your-remote-url> ."
echo ""
echo "  4. Install Hermes Agent on this machine (optional, for D-013):"
echo "     curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
