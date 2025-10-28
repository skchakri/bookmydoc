# Ollama AI Integration Setup

BookMyDoc uses Ollama for AI-powered symptom analysis. This document explains how to set up and configure Ollama for local development.

## Prerequisites

- Ollama installed on your host machine
- Docker containers running (web, db, redis)

## Installation

### 1. Install Ollama

**Linux:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**macOS:**
```bash
brew install ollama
```

**Windows:**
Download from https://ollama.com/download

### 2. Start Ollama Service

```bash
# Start Ollama service
ollama serve
```

The service will start on `http://localhost:11434`

### 3. Pull a Medical AI Model

```bash
# Recommended: Llama 3.2 (good balance of speed and accuracy)
ollama pull llama3.2

# Alternative models:
ollama pull llama2           # Older but stable
ollama pull mistral          # Fast and efficient
ollama pull medllama2        # Specialized for medical queries (if available)
ollama pull llama3:70b       # More accurate but slower
```

### 4. Configure BookMyDoc

The application is already configured to connect to Ollama. Configuration is in:
- `config/initializers/ruby_llm.rb` - RubyLLM configuration
- `app/services/ai_triage_service.rb` - Symptom analysis service

**Environment Variables** (optional):
```bash
# Add to .env file (create from .env.example)
OLLAMA_URL=http://host.docker.internal:11434
OLLAMA_MODEL=llama3.2
```

### 5. Verify Connection

Test the Ollama connection from inside the Docker container:

```bash
# Enter Rails console
docker compose exec web rails console

# Test Ollama connection
RubyLLM.complete("Hello, are you working?")

# Test symptom analysis
AiTriageService.analyze("I have a severe headache and fever for 3 days")
```

## How It Works

### Symptom Analysis Flow

1. **Patient submits symptoms** via `/symptom_reports/new`
2. **AiTriageService.analyze()** is called with the symptom text
3. **AI Analysis** (primary):
   - Sends structured prompt to Ollama via ruby_llm
   - Ollama analyzes symptoms using the configured model
   - Returns predicted condition and recommended specializations
4. **Fallback Analysis** (if AI fails):
   - Uses keyword-based matching
   - Matches symptoms against predefined specialization keywords
   - Returns basic recommendations

### Prompt Structure

The AI receives a structured prompt with:
- Available medical specializations
- Patient's symptom description
- Guidelines for medical triage
- Expected response format

Example prompt:
```
You are a medical triage assistant...

Available specializations:
Cardiologist, Dermatologist, ENT, General Physician, ...

Patient's symptoms:
"I have severe chest pain and shortness of breath"

Please analyze and provide:
CONDITION: [predicted condition]
SPECIALIZATIONS: [recommended specialists]
```

### Response Parsing

The service parses the AI response to extract:
- **Condition**: Brief diagnosis or description
- **Specializations**: List of recommended specialists

## Configuration Options

### RubyLLM Settings (config/initializers/ruby_llm.rb)

```ruby
RubyLLM.configure do |config|
  # Configure Ollama API base URL
  config.ollama_api_base = ENV.fetch('OLLAMA_URL', 'http://host.docker.internal:11434')

  # Request timeout in seconds
  config.request_timeout = 120
end

# Model is specified per-request in the service
ENV['OLLAMA_MODEL'] ||= 'medllama2'
```

### Adjusting Temperature

- **0.0-0.3**: More deterministic, conservative (recommended for medical use)
- **0.4-0.7**: Balanced creativity and accuracy
- **0.8-1.0**: More creative but less predictable

### Model Selection

| Model | Size | Speed | Accuracy | Use Case |
|-------|------|-------|----------|----------|
| llama3.2 | ~2GB | Fast | Good | General development |
| llama2 | ~4GB | Medium | Good | Stable baseline |
| mistral | ~4GB | Fast | Good | Fast responses |
| llama3:70b | ~40GB | Slow | Excellent | Production (requires powerful hardware) |
| medllama2 | ~4GB | Medium | Excellent | Medical-specific (if available) |

## Troubleshooting

### Connection Issues

**Error**: "Connection refused to localhost:11434"

**Solution**:
1. Verify Ollama is running: `curl http://localhost:11434/api/tags`
2. Check Docker can reach host: `docker compose exec web curl http://host.docker.internal:11434/api/tags`
3. If on Linux, you may need to use `host.docker.internal` or the host IP

**Linux-specific fix**:
```yaml
# In docker-compose.yml, add to web service:
extra_hosts:
  - "host.docker.internal:host-gateway"
```

### Model Not Found

**Error**: "model 'llama3.2' not found"

**Solution**:
```bash
# Pull the model
ollama pull llama3.2

# Verify it's available
ollama list
```

### Slow Responses

**Issue**: AI analysis takes too long

**Solutions**:
1. Use a smaller model (llama2, mistral)
2. Reduce max_tokens in configuration
3. Increase timeout in ruby_llm config
4. Use GPU acceleration if available

### Fallback to Keywords

If you see "AI analysis unavailable" in the condition text, the system is using keyword-based fallback. This means:
1. Ollama is not reachable
2. Model is not loaded
3. Request timed out

Check the Rails logs:
```bash
docker compose logs web | grep "AI Triage"
```

## Testing

### Manual Test via Console

```bash
docker compose exec web rails console

# Test basic connection
RubyLLM.complete("Hello")

# Test symptom analysis
result = AiTriageService.analyze("I have severe chest pain, shortness of breath, and dizziness")
puts result[:condition]
puts result[:specializations].inspect

# Test fallback
# Stop Ollama service temporarily, then:
result = AiTriageService.analyze("I have a headache")
# Should use keyword-based fallback
```

### Integration Test via Web UI

1. Start all services: `docker compose up`
2. Log in as a patient
3. Navigate to: `http://localhost:7000/symptom_reports/new`
4. Enter detailed symptoms
5. Submit and check the analysis results

## Production Considerations

### Performance

- **Response Time**: 2-10 seconds depending on model and hardware
- **GPU Acceleration**: Highly recommended for production
- **Model Size**: Balance between accuracy and speed

### Scaling

For high-traffic production:
1. Use dedicated Ollama server(s)
2. Implement request queuing (Sidekiq/Redis)
3. Add response caching for common symptoms
4. Consider API-based alternatives (OpenAI, Claude) for better scale

### Privacy & Compliance

- **HIPAA Compliance**: Ollama runs locally, no data sent to external APIs
- **Data Storage**: Symptom text is stored in database
- **Audit Trail**: All symptom analyses are logged
- **Encryption**: Use encrypted database and secure connections

### Alternative AI Providers

RubyLLM supports multiple providers. To use alternatives:

```ruby
# OpenAI
config.default_provider = :openai
config.openai_api_key = ENV['OPENAI_API_KEY']

# Anthropic Claude
config.default_provider = :anthropic
config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
```

## Resources

- Ollama Documentation: https://ollama.com/docs
- RubyLLM Gem: https://rubyllm.com
- Available Models: https://ollama.com/library

## Support

For issues:
1. Check Ollama logs: `journalctl -u ollama -f` (Linux)
2. Check Rails logs: `docker compose logs web`
3. Enable debug logging in `config/initializers/ruby_llm.rb`
