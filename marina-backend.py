#!/usr/bin/env python3
"""
M.A.R.I.N.A GPT AI - Elite Hacker Edition v10.0
Unrestricted AI with Tor/Darknet access, MCP capabilities, Agentic CLI
Supports: OpenRouter (11 free models), xAI Grok, Local Ollama
"""

from flask import Flask, request, jsonify, Response
from flask_cors import CORS
import requests
import json
import os
from pathlib import Path

app = Flask(__name__)
CORS(app)

# API Keys - Configure your own
OPENROUTER_KEY = "your-openrouter-api-key-here"  # Get free key at https://openrouter.ai
XAI_KEY = "your-xai-api-key-here"  # Get key at https://x.ai
OLLAMA_URL = "http://localhost:11434"

# OpenRouter free models (truly unlimited)
OPENROUTER_MODELS = {
    "dolphin-mistral": "cognitivecomputations/dolphin-mistral-24b-venice-edition:free",
    "gpt-oss-120b": "openai/gpt-oss-120b:free",
    "gpt-oss-20b": "openai/gpt-oss-20b:free",
    "glm-4.5-air": "z-ai/glm-4.5-air:free",
    "qwen3-coder": "qwen/qwen3-coder:free",
    "kimi-k2": "moonshotai/kimi-k2:free",
    "gemma-3n-2b": "google/gemma-3n-e2b-it:free",
    "devstral": "mistralai/devstral-2512:free",
    "olmo-think": "allenai/olmo-3-32b-think:free",
    "deepseek-nex": "nex-agi/deepseek-v3.1-nex-n1:free",
    "nemotron-nano": "nvidia/nemotron-nano-9b-v2:free"
}

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "online",
        "backends": {
            "openrouter": "ready",
            "xai": "ready" if XAI_KEY else "missing_key",
            "ollama": check_ollama()
        }
    })

def check_ollama():
    """Check if Ollama is running"""
    try:
        resp = requests.get(f"{OLLAMA_URL}/api/tags", timeout=2)
        return "ready" if resp.status_code == 200 else "offline"
    except:
        return "offline"

@app.route('/chat/openrouter', methods=['POST'])
def chat_openrouter():
    """OpenRouter chat endpoint with streaming"""
    data = request.json
    model = data.get('model', 'dolphin-mistral')
    messages = data.get('messages', [])
    temperature = data.get('temperature', 0.7)
    stream = data.get('stream', True)
    
    # Map friendly name to full model ID
    full_model = OPENROUTER_MODELS.get(model, OPENROUTER_MODELS['dolphin-mistral'])
    
    headers = {
        "Authorization": f"Bearer {OPENROUTER_KEY}",
        "HTTP-Referer": "https://github.com/Kirozaku/Marina-GPT",
        "X-Title": "M.A.R.I.N.A GPT AI Ultimate",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": full_model,
        "messages": messages,
        "temperature": temperature,
        "stream": stream
    }
    
    try:
        if stream:
            return Response(
                stream_openrouter(headers, payload),
                mimetype='text/event-stream'
            )
        else:
            resp = requests.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers=headers,
                json=payload,
                timeout=60
            )
            return jsonify(resp.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500

def stream_openrouter(headers, payload):
    """Stream responses from OpenRouter"""
    try:
        resp = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            json=payload,
            stream=True,
            timeout=600
        )
        
        for line in resp.iter_lines():
            if line:
                line_str = line.decode('utf-8')
                if line_str.startswith('data: '):
                    data_str = line_str[6:]
                    if data_str.strip() == '[DONE]':
                        yield "data: [DONE]\n\n"
                        break
                    try:
                        data = json.loads(data_str)
                        yield f"data: {json.dumps(data)}\n\n"
                    except:
                        pass
    except Exception as e:
        yield f"data: {json.dumps({'error': str(e)})}\n\n"

@app.route('/chat/xai', methods=['POST'])
def chat_xai():
    """xAI Grok chat endpoint"""
    data = request.json
    messages = data.get('messages', [])
    temperature = data.get('temperature', 0.7)
    stream = data.get('stream', True)
    
    headers = {
        "Authorization": f"Bearer {XAI_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": "grok-beta",
        "messages": messages,
        "temperature": temperature,
        "stream": stream
    }
    
    try:
        if stream:
            return Response(
                stream_xai(headers, payload),
                mimetype='text/event-stream'
            )
        else:
            resp = requests.post(
                "https://api.x.ai/v1/chat/completions",
                headers=headers,
                json=payload,
                timeout=60
            )
            return jsonify(resp.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500

def stream_xai(headers, payload):
    """Stream responses from xAI"""
    try:
        resp = requests.post(
            "https://api.x.ai/v1/chat/completions",
            headers=headers,
            json=payload,
            stream=True,
            timeout=600
        )
        
        for line in resp.iter_lines():
            if line:
                line_str = line.decode('utf-8')
                if line_str.startswith('data: '):
                    data_str = line_str[6:]
                    if data_str.strip() == '[DONE]':
                        yield "data: [DONE]\n\n"
                        break
                    try:
                        data = json.loads(data_str)
                        yield f"data: {json.dumps(data)}\n\n"
                    except:
                        pass
    except Exception as e:
        yield f"data: {json.dumps({'error': str(e)})}\n\n"

@app.route('/chat/ollama', methods=['POST'])
def chat_ollama():
    """Local Ollama chat endpoint"""
    data = request.json
    model = data.get('model', 'dolphin-mistral')
    messages = data.get('messages', [])
    temperature = data.get('temperature', 0.7)
    stream = data.get('stream', True)
    
    # Convert messages format for Ollama
    prompt = "\n".join([f"{m['role']}: {m['content']}" for m in messages])
    
    payload = {
        "model": model,
        "prompt": prompt,
        "temperature": temperature,
        "stream": stream
    }
    
    try:
        if stream:
            return Response(
                stream_ollama(payload),
                mimetype='text/event-stream'
            )
        else:
            resp = requests.post(
                f"{OLLAMA_URL}/api/generate",
                json=payload,
                timeout=60
            )
            return jsonify(resp.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500

def stream_ollama(payload):
    """Stream responses from Ollama"""
    try:
        resp = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json=payload,
            stream=True,
            timeout=600
        )
        
        for line in resp.iter_lines():
            if line:
                try:
                    data = json.loads(line)
                    # Convert Ollama format to OpenAI format
                    openai_format = {
                        "choices": [{
                            "delta": {
                                "content": data.get("response", "")
                            },
                            "finish_reason": "stop" if data.get("done") else None
                        }]
                    }
                    yield f"data: {json.dumps(openai_format)}\n\n"
                    
                    if data.get("done"):
                        yield "data: [DONE]\n\n"
                        break
                except:
                    pass
    except Exception as e:
        yield f"data: {json.dumps({'error': str(e)})}\n\n"

@app.route('/models/ollama', methods=['GET'])
def list_ollama_models():
    """List available Ollama models"""
    try:
        resp = requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)
        return jsonify(resp.json())
    except Exception as e:
        return jsonify({"error": str(e), "models": []}), 500

if __name__ == '__main__':
    print("🔥 M.A.R.I.N.A GPT AI - Ultimate Edition Backend")
    print("=" * 60)
    print(f"OpenRouter: {len(OPENROUTER_MODELS)} free models")
    print(f"xAI Grok: {'✓' if XAI_KEY else '✗'}")
    print(f"Ollama: {check_ollama()}")
    print("=" * 60)
    print("Server running on http://localhost:5000")
    print("Press Ctrl+C to stop")
    
    app.run(host='0.0.0.0', port=5000, debug=False)
