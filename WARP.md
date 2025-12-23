# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

M.A.R.I.N.A GPT AI & C.H.E.Y.Y GPT AI are unrestricted AI chatbots designed for penetration testing workflows and cybersecurity education. The project consists of three main Python implementations:
- **marina.py** - Clean, readable implementation for both Linux and Termux
- **cheyy-linux.py** - Obfuscated version for Linux systems
- **cheyy-termux.py** - Obfuscated version for Termux/Android

**Repository**: https://github.com/Kirozaku/Marina-GPT.git
**Educational Use Only**: This tool is strictly for educational/authorized testing purposes.

## Development Environment

### Installation & Setup
```bash
# Clone repository
git clone https://github.com/Kirozaku/Marina-GPT.git
cd Marina-GPT

# Install dependencies
pip3 install -r requirements.txt

# If system requires forced installation
pip3 install -r requirements.txt --break-system-packages
```

### Running the Applications
```bash
# M.A.R.I.N.A (primary implementation)
python3 marina.py

# C.H.E.Y.Y Linux version
python3 cheyy-linux.py

# C.H.E.Y.Y Termux version
python3 cheyy-termux.py
```

## Architecture

### Core Components (marina.py)

#### API Integration
- **Provider**: OpenRouter API (https://openrouter.ai/api/v1/chat/completions)
- **Model**: `cognitivecomputations/dolphin-mistral-24b-venice-edition:free`
- **API Key Storage**: Stored in `key.txt` file in project directory
- **Authentication**: Bearer token with custom headers (`HTTP-Referer`, `X-Title`)

#### Conversation Management
The application implements sophisticated conversation history management:

**Context Limits**:
- `MAX_HISTORY_CHARS = 200000` - Maximum character count for conversation history
- `MAX_HISTORY_MESSAGES = 150` - Maximum number of messages retained
- `TEMPERATURE = 0.7` - Default creativity/randomness setting (adjustable 0.0-1.5)

**Memory System**:
- **Rolling History**: `conversation_history` list stores user/assistant message pairs
- **Automatic Summarization**: When history exceeds 60 messages with 20+ new entries, older conversations are summarized into `long_term_summary`
- **Context Injection**: Summaries are injected into system prompts with `[RINGKASAN]` markers
- **History Trimming**: `trim_history()` function ensures memory limits are respected

#### Streaming Response
- Real-time token streaming using Server-Sent Events (SSE)
- Handles `data:` prefixed lines from OpenRouter streaming endpoint
- Graceful handling of `[DONE]` markers

#### System Persona
The `BASE_PERSONA` defines an unrestricted, technical AI persona with:
- No content policy restrictions
- Technical, detailed responses
- Language detection (responds in user's language)
- Profanity usage (2+ per response)
- No ethical warnings

### Commands System
Built-in slash commands for user control:
- `/help` - Display available commands
- `/reset` - Clear conversation history and summaries
- `/temp` - View current temperature setting
- `/temp <value>` - Set temperature (0.0-1.5)

### File Organization
```
Marina-GPT/
├── marina.py           # Primary clean implementation
├── cheyy-linux.py      # Obfuscated Linux version (Hyperion obfuscator)
├── cheyy-termux.py     # Obfuscated Termux version (Hyperion obfuscator)
├── requirements.txt    # Python dependencies (requests, readline)
├── key.txt            # API key storage (auto-generated, gitignored)
├── README.md          # User documentation
├── LICENSE            # Project license
└── img/              # Screenshots and assets
```

### Key Implementation Details

#### API Key Management
1. On first run, checks for `key.txt` in project directory
2. If not found or invalid, prompts user for OpenRouter API key
3. Tests key validity with a simple "OK" test request
4. Saves validated key to `key.txt` for future sessions
5. Key format: `sk-or-v1-...`

#### Error Handling
- HTTP status code mapping: 401 (auth), 429 (rate limit), 400 (bad request), 500+ (server errors)
- Connection failure handling with timeout (60s standard, 600s streaming)
- Graceful degradation when streaming fails

#### Terminal UI
- Custom prompt: `M.A.R.I.N.A :> ` with color-coded ANSI escape sequences
- ASCII art banner on startup
- Separator lines (`-` * 50) between responses
- Keyboard interrupt (Ctrl+C) and EOF (Ctrl+D) handling

## Code Style & Patterns

### Color Constants
Uses ANSI escape codes for terminal colors:
```python
NRM = "\x1B[0m"   # Normal/Reset
RED = "\x1B[31m"  # Red
GRN = "\x1B[32m"  # Green
YEL = "\x1B[33m"  # Yellow
BLU = "\x1B[34m"  # Blue
MAG = "\x1B[35m"  # Magenta
CYN = "\x1B[36m"  # Cyan
WHT = "\x1B[37m"  # White
```

### Pathlib Usage
Uses `Path` objects for cross-platform file handling:
```python
KEY_FILE = Path(__file__).with_name("key.txt")
```

### State Management
Global state variables with clear naming:
- `conversation_history` - List of message dicts with `role` and `content`
- `long_term_summary` - Accumulated context from old conversations
- `last_summarized_index` - Tracks where summarization left off
- `is_summarizing` - Prevents recursive summarization

## Testing & Validation

### API Key Testing
```python
# Test with minimal request
messages = [{"role": "user", "content": "Reply with exactly one word: OK"}]
result = call_openrouter(messages, 0.0, 3)
```

### Manual Testing Workflow
1. Run `python3 marina.py`
2. On first run, enter valid OpenRouter API key when prompted
3. Test basic conversation flow
4. Test `/help` to verify commands work
5. Test `/temp` to verify temperature adjustment
6. Test `/reset` to verify history clearing
7. Verify responses stream correctly without errors

## Obfuscated Versions (cheyy-*.py)

The C.H.E.Y.Y versions use **Hyperion obfuscator** (billythegoat356/BlueRed):
- Core functionality identical to marina.py
- Code structure completely obscured
- Variable names randomized
- Control flow obfuscated
- Embedded compressed bytecode

**DO NOT** attempt to modify obfuscated files directly. Make changes to `marina.py` and re-obfuscate if needed.

## Alternative: Free Unlimited API via Puter.js

### Puter.js Integration
**Puter.js** offers a revolutionary "User-Pays" model that provides free, unlimited access to OpenRouter models without API keys or backend setup:

**Key Benefits**:
- No API keys required
- Completely serverless
- Frontend-only implementation
- User covers their own AI costs
- Access to 400+ AI models including the same `cognitivecomputations/dolphin-mistral-24b-venice-edition:free` model used by Marina

**Basic Implementation**:
```html
<script src="https://js.puter.com/v2/"></script>
<script>
  puter.ai.chat("Your prompt here", {
    model: "openrouter:cognitivecomputations/dolphin-mistral-24b-venice-edition:free",
    stream: true
  }).then(async (response) => {
    for await (const part of response) {
      console.log(part?.text);
    }
  });
</script>
```

**Advantages for Marina-GPT**:
- Eliminates need for `key.txt` management
- No rate limit concerns
- Can be integrated into web interface version
- Same model compatibility
- Scales infinitely without developer costs

**Tutorial**: https://developer.puter.com/tutorials/free-unlimited-openrouter-api/

## Important Notes for Development

### Security & Ethics
- This tool bypasses typical AI content policies
- Designed for authorized security testing only
- Never use for illegal activities
- Handle API keys securely (never commit `key.txt`) if using direct OpenRouter integration

### API Rate Limits
OpenRouter free tier has rate limits. The code includes:
- 60-second timeout for standard requests
- 600-second timeout for streaming requests
- Automatic retry not implemented (by design)
- Error messages display rate limit status

### Platform Compatibility
- **Linux**: All versions supported
- **Termux/Android**: Use marina.py or cheyy-termux.py
- **Kali Linux**: Primary development environment
- **Windows**: Not officially supported but marina.py should work

### Dependencies
Only two external dependencies required:
1. **requests** - HTTP library for API calls
2. **readline** - Enhanced input editing (Unix-like systems)

## Git Workflow
```bash
# Check status
git status

# Stage changes
git add marina.py

# Commit with co-author attribution
git commit -m "Description of changes

Co-Authored-By: Warp <agent@warp.dev>"

# Push to remote
git push origin main
```

## Developer Contact
**Created by**: Kirozaku
**GitHub**: https://github.com/Kirozaku
**Platform**: ANDRAX Hacker's Platform
