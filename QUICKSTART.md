# BookMyDoc Quick Start Guide

Get BookMyDoc running locally in 5 minutes!

## Prerequisites Check

```bash
# Check Ruby version (need 3.2.2)
ruby -v

# Check if PostgreSQL is accessible
psql --version

# Check if Redis is accessible
redis-cli --version
```

## Step 1: Start Local Services

### Start PostgreSQL and Redis (with Docker)

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

## Step 2: Setup Application

```bash
cd /home/kalyan/platform/personal/seva_care

# Install all dependencies and setup database
./bin/setup

# This will:
# - Install Ruby gems
# - Install Node packages (for Tailwind)
# - Create .env file
# - Create and migrate database
# - Load seed data
```

## Step 3: Start Server

```bash
# Start development server with Tailwind watch
./bin/dev

# Or start Rails only (without CSS watching)
rails server -p 7000
```

Visit: **http://localhost:7000**

## Step 4: Login with Test Accounts

### Patient Account
- **Phone**: `+919123456789`
- **Password**: `patient123`
- **Name**: Amit Patel (Mumbai)

### Doctor Account
- **Phone**: `+919876543210`
- **Password**: `doctor123`
- **Name**: Dr. Rajesh Kumar (Cardiologist)

### Admin Account
- **Phone**: `+919999999999`
- **Password**: `password123`

## Quick Commands

```bash
# Reset database with seed data
rails db:reset

# Open Rails console
rails console

# Run tests
bundle exec rspec

# View routes
rails routes

# Check database status
rails db:version

# Stop local Docker services
docker stop bookmydoc-postgres bookmydoc-redis
```

## Troubleshooting

### Port 7000 already in use?
```bash
lsof -i :7000
kill -9 <PID>
```

### Database connection error?
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Restart PostgreSQL
docker restart bookmydoc-postgres
```

### Redis connection error?
```bash
# Check if Redis is running
docker ps | grep redis

# Restart Redis
docker restart bookmydoc-redis
```

### Asset/CSS not loading?
```bash
# Rebuild Tailwind CSS
npm run build

# Or watch for changes
npm run watch
```

## What to Explore

1. **Patient Flow**:
   - Login as patient → Report symptoms → Find doctors → Book appointment

2. **Doctor Flow**:
   - Login as doctor → View dashboard → Manage appointments → Set availability

3. **Admin Flow**:
   - Login as admin → Verify doctors → View all users → Check audit logs

## Next Steps

- Explore the codebase in `app/` directory
- Check models in `app/models/`
- Review controllers in `app/controllers/`
- Look at views in `app/views/`
- Customize Tailwind in `config/tailwind.config.js`

## API Testing

```bash
# Test OTP service
rails console
> OtpService.send_code("+919876543210")

# Test AI Triage
> AiTriageService.analyze("chest pain and shortness of breath")

# Test Payment
> PaymentService.initiate_partial_payment(Appointment.first)

# Test Distance calculation
> DistanceService.calculate(19.0760, 72.8777, 28.6139, 77.2090)
```

## Need Help?

- Read the full [README.md](README.md)
- Check logs in `log/development.log`
- Open an issue on GitHub

---

Happy coding! 🚀
