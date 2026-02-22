@echo off
setlocal enabledelayedexpansion
REM OpenBB Agent Quick Start Script for Windows
REM This script helps you quickly set up and run an OpenBB agent

echo.
echo ==============================
echo OpenBB Agent Quick Start
echo ==============================
echo.

REM Check if poetry is installed
where poetry >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Poetry is not installed.
    echo Please install it first: pip install poetry
    pause
    exit /b 1
)

REM List available agents
echo Available agents:
echo.
echo   1. 30-vanilla-agent-raw-widget-data
echo   2. 31-vanilla-agent-reasoning-steps
echo   3. 32-vanilla-agent-raw-widget-data-citations
echo   4. 33-vanilla-agent-charts
echo   5. 34-vanilla-agent-tables
echo   6. 35-vanilla-agent-pdf
echo   7. 36-vanilla-agent-pdf-citations
echo   8. 37-vanilla-agent-custom-features
echo   9. 38-vanilla-agent-mcp-tools
echo   10. 39-vanilla-agent-html-artifacts
echo   11. 40-vanilla-agent-dashboard-widgets
echo.

set /p selection="Select an agent (1-11): "

if "%selection%"=="1" set "selected_agent=30-vanilla-agent-raw-widget-data"
if "%selection%"=="2" set "selected_agent=31-vanilla-agent-reasoning-steps"
if "%selection%"=="3" set "selected_agent=32-vanilla-agent-raw-widget-data-citations"
if "%selection%"=="4" set "selected_agent=33-vanilla-agent-charts"
if "%selection%"=="5" set "selected_agent=34-vanilla-agent-tables"
if "%selection%"=="6" set "selected_agent=35-vanilla-agent-pdf"
if "%selection%"=="7" set "selected_agent=36-vanilla-agent-pdf-citations"
if "%selection%"=="8" set "selected_agent=37-vanilla-agent-custom-features"
if "%selection%"=="9" set "selected_agent=38-vanilla-agent-mcp-tools"
if "%selection%"=="10" set "selected_agent=39-vanilla-agent-html-artifacts"
if "%selection%"=="11" set "selected_agent=40-vanilla-agent-dashboard-widgets"

if "%selected_agent%"=="" (
    echo [ERROR] Invalid selection
    pause
    exit /b 1
)

echo.
echo [OK] Selected: %selected_agent%
echo.

REM Check for API key
if "%OPENAI_API_KEY%"=="" (
    echo [WARNING] OPENAI_API_KEY not found in environment
    set /p api_key="Enter your OpenAI API key (or press Enter to skip): "
    if not "!api_key!"=="" (
        set OPENAI_API_KEY=!api_key!
        echo [OK] API key set for this session
    ) else (
        echo [WARNING] Agent may not work without an API key
    )
    echo.
) else (
    echo [OK] OPENAI_API_KEY found in environment
    echo.
)

REM Install dependencies
echo [INFO] Installing dependencies...
poetry install --no-root
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

REM Get port
set PORT=7777
set /p custom_port="Port to run on (default: 7777): "
if not "%custom_port%"=="" set PORT=%custom_port%

REM Determine module path based on agent
if "%selected_agent%"=="30-vanilla-agent-raw-widget-data" set "module_path=vanilla_agent_raw_context.main:app"
if "%selected_agent%"=="31-vanilla-agent-reasoning-steps" set "module_path=vanilla_agent_reasoning_steps.main:app"
if "%selected_agent%"=="32-vanilla-agent-raw-widget-data-citations" set "module_path=vanilla_agent_raw_citations.main:app"
if "%selected_agent%"=="33-vanilla-agent-charts" set "module_path=vanilla_agent_charts.main:app"
if "%selected_agent%"=="34-vanilla-agent-tables" set "module_path=vanilla_agent_tables.main:app"
if "%selected_agent%"=="35-vanilla-agent-pdf" set "module_path=vanilla_agent_pdf.main:app"
if "%selected_agent%"=="36-vanilla-agent-pdf-citations" set "module_path=vanilla_agent_pdf_citations.main:app"
if "%selected_agent%"=="37-vanilla-agent-custom-features" set "module_path=vanilla_agent_custom_features.main:app"
if "%selected_agent%"=="38-vanilla-agent-mcp-tools" set "module_path=vanilla_agent_mcp_tools.main:app"
if "%selected_agent%"=="39-vanilla-agent-html-artifacts" set "module_path=vanilla_agent_html.main:app"
if "%selected_agent%"=="40-vanilla-agent-dashboard-widgets" set "module_path=vanilla_agent_dashboard_widgets.main:app"

echo.
echo [INFO] Starting agent...
echo.
echo Agent URL: http://localhost:%PORT%
echo API Docs:  http://localhost:%PORT%/docs
echo Config:    http://localhost:%PORT%/agents.json
echo.
echo To integrate with OpenBB:
echo   1. Open OpenBB Desktop/Web
echo   2. Go to Copilot settings
echo   3. Add custom copilot with URL: http://localhost:%PORT%
echo.
echo Press Ctrl+C to stop the agent
echo.
echo ----------------------------------------
echo.

REM Start the agent
cd %selected_agent%
poetry run uvicorn %module_path% --port %PORT% --reload
