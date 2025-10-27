# Puma configuration
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Port configuration - Use 7000 for BookMyDoc
port ENV.fetch("PORT") { 7000 }

# Environment
environment ENV.fetch("RAILS_ENV") { "development" }

# Worker configuration
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Preload app for production
preload_app!

# PID file
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Logging
stdout_redirect(stdout = "log/puma_access.log", stderr = "log/puma_error.log", append = true) if ENV.fetch("RAILS_ENV", "development") == "production"

# Allow puma to be restarted by `bin/rails restart` command
plugin :tmp_restart
