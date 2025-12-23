#!/bin/bash
# M.A.R.I.N.A GPT AI - Ultimate Edition Launcher
# Kirozaku @ ANDRAX Hacker's Platform

clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║    🔥 M.A.R.I.N.A GPT AI - ULTIMATE EDITION v9.0 🔥          ║
╠═══════════════════════════════════════════════════════════════╣
║  Master Artificial Recognition Intelligence for Network       ║
║  Attacks - Multi-Backend Edition                              ║
║                                                                ║
║  Backends: OpenRouter (11 models) + xAI Grok + Local Ollama  ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo ""
echo "[*] Checking dependencies..."

# Check Python dependencies
if ! python3 -c "import flask, flask_cors, requests" 2>/dev/null; then
    echo "[!] Installing Python dependencies..."
    pip3 install flask flask-cors requests --break-system-packages
fi

# Configure Ollama to use external storage
export OLLAMA_MODELS="/mnt/external_storage/ollama/models"
mkdir -p "$OLLAMA_MODELS"

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo ""
    echo "[!] Ollama not found. Installing..."
    echo "[*] This will install Ollama and store models on /mnt/external_storage"
    echo ""
    curl -fsSL https://ollama.com/install.sh | sh
    
    if [ $? -eq 0 ]; then
        echo "[✓] Ollama installed successfully!"
    else
        echo "[!] Ollama installation failed. You can install manually later."
    fi
fi

# Check if Ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "[*] Starting Ollama service..."
    OLLAMA_MODELS="/mnt/external_storage/ollama/models" ollama serve > /tmp/ollama.log 2>&1 &
    sleep 2
    echo "[✓] Ollama service started"
else
    echo "[✓] Ollama is already running"
fi

# Check if dolphin-mistral model exists
if [ -d "/mnt/external_storage/ollama/models" ]; then
    if ! ls /mnt/external_storage/ollama/models/manifests/*/library/dolphin-mistral* 2>/dev/null | grep -q .; then
        echo ""
        echo "[*] Downloading Dolphin Mistral model (7GB uncensored model)..."
        echo "[*] This will take a few minutes depending on your connection..."
        OLLAMA_MODELS="/mnt/external_storage/ollama/models" ollama pull dolphin-mistral
    else
        echo "[✓] Dolphin Mistral model already available"
    fi
fi

echo ""
echo "[*] Starting Marina backend server..."
python3 /home/kali/Marina-GPT/marina-backend.py &
BACKEND_PID=$!
sleep 2

# Check if backend started successfully
if kill -0 $BACKEND_PID 2>/dev/null; then
    echo "[✓] Backend server running (PID: $BACKEND_PID)"
else
    echo "[!] Backend server failed to start"
    exit 1
fi

echo ""
echo "[*] Opening Marina Ultimate in Firefox..."
firefox /home/kali/Marina-GPT/marina-ultimate.html &

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  M.A.R.I.N.A is now running!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  🌐 Frontend: Firefox (marina-ultimate.html)"
echo "  ⚙️  Backend:  http://localhost:5000"
echo "  💾 Ollama:   /mnt/external_storage/ollama/models"
echo ""
echo "  Available Backends:"
echo "    • OpenRouter (11 FREE unlimited models)"
echo "    • xAI Grok (Elon's AI)"
echo "    • Local Ollama (Offline, unlimited)"
echo ""
echo "  Default Model: DeepSeek V3.1 (truly unlimited)"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Press Ctrl+C to stop the backend server"
echo ""

# Wait for backend to be stopped
wait $BACKEND_PID
