# Running BookMyDoc Locally (No Docker for Rails)

Since PostgreSQL and Redis are already running in Docker, you just need to:

## 1. Install System Dependencies

```bash
# Install PostgreSQL development libraries
sudo apt-get update
sudo apt-get install -y libpq-dev build-essential

# This is required for the 'pg' gem to compile
```

## 2. Install Gems and NPM Packages

```bash
cd /home/kalyan/platform/personal/seva_care

# Install Ruby gems
bundle install

# Install Node packages for Tailwind
npm install
```

## 3. Setup Database

```bash
# Create and migrate database
rails db:create
rails db:migrate
rails db:seed
```

## 4. Build Tailwind CSS

```bash
# Build CSS once
npm run build

# Or watch for changes (in separate terminal)
npm run watch
```

## 5. Start Rails Server

```bash
# Start on port 7000
rails server -p 7000

# Or use the dev script (starts Rails + Tailwind watch)
./bin/dev
```

## Access Application

Visit: **http://localhost:7000**

## ✅ Your Current Setup

- ✅ PostgreSQL running on `localhost:5432` (Docker)
- ✅ Redis running on `localhost:6379` (Docker)
- ⏳ Rails app will run locally (not in Docker)

This is the recommended setup for development!
