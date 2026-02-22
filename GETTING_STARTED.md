# Getting Started with OpenBB Agents

Welcome! This guide will help you quickly integrate custom AI agents into OpenBB Desktop or OpenBB Web.

## What Are OpenBB Agents?

OpenBB agents are custom AI assistants that integrate with the OpenBB Workspace. They can:
- Answer financial questions
- Retrieve and analyze data from widgets
- Generate charts, tables, and reports
- Access external tools and APIs
- Stream responses in real-time

## 📚 Documentation Overview

This repository includes comprehensive documentation:

| Document | Description | When to Use |
|----------|-------------|-------------|
| [GETTING_STARTED.md](./GETTING_STARTED.md) | This file - quick overview and links | Start here! |
| [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md) | Complete integration guide for Desktop & Web | For detailed setup instructions |
| [VERIFICATION_GUIDE.md](./VERIFICATION_GUIDE.md) | How to test your agent setup | After starting your agent |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Docker & cloud deployment options | For production deployment |
| [README.md](./README.md) | Repository overview and examples | To explore agent features |

## ⚡ Quick Start (5 Minutes)

### Prerequisites

1. **Python 3.10+** installed
2. **Poetry** package manager: `pip install poetry`
3. **API Key** for your LLM provider (e.g., OpenAI)

### Step 1: Clone and Setup

```bash
# Clone the repository (replace with your fork if needed)
git clone https://github.com/pjs341993/agents-for-openbb.git
cd agents-for-openbb

# Set your API key
export OPENAI_API_KEY=your-key-here

# Install dependencies
poetry install --no-root
```

### Step 2: Run the Quick Start Script

**macOS/Linux:**
```bash
./quick-start.sh
```

**Windows:**
```bash
quick-start.bat
```

The script will:
1. Show you available agents
2. Let you select one
3. Install dependencies
4. Start the agent server

### Step 3: Integrate with OpenBB

**For OpenBB Desktop:**
1. Open OpenBB Desktop
2. Go to **Settings → Copilot**
3. Click **Add Custom Copilot**
4. Enter: `http://localhost:7777`
5. Click **Save**

**For OpenBB Web:**
- See the [Integration Guide](./INTEGRATION_GUIDE.md#integration-with-openbb-web) for ngrok or cloud deployment instructions

### Step 4: Test Your Agent

1. Select your agent from the copilot dropdown
2. Ask: "Hello! What can you do?"
3. See the response! 🎉

## 🎯 Choose Your Path

### I want to...

#### 🚀 Get started quickly
→ Use the [quick-start script](#quick-start-5-minutes) above

#### 📖 Learn about integration options
→ Read the [Integration Guide](./INTEGRATION_GUIDE.md)

#### 🧪 Test if my setup works
→ Follow the [Verification Guide](./VERIFICATION_GUIDE.md)

#### 🐳 Deploy with Docker
→ Check the [Deployment Guide](./DEPLOYMENT.md)

#### 💡 Explore example agents
→ Browse the agent directories (30-*, 31-*, etc.)

#### 🛠️ Build a custom agent
→ Start with an example and modify it

## 📁 Repository Structure

```
agents-for-openbb/
├── 30-vanilla-agent-raw-widget-data/     # Basic agent with widget data
├── 33-vanilla-agent-charts/              # Agent that creates charts
├── 34-vanilla-agent-tables/              # Agent that creates tables
├── 37-vanilla-agent-custom-features/     # Agent with custom features
├── 38-vanilla-agent-mcp-tools/           # Agent with MCP tools
├── 39-vanilla-agent-html-artifacts/      # Agent that creates HTML
├── 40-vanilla-agent-dashboard-widgets/   # Agent with dashboard access
├── INTEGRATION_GUIDE.md                  # Complete integration guide
├── VERIFICATION_GUIDE.md                 # Testing and verification
├── DEPLOYMENT.md                         # Docker & cloud deployment
├── quick-start.sh                        # Quick start script (Unix)
├── quick-start.bat                       # Quick start script (Windows)
└── README.md                             # Repository overview
```

## 🔑 Key Concepts

### Agent Configuration
Each agent exposes an `/agents.json` endpoint that describes:
- Agent name and description
- Available endpoints
- Supported features (streaming, widgets, charts, etc.)

### Query Endpoint
The `/v1/query` endpoint handles conversations:
- Receives messages from OpenBB
- Processes with your LLM
- Streams responses back

### Features
Agents can support various features:
- **Streaming**: Real-time response generation
- **Widget Data**: Access to OpenBB data widgets
- **Charts**: Generate visualizations
- **Tables**: Format data in tables
- **Citations**: Reference data sources
- **PDFs**: Handle PDF documents

## 🎓 Learning Path

1. **Start Simple**: Run the basic `30-vanilla-agent-raw-widget-data`
2. **Test It**: Follow the [Verification Guide](./VERIFICATION_GUIDE.md)
3. **Explore Features**: Try agents with charts (`33-`), tables (`34-`), etc.
4. **Customize**: Modify an agent to fit your needs
5. **Deploy**: Use the [Deployment Guide](./DEPLOYMENT.md) for production

## 🆘 Need Help?

### Common Issues

**Agent won't start?**
→ Check you've run `poetry install --no-root`

**Connection refused?**
→ Verify agent is running on the correct port

**CORS errors?**
→ Update `allow_origins` in your agent's `main.py`

**API key errors?**
→ Set `OPENAI_API_KEY` environment variable

For more help, see:
- [Troubleshooting section](./INTEGRATION_GUIDE.md#troubleshooting) in the Integration Guide
- [Verification Guide](./VERIFICATION_GUIDE.md) for testing

## 📝 Example Agents

Each numbered directory contains a complete agent example:

- **30** - Basic agent with raw widget data access
- **31** - Agent with reasoning steps
- **32** - Agent with citations
- **33** - Agent that creates charts
- **34** - Agent that creates tables
- **35** - Agent that handles PDFs
- **36** - Agent with PDF citations
- **37** - Agent with custom features
- **38** - Agent with MCP tools
- **39** - Agent with HTML artifacts
- **40** - Agent with dashboard widgets

Each example includes:
- Source code (`main.py`)
- Tests
- README with specific instructions

## 🚢 Production Deployment

For production use:

1. **Choose a deployment method**:
   - Docker (see [DEPLOYMENT.md](./DEPLOYMENT.md))
   - Cloud platforms (AWS, GCP, Azure)
   - PaaS (Heroku, Render, Railway)

2. **Enable HTTPS**: Required for OpenBB Web

3. **Set environment variables**: Never commit API keys

4. **Configure CORS**: Add your OpenBB domain to `allow_origins`

5. **Monitor**: Add logging and error tracking

See the [Deployment Guide](./DEPLOYMENT.md) for detailed instructions.

## 🤝 Contributing

Found an issue or want to improve the documentation? Contributions are welcome!

## 📄 License

See [LICENSE](./LICENSE) file for details.

---

**Ready to get started?** Run the quick-start script or dive into the [Integration Guide](./INTEGRATION_GUIDE.md)!
