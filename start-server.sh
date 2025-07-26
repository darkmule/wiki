#!/bin/bash

# Simple Python HTTP Server Starter with Logging
# Usage: ./start-server.sh [port]

# Set default port
PORT=${1:-8000}

# Create logs directory if it doesn't exist
mkdir -p logs

# Log file with timestamp
LOG_FILE="logs/server-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Security check
if [ ! -f "index.html" ]; then
    echo -e "${RED}⚠️  Security Warning: No index.html found!${NC}"
    echo -e "${YELLOW}📁 Directory listing will be exposed at http://localhost:${PORT}/${NC}"
    echo -e "${YELLOW}💡 Consider creating an index.html file for better security${NC}"
    echo ""
fi

echo -e "${GREEN}🚀 Starting Python HTTP Server...${NC}"
echo -e "${BLUE}📁 Serving directory: $(pwd)${NC}"

# Try to find the right Python command
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python3.13 &> /dev/null; then
    PYTHON_CMD="python3.13"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo -e "${RED}❌ No Python executable found!${NC}"
    echo -e "${YELLOW}💡 Try: pyenv global 3.13.0${NC}"
    exit 1
fi

echo -e "${GREEN}🐍 Using: ${PYTHON_CMD}${NC}"
echo -e "${BLUE}🌐 Server URL: http://localhost:${PORT}${NC}"
echo -e "${BLUE}📋 Your page: http://localhost:${PORT}/hello-world.html${NC}"
echo -e "${YELLOW}📝 Logging to: ${LOG_FILE}${NC}"
echo -e "${YELLOW}🛑 Press Ctrl+C to stop the server${NC}"
echo ""

# Start the server with logging
${PYTHON_CMD} -m http.server ${PORT} 2>&1 | tee ${LOG_FILE}
