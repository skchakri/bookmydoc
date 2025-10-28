# Configure RubyLLM for Ollama integration
RubyLLM.configure do |config|
  # Configure Ollama API base URL
  # Use host.docker.internal to access host machine from Docker
  config.ollama_api_base = ENV.fetch('OLLAMA_URL', 'http://host.docker.internal:11434')

  # Request timeout in seconds
  config.request_timeout = 120
end

# Store Ollama model in environment for use in service
ENV['OLLAMA_MODEL'] ||= 'medllama2'

Rails.logger.info "RubyLLM configured to use Ollama at #{ENV.fetch('OLLAMA_URL', 'http://host.docker.internal:11434')}"
Rails.logger.info "Using model: #{ENV['OLLAMA_MODEL']}"
