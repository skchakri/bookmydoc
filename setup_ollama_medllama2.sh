#!/bin/bash

# BookMyDoc - Ollama MedLlama2 Setup Script
# This script helps you set up Ollama with the medllama2 model for medical symptom analysis

echo "=================================================="
echo "BookMyDoc - Ollama MedLlama2 Setup"
echo "=================================================="
echo ""

# Check if Ollama is installed
echo "Step 1: Checking if Ollama is installed..."
if command -v ollama &> /dev/null; then
    echo "✓ Ollama is installed"
    ollama --version
else
    echo "✗ Ollama is not installed"
    echo ""
    echo "Please install Ollama first:"
    echo "  Linux:   curl -fsSL https://ollama.com/install.sh | sh"
    echo "  macOS:   brew install ollama"
    echo "  Windows: https://ollama.com/download"
    exit 1
fi

echo ""
echo "Step 2: Checking if Ollama service is running..."

# Check if Ollama is running
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "✓ Ollama service is running"
else
    echo "✗ Ollama service is not running"
    echo ""
    echo "Please start Ollama service:"
    echo "  ollama serve"
    echo ""
    echo "Or run it in the background:"
    echo "  ollama serve &"
    exit 1
fi

echo ""
echo "Step 3: Checking for medllama2 model..."

# Check if medllama2 is already installed
if ollama list | grep -q "medllama2"; then
    echo "✓ medllama2 model is already installed"
else
    echo "⚠ medllama2 model not found"
    echo ""
    echo "Note: medllama2 might not be available in the Ollama library."
    echo "Checking available medical models..."
    echo ""

    echo "Available alternatives:"
    echo "  1. llama3.2 (recommended) - Fast and accurate general purpose model"
    echo "  2. llama2 - Stable baseline model"
    echo "  3. mistral - Fast and efficient"
    echo ""

    read -p "Would you like to pull llama3.2 instead? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Pulling llama3.2 model (this may take a few minutes)..."
        ollama pull llama3.2

        if [ $? -eq 0 ]; then
            echo "✓ llama3.2 model installed successfully"
            echo ""
            echo "To use llama3.2, update your .env file:"
            echo "  OLLAMA_MODEL=llama3.2"
        else
            echo "✗ Failed to pull llama3.2"
            exit 1
        fi
    else
        echo ""
        echo "You can manually try to pull medllama2:"
        echo "  ollama pull medllama2"
        echo ""
        echo "If it's not available, use llama3.2 or mistral instead."
        exit 1
    fi
fi

echo ""
echo "Step 4: Testing Ollama connection..."

# Test Ollama
RESPONSE=$(ollama run llama3.2 "Hello, can you respond with just 'yes'?" 2>&1 | head -n 1)
if [ ! -z "$RESPONSE" ]; then
    echo "✓ Ollama is responding correctly"
    echo "  Response: $RESPONSE"
else
    echo "✗ Ollama test failed"
    exit 1
fi

echo ""
echo "Step 5: Verifying Docker connection to Ollama..."

# Test from Docker container
echo "Testing connection from Docker container..."
docker compose exec -T web curl -s http://host.docker.internal:11434/api/tags > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Docker container can reach Ollama"
else
    echo "✗ Docker container cannot reach Ollama"
    echo ""
    echo "On Linux, you may need to add to docker-compose.yml:"
    echo ""
    echo "  web:"
    echo "    extra_hosts:"
    echo "      - \"host.docker.internal:host-gateway\""
    echo ""
fi

echo ""
echo "=================================================="
echo "Setup Complete!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Make sure Ollama is running: ollama serve"
echo "2. Test symptom analysis:"
echo "   - Log in as a patient"
echo "   - Go to: http://localhost:7000/symptom_reports/new"
echo "   - Submit symptoms and see AI analysis"
echo ""
echo "3. Check Rails console:"
echo "   docker compose exec web rails console"
echo "   > AiTriageService.analyze('I have a headache and fever')"
echo ""
echo "Current configuration:"
echo "  Model: medllama2 (or fallback to llama3.2)"
echo "  URL: http://host.docker.internal:11434"
echo "  Temperature: 0.3"
echo "  Max tokens: 1000"
echo ""
echo "To change the model, set OLLAMA_MODEL in .env file"
echo "=================================================="
