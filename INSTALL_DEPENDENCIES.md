# Install System Dependencies

You need to install PostgreSQL development libraries before running `bundle install`.

## For Ubuntu/Debian (Linux)

Run the following commands in your terminal:

```bash
# Update package list
sudo apt-get update

# Install PostgreSQL development headers and build tools
sudo apt-get install -y libpq-dev build-essential

# Optional: Install PostgreSQL client tools
sudo apt-get install -y postgresql-client

# Optional: Install Redis tools
sudo apt-get install -y redis-tools
```

## After Installing Dependencies

Once the above is installed, run:

```bash
cd /home/kalyan/platform/personal/seva_care

# Install Ruby gems
bundle install

# Install Node packages (for Tailwind CSS)
npm install

# Copy environment file
cp .env.example .env

# Create and setup database
rails db:create
rails db:migrate
rails db:seed
```

## Start PostgreSQL and Redis with Docker

If you don't have PostgreSQL and Redis installed locally, use Docker:

```bash
# Start PostgreSQL
docker run -d \
  --name bookmydoc-postgres \
  -e POSTGRES_USER=bookmydoc \
  -e POSTGRES_PASSWORD=bookmydoc_dev_password \
  -e POSTGRES_DB=bookmydoc_development \
  -p 5432:5432 \
  postgres:15

# Start Redis
docker run -d \
  --name bookmydoc-redis \
  -p 6379:6379 \
  redis:7-alpine

# Verify they're running
docker ps
```

## Start the Application

```bash
# Start Rails server with Tailwind watch
./bin/dev

# Or just Rails server
rails server -p 7000
```

Visit: **http://localhost:7000**

## Troubleshooting

### If bundle install still fails:

```bash
# Try installing pg gem with explicit path
gem install pg -- --with-pg-config=/usr/bin/pg_config

# Then retry bundle install
bundle install
```

### If you get permission errors:

```bash
# Make sure bin scripts are executable
chmod +x bin/*
```

### Check if PostgreSQL is accessible:

```bash
# Test PostgreSQL connection
docker exec -it bookmydoc-postgres psql -U bookmydoc -d bookmydoc_development

# Test Redis connection
docker exec -it bookmydoc-redis redis-cli ping
```

## Alternative: Use Docker Compose for Everything

If you prefer to run everything in Docker:

```bash
# Build and start all services (Postgres, Redis, Rails)
docker-compose up --build

# Access at http://localhost:7000
```

This will start all services including the Rails app in containers.
