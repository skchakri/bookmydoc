# 🚀 Final Setup Steps for BookMyDoc

Your PostgreSQL and Redis are already running! Just follow these steps:

## ✅ Current Status

- ✅ PostgreSQL: Running on `localhost:5432` (user: `root`, password: `password`)
- ✅ Redis: Running on `localhost:6379`
- ✅ .env file created with correct credentials
- ⏳ Need to install dependencies and start Rails

## 📋 Step-by-Step Instructions

### Step 1: Install System Dependencies

```bash
sudo apt-get update
sudo apt-get install -y libpq-dev build-essential
```

**Why?** The `pg` gem needs PostgreSQL development headers to compile.

### Step 2: Install Ruby Gems

```bash
cd /home/kalyan/platform/personal/seva_care
bundle install
```

This will install all Ruby dependencies including Rails, Hotwire, etc.

### Step 3: Install Node Packages

```bash
npm install
```

This installs Tailwind CSS and its plugins.

### Step 4: Setup Database

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Load seed data (creates test users)
rails db:seed
```

### Step 5: Build Tailwind CSS

```bash
npm run build
```

### Step 6: Start the Server

```bash
# Option 1: Just Rails
rails server -p 7000

# Option 2: Rails + Tailwind watch (recommended for development)
./bin/dev
```

## 🌐 Access the Application

Open your browser: **http://localhost:7000**

## 🔑 Test Accounts

Once running, you can login with:

### Admin
- Phone: `+919999999999`
- Password: `password123`

### Doctor
- Phone: `+919876543210`
- Password: `doctor123`
- Name: Dr. Rajesh Kumar (Cardiologist)

### Patient
- Phone: `+919123456789`
- Password: `patient123`
- Name: Amit Patel

## 🔧 Troubleshooting

### If bundle install fails with pg gem error:
```bash
# Install libpq-dev first
sudo apt-get install -y libpq-dev build-essential

# Then retry
bundle install
```

### If database connection fails:
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Check credentials in .env file
cat .env

# Test connection
psql -h localhost -U root -d postgres
# Password: password
```

### If Redis connection fails:
```bash
# Check if Redis is running
docker ps | grep redis

# Test connection
redis-cli ping
# Should return: PONG
```

### Clean slate:
```bash
# Drop and recreate database
rails db:drop db:create db:migrate db:seed
```

## 📊 What's Included

- ✅ 8 Database models with full associations
- ✅ 20+ Controllers (Patient, Doctor, Admin flows)
- ✅ Tailwind CSS + Flowbite UI components
- ✅ Hotwire (Turbo Frames + Streams) for real-time updates
- ✅ 5 Service objects (OTP, AI Triage, Payment, Distance)
- ✅ Comprehensive seed data
- ✅ Rate limiting with Rack::Attack
- ✅ Audit logging
- ✅ File uploads with Active Storage
- ✅ QR code generation for doctors

## 🎯 Next Steps After Running

1. Browse to http://localhost:7000
2. Click "Sign up" or login with test accounts
3. Explore patient flow (report symptoms, find doctors, book appointments)
4. Try doctor dashboard (manage appointments, create test orders)
5. Check admin panel (verify doctors, view audit logs)

---

**Need help?** Check the logs:
```bash
# Rails logs
tail -f log/development.log

# PostgreSQL logs
docker logs postgres

# Redis logs
docker logs redis
```
