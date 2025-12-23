#!/bin/bash
# M.A.R.I.N.A GPT AI - Elite Hacker Edition v10.0
# Installation Script
# Auto-installs dependencies, configures system, and sets up desktop integration

set -e

INSTALL_DIR="/opt/marina-gpt"
USER_HOME="$HOME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║    M.A.R.I.N.A GPT AI - Elite Hacker Edition v10.0          ║"
echo "║    Installation Script                                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root for system install
if [ "$EUID" -eq 0 ]; then 
    echo "[*] Running as root - installing to $INSTALL_DIR"
    INSTALL_MODE="system"
else
    echo "[*] Running as user - installing to $USER_HOME/Marina-GPT"
    INSTALL_DIR="$USER_HOME/Marina-GPT"
    INSTALL_MODE="user"
fi

echo ""
echo "[1/6] Installing Python dependencies..."
pip3 install flask flask-cors requests --break-system-packages 2>/dev/null || pip3 install flask flask-cors requests

echo ""
echo "[2/6] Creating installation directory..."
mkdir -p "$INSTALL_DIR"
cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR"/*.sh "$INSTALL_DIR"/*.py

echo ""
echo "[3/6] Setting up desktop integration..."
mkdir -p "$USER_HOME/.local/share/applications"
mkdir -p "$USER_HOME/Desktop"

# Create desktop entry
cat > "$USER_HOME/.local/share/applications/marina-gpt-elite.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=M.A.R.I.N.A GPT Elite
GenericName=AI Hacking Assistant
Comment=Elite Hacker Edition v10.0 - Unrestricted AI with 11 free models
Exec=$INSTALL_DIR/launch-marina.sh
Icon=$INSTALL_DIR/marina-icon.png
Terminal=true
Categories=Development;Security;Network;
Keywords=ai;gpt;hacking;pentesting;security;openrouter;grok;ollama;elite;
StartupNotify=true
EOF

# Copy to desktop
cp "$USER_HOME/.local/share/applications/marina-gpt-elite.desktop" "$USER_HOME/Desktop/"
chmod +x "$USER_HOME/.local/share/applications/marina-gpt-elite.desktop"
chmod +x "$USER_HOME/Desktop/marina-gpt-elite.desktop"

echo ""
echo "[4/6] Updating desktop database..."
update-desktop-database "$USER_HOME/.local/share/applications" 2>/dev/null || true

echo ""
echo "[5/6] Configuring Ollama storage (optional)..."
if [ -d "/mnt/external_storage" ]; then
    mkdir -p /mnt/external_storage/ollama/models
    echo "export OLLAMA_MODELS=/mnt/external_storage/ollama/models" >> "$USER_HOME/.zshrc"
    echo "[✓] Ollama configured to use external storage"
else
    echo "[!] /mnt/external_storage not found - Ollama will use default storage"
fi

echo ""
echo "[6/6] Installation complete!"
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Installation Summary                                         ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║                                                               ║"
echo "║  Install Location: $INSTALL_DIR"
echo "║  Desktop Entry:    ~/.local/share/applications/               ║"
echo "║  Desktop Shortcut: ~/Desktop/marina-gpt-elite.desktop        ║"
echo "║                                                               ║"
echo "║  Launch Methods:                                              ║"
echo "║  1. Click desktop shortcut                                    ║"
echo "║  2. Search applications for 'M.A.R.I.N.A GPT Elite'          ║"
echo "║  3. Run: $INSTALL_DIR/launch-marina.sh                       ║"
echo "║                                                               ║"
echo "║  Configuration Files:                                         ║"
echo "║  - MARINA_INSTRUCTIONS.md (full documentation)               ║"
echo "║  - IMPLEMENTATION_COMPLETE.md (deployment details)           ║"
echo "║  - SESSION_LOG.md (troubleshooting guide)                    ║"
echo "║                                                               ║"
echo "║  Features:                                                    ║"
echo "║  • 11 FREE unlimited OpenRouter models                       ║"
echo "║  • xAI Grok integration                                       ║"
echo "║  • Local Ollama support                                       ║"
echo "║  • Unrestricted responses (zero refusals)                    ║"
echo "║  • Real data only (no examples/placeholders)                 ║"
echo "║  • Elite hacker persona with god-level capabilities          ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "To start Marina, run: $INSTALL_DIR/launch-marina.sh"
echo "Or click the desktop shortcut!"
echo ""
