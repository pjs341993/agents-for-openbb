# OpenBB Agent Integration Guide

This guide will help you integrate your custom agents from this repository into OpenBB Desktop or OpenBB Web.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Integration with OpenBB Desktop](#integration-with-openbb-desktop)
3. [Integration with OpenBB Web](#integration-with-openbb-web)
4. [Deployment Options](#deployment-options)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Configuration](#advanced-configuration)

---

## Quick Start

### Prerequisites

Before you begin, ensure you have:

- **Python 3.10+** installed
- **Poetry** for dependency management (`pip install poetry`)
- **OpenAI API key** (or other LLM provider credentials)
- **OpenBB Workspace** (Desktop or Web access)

### Step 1: Choose an Agent Example

This repository contains multiple agent examples. Choose one that fits your needs:

- **30-vanilla-agent-raw-widget-data** - Basic agent with widget data access
- **33-vanilla-agent-charts** - Agent that can produce charts
- **34-vanilla-agent-tables** - Agent that can produce tables
- **37-vanilla-agent-custom-features** - Agent with custom features
- **38-vanilla-agent-mcp-tools** - Agent with MCP tools integration
- **39-vanilla-agent-html-artifacts** - Agent that produces HTML artifacts
- **40-vanilla-agent-dashboard-widgets** - Agent with dashboard widget access

For this guide, we'll use `30-vanilla-agent-raw-widget-data` as an example.

### Step 2: Set Up Environment

1. **Clone the repository** (if not already done):
   ```bash
   # Replace with your repository URL if you've forked this
   git clone https://github.com/pjs341993/agents-for-openbb.git
   cd agents-for-openbb
   ```

2. **Set your API key**:
   ```bash
   # For bash/zsh
   export OPENAI_API_KEY=<your-api-key>
   
   # Or create a .env file in the project directory
   echo "OPENAI_API_KEY=<your-api-key>" > .env
   ```

3. **Install dependencies**:
   ```bash
   poetry install --no-root
   ```

### Step 3: Start Your Agent

Navigate to your chosen agent directory and start the server:

```bash
cd 30-vanilla-agent-raw-widget-data
poetry run uvicorn vanilla_agent_raw_context.main:app --port 7777 --reload
```

Your agent is now running at `http://localhost:7777`!

---

## Integration with OpenBB Desktop

### Local Development (Recommended for Testing)

1. **Start your agent** following [Step 3](#step-3-start-your-agent) above

2. **Open OpenBB Desktop/Terminal Pro**

3. **Navigate to Copilot Settings**:
   - Click on the **Settings** icon (usually in the top-right corner)
   - Go to **Copilot** settings section
   - Look for **Custom Copilot** or **Add Agent** option

4. **Add your custom agent**:
   - Click **Add Custom Copilot** or **+** button
   - Enter the URL: `http://localhost:7777`
   - The agent should auto-discover its configuration from `/agents.json`
   - Click **Save** or **Add**

5. **Test your agent**:
   - Open the Copilot chat interface
   - Select your custom agent from the agent dropdown
   - Try asking a question like "Hello, who are you?"

### Verify Agent Configuration

To check if your agent is properly configured, visit:
```
http://localhost:7777/agents.json
```

You should see a JSON response with your agent's metadata, including:
- Name
- Description
- Endpoints
- Features (streaming, widget access, etc.)

---

## Integration with OpenBB Web

### For OpenBB Web (pro.openbb.co)

OpenBB Web requires your agent to be **publicly accessible** over HTTPS. You have several options:

#### Option 1: Local Development with ngrok (Quick Testing)

**ngrok** creates a secure tunnel to your localhost, making it publicly accessible:

1. **Install ngrok**:
   ```bash
   # macOS
   brew install ngrok
   
   # Linux
   snap install ngrok
   
   # Or download from https://ngrok.com/download
   ```

2. **Start your agent locally**:
   ```bash
   cd 30-vanilla-agent-raw-widget-data
   poetry run uvicorn vanilla_agent_raw_context.main:app --port 7777
   ```

3. **Create ngrok tunnel**:
   ```bash
   ngrok http 7777
   ```

4. **Copy the HTTPS URL** provided by ngrok (e.g., `https://abc123.ngrok.io`)

5. **Update CORS settings** in your agent's `main.py`:
   ```python
   app.add_middleware(
       CORSMiddleware,
       allow_origins=[
           "https://pro.openbb.co",
           "https://abc123.ngrok.io"  # Add your ngrok URL
       ],
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

6. **Restart your agent** and **add to OpenBB Web**:
   - Go to https://pro.openbb.co
   - Navigate to Copilot settings
   - Add custom copilot with URL: `https://abc123.ngrok.io`

> **Note**: ngrok URLs change every time you restart ngrok (unless you have a paid account). For production use, consider a cloud deployment.

#### Option 2: Cloud Deployment (Production)

For production use, deploy your agent to a cloud provider:

**Recommended Cloud Platforms**:
- **Heroku** - Easy deployment, good for small projects
- **Google Cloud Run** - Serverless, scales to zero
- **AWS Lambda + API Gateway** - Serverless option
- **DigitalOcean App Platform** - Simple and affordable
- **Railway** - Modern deployment platform
- **Render** - Free tier available

**Example: Deploy to Render**

1. **Create a `render.yaml`** in your agent directory:
   ```yaml
   services:
     - type: web
       name: openbb-agent
       env: python
       buildCommand: "pip install poetry && poetry install --no-root"
       startCommand: "cd 30-vanilla-agent-raw-widget-data && poetry run uvicorn vanilla_agent_raw_context.main:app --host 0.0.0.0 --port $PORT"
       envVars:
         - key: OPENAI_API_KEY
           sync: false
   ```

2. **Push to GitHub** and connect to Render

3. **Set environment variables** in Render dashboard

4. **Get your deployment URL** (e.g., `https://openbb-agent.onrender.com`)

5. **Update CORS** in `main.py` to include your production URL

6. **Add to OpenBB Web** using your production URL

---

## Deployment Options

### Running in Production

For production deployments, consider these best practices:

#### 1. Use Environment Variables

Never hardcode API keys. Use environment variables or secret managers:

```python
import os
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
```

#### 2. Enable HTTPS

Always use HTTPS in production. Most cloud platforms provide this automatically.

#### 3. Configure CORS Properly

Update the `allow_origins` in your `main.py` to include only trusted domains:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://pro.openbb.co",
        "https://your-custom-domain.com"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

#### 4. Monitor and Log

Implement logging and monitoring for your agent:

```python
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.post("/v1/query")
async def query(request: QueryRequest):
    logger.info(f"Received query: {request.messages[-1].content[:100]}...")
    # ... rest of your code
```

#### 5. Use Docker (Optional)

Create a `Dockerfile` for consistent deployments:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install poetry
RUN pip install poetry

# Copy project files
COPY pyproject.toml poetry.lock ./
COPY 30-vanilla-agent-raw-widget-data ./30-vanilla-agent-raw-widget-data

# Install dependencies
RUN poetry install --no-root --no-dev

# Expose port
EXPOSE 7777

# Run the application
CMD ["poetry", "run", "uvicorn", "vanilla_agent_raw_context.main:app", "--host", "0.0.0.0", "--port", "7777"]
```

Build and run:
```bash
docker build -t openbb-agent .
docker run -p 7777:7777 -e OPENAI_API_KEY=$OPENAI_API_KEY openbb-agent
```

---

## Troubleshooting

### Common Issues

#### Agent Not Appearing in OpenBB

**Problem**: The agent doesn't show up in the copilot list.

**Solutions**:
1. Verify agent is running: Visit `http://localhost:7777/agents.json`
2. Check the JSON response format matches the expected schema
3. Ensure the URL is correct in OpenBB settings
4. Check browser console for CORS errors

#### CORS Errors

**Problem**: Browser console shows CORS policy errors.

**Solutions**:
1. Add OpenBB's domain to `allow_origins` in `main.py`
2. For OpenBB Web, add `https://pro.openbb.co`
3. For OpenBB Desktop, you may need `http://localhost:*` or specific desktop URLs
4. Restart your agent after making changes

#### Connection Refused

**Problem**: Cannot connect to agent at localhost.

**Solutions**:
1. Verify agent is running: `ps aux | grep uvicorn`
2. Check the port: `lsof -i :7777` (Unix/macOS) or `netstat -ano | findstr :7777` (Windows)
3. Try a different port if 7777 is in use
4. Check firewall settings

#### Widget Data Not Loading

**Problem**: Agent doesn't receive widget data.

**Solutions**:
1. Verify `"widget-dashboard-select": True` in `/agents.json`
2. Check that widgets are added to context in OpenBB
3. Review the `request.widgets` structure in your code
4. Add logging to debug: `print(request.widgets)`

#### Streaming Issues

**Problem**: Responses not streaming, or appearing all at once.

**Solutions**:
1. Ensure `"streaming": True` in `/agents.json`
2. Verify you're using `EventSourceResponse`
3. Check that you're yielding chunks with `message_chunk()`
4. Test SSE endpoint directly: `curl -N http://localhost:7777/v1/query`

#### API Key Issues

**Problem**: "Authentication failed" or API key errors.

**Solutions**:
1. Verify environment variable is set: `echo $OPENAI_API_KEY`
2. Check `.env` file exists and is loaded
3. Restart your shell/terminal after setting variables
4. For cloud deployments, set environment variables in platform settings

### Getting Help

If you're still experiencing issues:

1. **Check the logs**: Your agent's console output often contains helpful error messages
2. **Review the examples**: Compare your code with the working examples in this repository
3. **OpenBB Documentation**: Visit [OpenBB AI SDK](https://github.com/OpenBB-finance/openbb-ai)
4. **GitHub Issues**: Check existing issues or create a new one

---

## Advanced Configuration

### Multiple Agents

You can run multiple agents simultaneously on different ports:

```bash
# Terminal 1
cd 30-vanilla-agent-raw-widget-data
poetry run uvicorn vanilla_agent_raw_context.main:app --port 7777

# Terminal 2
cd 33-vanilla-agent-charts
poetry run uvicorn vanilla_agent_charts.main:app --port 7778

# Terminal 3
cd 34-vanilla-agent-tables
poetry run uvicorn vanilla_agent_tables.main:app --port 7779
```

Then add each agent to OpenBB with their respective URLs.

### Custom Features

Agents can declare custom features in their `/agents.json` response:

```python
@app.get("/agents.json")
def get_copilot_description():
    return JSONResponse(
        content={
            "my_agent": {
                "name": "My Custom Agent",
                "description": "A custom agent with special features",
                "image": "https://example.com/agent-icon.png",
                "endpoints": {"query": "/v1/query"},
                "features": {
                    "streaming": True,                    # Enable SSE streaming
                    "widget-dashboard-select": True,      # Access selected widgets
                    "widget-dashboard-search": False,     # Access all dashboard widgets
                    "citations": True,                    # Support citations
                    "tables": True,                       # Can produce tables
                    "charts": True,                       # Can produce charts
                    "pdf": True,                          # Can handle PDFs
                },
            }
        }
    )
```

### Environment-Specific Configuration

Use different configurations for development and production:

```python
import os

ENV = os.getenv("ENV", "development")

if ENV == "production":
    ALLOWED_ORIGINS = ["https://pro.openbb.co", "https://your-domain.com"]
    LOG_LEVEL = "WARNING"
else:
    ALLOWED_ORIGINS = ["*"]
    LOG_LEVEL = "DEBUG"

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Testing Your Agent

Each agent example includes a test suite. Run tests with:

```bash
cd 30-vanilla-agent-raw-widget-data
poetry run pytest tests
```

Create your own tests to ensure your agent works correctly:

```python
import pytest
from fastapi.testclient import TestClient
from vanilla_agent_raw_context.main import app

client = TestClient(app)

def test_agents_json():
    response = client.get("/agents.json")
    assert response.status_code == 200
    data = response.json()
    assert "vanilla_agent_raw_context" in data

def test_query_endpoint():
    request_data = {
        "messages": [{"role": "human", "content": "Hello"}]
    }
    response = client.post("/v1/query", json=request_data)
    assert response.status_code == 200
```

---

## Next Steps

Now that your agent is integrated with OpenBB:

1. **Customize**: Modify the agent's behavior to suit your needs
2. **Add Features**: Implement charts, tables, PDFs, or custom features
3. **Deploy**: Move from localhost to a production deployment
4. **Share**: Share your agent with your team or the community

For more examples and advanced use cases, explore the other agent examples in this repository.

Happy building! 🚀
