FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  nodejs \
  npm \
  postgresql-client \
  libvips \
  build-essential \
  libpq-dev \
  git \
  vim \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Precompile assets (will be done after CSS/JS setup)
# RUN bundle exec rails assets:precompile

# Expose port
EXPOSE 3000

# Start the server
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]
