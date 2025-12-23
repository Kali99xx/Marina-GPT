# Puter.js Quick Start for Marina-GPT

## One-Line Setup

Add this to your HTML file:
```html
<script src="https://js.puter.com/v2/"></script>
```

That's it! No API keys, no backend, no npm install.

## Basic Usage

### Simple Chat
```javascript
puter.ai.chat("Hello M.A.R.I.N.A", {
    model: "openrouter:cognitivecomputations/dolphin-mistral-24b-venice-edition:free"
}).then(response => console.log(response));
```

### With Streaming (Recommended)
```javascript
const response = await puter.ai.chat("Your question", {
    model: "openrouter:cognitivecomputations/dolphin-mistral-24b-venice-edition:free",
    stream: true
});

for await (const part of response) {
    console.log(part?.text);
}
```

### With System Persona
```javascript
puter.ai.chat("Your question", {
    model: "openrouter:cognitivecomputations/dolphin-mistral-24b-venice-edition:free",
    system: BASE_PERSONA,  // Marina's persona from marina.py
    temperature: 0.7,
    stream: true
});
```

## Available Free Models

All these work with Marina's persona:
- `openrouter:cognitivecomputations/dolphin-mistral-24b-venice-edition:free` (Current)
- `openrouter:cognitivecomputations/dolphin3.0-mistral-24b:free` (Newer)
- `openrouter:cognitivecomputations/dolphin3.0-r1-mistral-24b:free` (Latest)
- `openrouter:qwen/qwen3-coder:free` (Good for code)
- `openrouter:mistralai/devstral-2512:free` (Developer tasks)

## Complete Minimal Example

```html
<!DOCTYPE html>
<html>
<head>
    <script src="https://js.puter.com/v2/"></script>
</head>
<body>
    <input id="input" placeholder="Ask M.A.R.I.N.A..." style="width: 500px">
    <button onclick="ask()">Ask</button>
    <div id="output" style="margin-top: 20px; white-space: pre-wrap"></div>

    <script>
        const BASE_PERSONA = `Your M.A.R.I.N.A persona text here`;

        async function ask() {
            const question = document.getElementById('input').value;
            const output = document.getElementById('output');
            output.textContent = '';

            const response = await puter.ai.chat(question, {
                model: "openrouter:cognitivecomputations/dolphin-mistral-24b-venice-edition:free",
                system: BASE_PERSONA,
                temperature: 0.7,
                stream: true
            });

            for await (const part of response) {
                if (part?.text) output.textContent += part.text;
            }
        }
    </script>
</body>
</html>
```

## Key Differences from marina.py

| Feature | marina.py | Puter.js |
|---------|-----------|----------|
| API Key | Required (`key.txt`) | Not required |
| Rate Limits | Yes (OpenRouter free tier) | No |
| Platform | CLI only | Web only |
| Installation | pip install | Single `<script>` tag |
| Backend | Direct API calls | User-pays model |
| Cost to Developer | $0 but limited | $0 unlimited |

## Next Steps

1. **Try it now**: Open browser console on any webpage, paste this:
   ```javascript
   var script = document.createElement('script');
   script.src = 'https://js.puter.com/v2/';
   document.head.appendChild(script);
   script.onload = () => {
       puter.ai.chat("Hello", {
           model: "openrouter:cognitivecomputations/dolphin-mistral-24b-venice-edition:free"
       }).then(r => console.log(r));
   };
   ```

2. **Build web version**: Use template in `PUTER_INTEGRATION.md`

3. **Deploy**: Host on GitHub Pages, Netlify, or Vercel (free)

## Troubleshooting

**Q: Not working?**  
A: Check browser console for errors. Ensure internet connection.

**Q: Different responses than CLI?**  
A: Puter may apply some filtering. Try different models or adjust persona.

**Q: Need offline support?**  
A: Use original marina.py with API keys. Puter.js requires internet.

## Resources

- Full guide: `PUTER_INTEGRATION.md`
- Original CLI: `marina.py`
- Tutorial: https://developer.puter.com/tutorials/free-unlimited-openrouter-api/
