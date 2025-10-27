# 🎉 BookMyDoc is Now Running in Docker!

## ✅ Current Status

All services are **UP and RUNNING**:

```
SERVICE          STATUS     PORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PostgreSQL       Running    5432
Redis            Running    6379
Rails Web        Running    7000
```

## 🌐 Access the Application

**Open your browser and visit:**
```
http://localhost:7000
```

## 🔑 Test Accounts

### Admin Account
- **Phone**: `+919999999999`
- **Password**: `password123`
- Access: Full system admin dashboard

### Doctor Accounts
1. **Dr. Rajesh Kumar** (Cardiologist, Mumbai)
   - **Phone**: `+919876543210`
   - **Password**: `doctor123`

2. **Dr. Priya Sharma** (ENT, Delhi)
   - **Phone**: `+919876543211`
   - **Password**: `doctor123`

### Patient Accounts
1. **Amit Patel** (Mumbai)
   - **Phone**: `+919123456789`
   - **Password**: `patient123`

2. **Sneha Reddy** (Delhi)
   - **Phone**: `+919123456788`
   - **Password**: `patient123`

## 📊 Seed Data

The database has been populated with:
- ✅ 5 Users (1 admin, 2 doctors, 2 patients)
- ✅ 12 Appointment slots
- ✅ 3 Appointments (past, upcoming, today)
- ✅ 2 Symptom reports
- ✅ 1 Test order
- ✅ 4 Notifications

## 🛠️ Useful Commands

### View Logs
```bash
# All services
docker compose logs -f

# Just Rails
docker compose logs -f web

# PostgreSQL
docker compose logs -f db

# Redis
docker compose logs -f redis
```

### Rails Commands
```bash
# Rails console
docker compose exec web rails console

# Run migrations
docker compose exec web rails db:migrate

# Reset database
docker compose exec web rails db:reset

# Generate new migration
docker compose exec web rails g migration MigrationName
```

### Container Management
```bash
# Stop all services
docker compose down

# Restart all services
docker compose restart

# Restart just web
docker compose restart web

# Rebuild and restart
docker compose up -d --build

# View container status
docker compose ps
```

### Database Access
```bash
# PostgreSQL
docker compose exec db psql -U bookmydoc -d bookmydoc_development

# Redis
docker compose exec redis redis-cli
```

## 🧪 Testing the Application

### 1. Patient Flow
1. Go to http://localhost:7000
2. Click "Sign up"
3. Or login with: `+919123456789` / `patient123`
4. Click "Report Symptoms"
5. Enter symptoms like "chest pain and shortness of breath"
6. Get AI recommendations
7. Browse doctors
8. Book an appointment

### 2. Doctor Flow
1. Login with: `+919876543210` / `doctor123`
2. View today's appointments
3. Manage availability slots
4. Create test orders
5. Review test results

### 3. Admin Flow
1. Login with: `+919999999999` / `password123`
2. View all users
3. Verify doctors
4. Check audit logs
5. View system stats

## 🔧 Troubleshooting

### Port already in use?
```bash
# Check what's using port 7000
lsof -i :7000

# Kill it
kill -9 $(lsof -t -i:7000)

# Restart Docker
docker compose restart
```

### Database connection errors?
```bash
# Check PostgreSQL
docker compose logs db

# Restart database
docker compose restart db

# Recreate database
docker compose exec web rails db:drop db:create db:migrate db:seed
```

### Clear everything and start fresh?
```bash
# Stop and remove all containers, volumes
docker compose down -v

# Rebuild from scratch
docker compose up -d --build

# Setup database
docker compose exec web rails db:create db:migrate db:seed
```

## 📁 File Structure

```
seva_care/
├── app/                    # Rails application
│   ├── controllers/        # 20+ controllers
│   ├── models/            # 8 domain models
│   ├── services/          # 5 service objects
│   ├── views/             # Tailwind + Flowbite views
│   └── javascript/        # Stimulus controllers
├── db/
│   ├── migrate/           # 9 migrations
│   └── seeds.rb           # Sample data
├── config/
│   ├── routes.rb          # All routes configured
│   └── ...
├── docker-compose.yml     # Docker services
└── Dockerfile             # Rails container