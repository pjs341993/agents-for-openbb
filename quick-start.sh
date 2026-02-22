#!/bin/bash

# OpenBB Agent Quick Start Script
# This script helps you quickly set up and run an OpenBB agent

set -e

echo "🚀 OpenBB Agent Quick Start"
echo "============================"
echo ""

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo "❌ Poetry is not installed."
    echo "Please install it first: pip install poetry"
    exit 1
fi

# List available agents
echo "Available agents:"
echo ""
agents=(
    "30-vanilla-agent-raw-widget-data"
    "31-vanilla-agent-reasoning-steps"
    "32-vanilla-agent-raw-widget-data-citations"
    "33-vanilla-agent-charts"
    "34-vanilla-agent-tables"
    "35-vanilla-agent-pdf"
    "36-vanilla-agent-pdf-citations"
    "37-vanilla-agent-custom-features"
    "38-vanilla-agent-mcp-tools"
    "39-vanilla-agent-html-artifacts"
    "40-vanilla-agent-dashboard-widgets"
)

for i in "${!agents[@]}"; do
    echo "  $((i+1)). ${agents[$i]}"
done

echo ""
read -p "Select an agent (1-${#agents[@]}): " selection

if [[ $selection -lt 1 || $selection -gt ${#agents[@]} ]]; then
    echo "❌ Invalid selection"
    exit 1
fi

selected_agent="${agents[$((selection-1))]}"
echo ""
echo "✅ Selected: $selected_agent"
echo ""

# Check for API key
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  OPENAI_API_KEY not found in environment"
    read -p "Enter your OpenAI API key (or press Enter to skip): " api_key
    if [ -n "$api_key" ]; then
        export OPENAI_API_KEY="$api_key"
        echo "✅ API key set for this session"
    else
        echo "⚠️  Warning: Agent may not work without an API key"
    fi
    echo ""
else
    echo "✅ OPENAI_API_KEY found in environment"
    echo ""
fi

# Check if dependencies are installed
echo "📦 Installing dependencies..."
if poetry install --no-root; then
    echo "✅ Dependencies installed"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo ""

# Determine the port
PORT=7777
read -p "Port to run on (default: 7777): " custom_port
if [ -n "$custom_port" ]; then
    PORT=$custom_port
fi

# Find the main module
cd "$selected_agent"
main_module=$(find . -name "main.py" | head -1)

if [ -z "$main_module" ]; then
    echo "❌ Could not find main.py in $selected_agent"
    exit 1
fi

# Extract module path
module_dir=$(dirname "$main_module" | sed 's/^\.\///')
module_path="${module_dir//\//.}.main:app"

echo ""
echo "🎉 Starting agent..."
echo ""
echo "Agent URL: http://localhost:$PORT"
echo "API Docs:  http://localhost:$PORT/docs"
echo "Config:    http://localhost:$PORT/agents.json"
echo ""
echo "To integrate with OpenBB:"
echo "  1. Open OpenBB Desktop/Web"
echo "  2. Go to Copilot settings"
echo "  3. Add custom copilot with URL: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop the agent"
echo ""
echo "----------------------------------------"
echo ""

# Start the agent
poetry run uvicorn "$module_path" --port "$PORT" --reload
