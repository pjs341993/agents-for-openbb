# Quick Verification Guide

This document helps you verify that your OpenBB agent is set up correctly before integrating it with OpenBB Desktop or Web.

## Step 1: Verify Agent is Running

After starting your agent with:
```bash
cd 30-vanilla-agent-raw-widget-data  # or your chosen agent
poetry run uvicorn vanilla_agent_raw_context.main:app --port 7777 --reload
```

You should see output similar to:
```
INFO:     Started server process [12345]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:7777 (Press CTRL+C to quit)
```

## Step 2: Test Agent Endpoints

### Test 1: Check the Agent Configuration

Open your browser or use curl to test the `/agents.json` endpoint:

```bash
curl http://localhost:7777/agents.json
```

Expected response (example from vanilla-agent-raw-context):
```json
{
  "vanilla_agent_raw_context": {
    "name": "Vanilla Agent Raw Context",
    "description": "A vanilla agent that automatically retrieves widget data and passes it as raw context to the LLM.",
    "image": "https://github.com/OpenBB-finance/copilot-for-terminal-pro/assets/14093308/7da2a512-93b9-478d-90bc-b8c3dd0cabcf",
    "endpoints": {
      "query": "/v1/query"
    },
    "features": {
      "streaming": true,
      "widget-dashboard-select": true,
      "widget-dashboard-search": false
    }
  }
}
```

✅ **If you see valid JSON** → Agent configuration is working!  
❌ **If you get an error** → Check that the agent is running and on the correct port.

### Test 2: Check the API Documentation

Visit: http://localhost:7777/docs

You should see an interactive API documentation page (Swagger UI) with:
- GET `/agents.json` endpoint
- POST `/v1/query` endpoint

✅ **If you see the documentation** → FastAPI is working correctly!  
❌ **If you get 404** → Check your agent's `main.py` for correct FastAPI setup.

### Test 3: Test a Simple Query (Optional)

You can test the query endpoint using curl:

```bash
curl -X POST http://localhost:7777/v1/query \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "human",
        "content": "Hello! What is your name?"
      }
    ]
  }'
```

Expected: You should see a stream of Server-Sent Events (SSE) with the agent's response.

⚠️ **Note**: This test requires a valid API key (OpenAI, Anthropic, etc.) set in your environment.

## Step 3: Common Issues

### Issue: Port Already in Use

**Error**: `[Errno 48] error while attempting to bind on address ('127.0.0.1', 7777): address already in use`

**Solution**: 
1. Use a different port: `--port 7778`
2. Or stop the process using port 7777:
   ```bash
   lsof -ti:7777 | xargs kill -9  # macOS/Linux
   ```

### Issue: Module Not Found

**Error**: `ModuleNotFoundError: No module named 'openai'` or similar

**Solution**: Install dependencies first:
```bash
poetry install --no-root
```

### Issue: API Key Not Set

**Error**: `openai.OpenAIError: The api_key client option must be set`

**Solution**: Set your API key:
```bash
export OPENAI_API_KEY=your-key-here
```

Or create a `.env` file in the project root:
```
OPENAI_API_KEY=your-key-here
```

## Step 4: Test OpenBB Integration

Once your agent passes the above tests, you're ready to integrate with OpenBB!

### For OpenBB Desktop

1. Open OpenBB Desktop/Terminal Pro
2. Go to Settings → Copilot
3. Click "Add Custom Copilot"
4. Enter URL: `http://localhost:7777`
5. Click "Add" or "Save"

You should see your agent appear in the copilot list with the name from `/agents.json`.

### For OpenBB Web

For OpenBB Web, you need a publicly accessible URL. See the [Integration Guide](./INTEGRATION_GUIDE.md) for ngrok or cloud deployment options.

## Step 5: Test in OpenBB

1. **Select your agent** from the copilot dropdown
2. **Ask a simple question**: "Hello! What can you do?"
3. **Check the response**: You should see a response from your agent

✅ **If you get a response** → Integration successful!  
❌ **If you get an error** → Check browser console for CORS errors or connection issues.

## Troubleshooting Integration

### CORS Errors in Browser Console

**Symptom**: Browser console shows: `Access to fetch at 'http://localhost:7777' from origin 'https://pro.openbb.co' has been blocked by CORS policy`

**Solution**: Update `allow_origins` in your agent's `main.py`:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://pro.openbb.co",  # For OpenBB Web
        "http://localhost:3000",   # For local OpenBB Desktop (if needed)
        # Add other origins as needed
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Then restart your agent.

### Agent Not Appearing in List

**Symptom**: Agent doesn't show up in OpenBB's copilot list

**Solutions**:
1. Verify `/agents.json` returns valid JSON
2. Check the URL is correct (e.g., `http://localhost:7777`, not `http://localhost:7777/`)
3. Refresh OpenBB or restart it
4. Check OpenBB's logs/console for error messages

### Connection Refused

**Symptom**: OpenBB can't connect to the agent

**Solutions**:
1. Verify agent is running: Check terminal where uvicorn is running
2. Test locally first: Visit `http://localhost:7777/agents.json` in browser
3. Check firewall settings: Ensure port 7777 is not blocked
4. For OpenBB Desktop on different machine: Use your machine's IP instead of localhost

## Next Steps

Once verification is complete:
- ✅ Customize your agent's behavior
- ✅ Add more features (charts, tables, PDFs, etc.)
- ✅ Deploy to production (see [Integration Guide](./INTEGRATION_GUIDE.md))
- ✅ Share with your team!

Need more help? See the [Integration Guide](./INTEGRATION_GUIDE.md) or check the example agents in this repository.
