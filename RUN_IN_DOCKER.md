# Running BookMyDoc in Docker

Since you don't have `libpq-dev` installed locally, the easiest way is to run everything in Docker containers.

## Option 1: Using Docker Compose (Recommended)

### Step 1: Install Docker Compose

```bash
# Download docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### Step 2: Build and Run

```bash
cd /home/kalyan/platform/personal/seva_care

# Build and start all services
docker-compose up --build

# Or run in detached mode (background)
docker-compose up -d --build
```

This will start:
- PostgreSQL (port 5432)
- Redis (port 6379)
- Rails app (port 7000)

Visit: **http://localhost:7000**

### Step 3: Setup Database (First Time Only)

In another terminal:

```bash
# Create and migrate database
docker-compose exec web rails db:create db:migrate db:seed

# Or run all at once
docker-compose exec web bash -c "rails db:create && rails db:migrate && rails db:seed"
```

### Useful Commands

```bash
# View logs
docker-compose logs -f web

# Stop all services
docker-compose down

# Restart services
docker-compose restart

# Open Rails console
docker-compose exec web rails console

# Run migrations
docker-compose exec web rails db:migrate

# Access database
docker-compose exec db psql -U bookmydoc -d bookmydoc_development

# Access Redis
docker-compose exec redis redis-cli
```

---

## Option 2: Using Docker without Docker Compose

If you prefer not to install docker-compose:

### Step 1: Start PostgreSQL and Redis

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

# Wait a few seconds for them to start
sleep 5
```

### Step 2: Build Rails Docker Image

```bash
cd /home/kalyan/platform/personal/seva_care

# Build the image
docker build -t bookmydoc-app .
```

### Step 3: Run Rails Container

```bash
# Run Rails container
docker run -it --rm \
  --name bookmydoc-web \
  -p 7000:7000 \
  -v $(pwd):/app \
  -e DATABASE_HOST=host.docker.internal \
  -e REDIS_URL=redis://host.docker.internal:6379/0 \
  bookmydoc-app \
  bash -c "bundle install && npm install && rails db:create db:migrate db:seed && rails server -b 0.0.0.0 -p 7000"
```

Visit: **http://localhost:7000**

---

## Option 3: Install Dependencies Locally (Alternative)

If you want to run Rails locally without Docker:

```bash
# Install PostgreSQL dev libraries
sudo apt-get update
sudo apt-get install -y libpq-dev build-essential

# Start database containers
docker run -d --name bookmydoc-postgres -e POSTGRES_USER=bookmydoc -e POSTGRES_PASSWORD=bookmydoc_dev_password -e POSTGRES_DB=bookmydoc_development -p 5432:5432 postgres:15
docker run -d --name bookmydoc-redis -p 6379:6379 redis:7-alpine

# Install gems and npm packages
bundle install
npm install

# Setup database
rails db:create db:migrate db:seed

# Start server
./bin/dev
```

---

## Troubleshooting

### Port already in use?

```bash
# Find what's using port 7000
lsof -i :7000

# Or kill it
kill -9 $(lsof -t -i:7000)
```

### Database connection errors?

```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Check logs
docker logs bookmydoc-postgres
```

### Clean slate restart?

```bash
# Stop and remove everything
docker-compose down -v

# Remove individual containers
docker stop bookmydoc-postgres bookmydoc-redis
docker rm bookmydoc-postgres bookmydoc-redis

# Start fresh
docker-compose up --build
```

---

## My Recommendation

**Use Option 1 (Docker Compose)** - it's the cleanest and most consistent way to run the entire stack in containers.

Just run:
```bash
# Install docker-compose first (if needed)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Then start the app
cd /home/kalyan/platform/personal/seva_care
docker-compose up --build

# In another terminal, setup database
docker-compose exec web rails db:create db:migrate db:seed
```

That's it! 🚀
