# BookMyDoc - Healthcare Appointment Platform for India

BookMyDoc is a full-stack Ruby on Rails application that connects patients with verified doctors across India. It provides AI-powered symptom analysis, appointment booking, payment integration (UPI), and comprehensive health record management.

## Features

### For Patients
- 🔍 **AI-Powered Symptom Analysis** - Describe symptoms and get specialist recommendations
- 🏥 **Find Doctors** - Search verified doctors by specialization and location
- 📅 **Book Appointments** - Real-time availability with secure UPI payments
- 📱 **Mobile Ready** - Hotwire Native support for Android & iOS
- 📄 **Digital Health Records** - Upload and manage prescriptions, lab reports
- 🔔 **Real-time Notifications** - Get updates on appointments and test results

### For Doctors
- 📊 **Dashboard** - Manage daily appointments and patient interactions
- ⏰ **Availability Management** - Set and update appointment slots
- 📝 **Patient Notes** - Record consultation notes with audio/screenshot support
- 🧪 **Test Orders** - Request lab tests and review results
- 🔐 **Verified Profiles** - Admin-verified doctor accounts with QR codes

### For Admins
- 👥 **User Management** - Full CRUD for patients and doctors
- ✅ **Doctor Verification** - Approve and verify doctor credentials
- 📊 **Analytics Dashboard** - View platform statistics
- 🔍 **Audit Logs** - Track all system activities

## Tech Stack

- **Framework**: Ruby on Rails 7.1
- **Frontend**: Tailwind CSS + Flowbite + Hotwire (Turbo/Stimulus)
- **Database**: PostgreSQL
- **Cache/Jobs**: Redis
- **File Storage**: Active Storage
- **Authentication**: BCrypt (custom implementation, no Devise)
- **Rate Limiting**: Rack::Attack
- **QR Codes**: RQRCode
- **Mobile**: Hotwire Native (iOS/Android)
- **Deployment**: Docker + Docker Compose

## Prerequisites

Before you begin, ensure you have the following installed:

- Ruby 3.2.2
- PostgreSQL 15+ (running locally on port 5432)
- Redis 7+ (running locally on port 6379)
- Docker & Docker Compose (optional)
- Git

## Local Setup (Without Docker)

### 1. Start Local Services

Make sure PostgreSQL and Redis are running locally:

```bash
# Start PostgreSQL (example with Docker)
docker run -d \
  --name bookmydoc-postgres \
  -e POSTGRES_USER=bookmydoc \
  -e POSTGRES_PASSWORD=bookmydoc_dev_password \
  -e POSTGRES_DB=bookmydoc_development \
  -p 5432:5432 \
  postgres:15

# Start Redis (example with Docker)
docker run -d \
  --name bookmydoc-redis \
  -p 6379:6379 \
  redis:7-alpine
```

Or use system services:
```bash
# On Ubuntu/Debian
sudo systemctl start postgresql
sudo systemctl start redis-server

# On macOS with Homebrew
brew services start postgresql@15
brew services start redis
```

### 2. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd seva_care

# Install dependencies
bundle install

# Copy environment variables
cp .env.example .env

# Create database
rails db:create

# Run migrations
rails db:migrate

# Load seed data
rails db:seed
```

### 3. Start the Server

```bash
# Start Rails server on port 7000
rails server -p 7000

# Or use Puma directly
bundle exec puma -p 7000
```

Visit: [http://localhost:7000](http://localhost:7000)

## Docker Setup

### Option 1: Using Docker Compose (All Services)

```bash
# Build and start all services
docker-compose up --build

# Run in detached mode
docker-compose up -d

# View logs
docker-compose logs -f web

# Stop services
docker-compose down
```

### Option 2: Using Local DB/Redis with Docker Rails

If you prefer to run PostgreSQL and Redis locally:

```bash
# Ensure local services are running
docker ps  # Check if postgres and redis containers are running

# Build and run Rails in Docker
docker-compose up web
```

## Database Setup

### Create PostgreSQL User (if needed)

```sql
-- Connect to PostgreSQL
psql postgres

-- Create user
CREATE USER bookmydoc WITH PASSWORD 'bookmydoc_dev_password';
ALTER USER bookmydoc CREATEDB;

-- Exit
\q
```

### Seed Data

The seed file creates:

**Admin User:**
- Phone: `+919999999999`
- Password: `password123`

**Doctors:**
1. Dr. Rajesh Kumar (Cardiologist, Mumbai)
   - Phone: `+919876543210`
   - Password: `doctor123`

2. Dr. Priya Sharma (ENT, Delhi)
   - Phone: `+919876543211`
   - Password: `doctor123`

**Patients:**
1. Amit Patel (Mumbai)
   - Phone: `+919123456789`
   - Password: `patient123`

2. Sneha Reddy (Delhi)
   - Phone: `+919123456788`
   - Password: `patient123`

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with coverage
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/models/user_spec.rb
```

## Key Features Implementation

### 1. Authentication & Authorization

- Custom authentication with BCrypt (no Devise)
- Role-based access control (Patient, Doctor, Admin)
- OTP verification for phone numbers (stubbed for development)
- Session-based authentication with CSRF protection

### 2. AI-Powered Symptom Analysis

Located in `app/services/ai_triage_service.rb`:
- Keyword-based matching (stub for production AI)
- Recommends specializations based on symptoms
- Suggests nearby doctors

### 3. Appointment Booking Flow

1. Patient reports symptoms → AI recommends specialists
2. Patient browses nearby doctors
3. Patient selects available time slot
4. Payment via UPI (stubbed for development)
5. Appointment confirmed → Both parties notified

### 4. Payment Integration

Located in `app/services/payment_service.rb`:
- Stubs for Razorpay, PhonePe, Paytm
- Partial payment at booking + remaining at visit
- Ready for production payment gateway integration

### 5. Hotwire (Turbo/Stimulus)

Examples:
- Live appointment rescheduling
- Real-time notifications
- Inline test result reviews
- No full page reloads

### 6. Rate Limiting

Configured in `config/initializers/rack_attack.rb`:
- Login attempts: 5/minute
- OTP verification: 3/minute
- Signup: 3/5 minutes
- General requests: 300/5 minutes

## Project Structure

```
seva_care/
├── app/
│   ├── controllers/
│   │   ├── admin/              # Admin namespace
│   │   ├── doctors/            # Doctor namespace
│   │   ├── patients/           # Patient namespace
│   │   └── ...                 # Shared controllers
│   ├── models/                 # ActiveRecord models
│   ├── services/               # Business logic services
│   ├── views/
│   │   ├── layouts/
│   │   ├── shared/             # Reusable partials
│   │   └── ...
│   └── javascript/
│       └── controllers/        # Stimulus controllers
├── config/
│   ├── initializers/
│   │   └── rack_attack.rb      # Rate limiting
│   ├── routes.rb
│   └── ...
├── db/
│   ├── migrate/                # Database migrations
│   └── seeds.rb                # Sample data
├── docker-compose.yml
├── Dockerfile
└── README.md
```

## API Integrations (Production Ready)

### SMS/OTP Provider
Replace stub in `app/services/otp_service.rb` with:
- Twilio
- MSG91
- AWS SNS
- Any Indian SMS gateway

### Payment Gateway
Replace stub in `app/services/payment_service.rb` with:
- Razorpay
- PhonePe
- Paytm
- Any UPI payment gateway

### AI/Medical Analysis
Replace stub in `app/services/ai_triage_service.rb` with:
- Medical LLM API
- Symptom checker API
- Custom AI model

## Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
DATABASE_HOST=localhost
DATABASE_USERNAME=bookmydoc
DATABASE_PASSWORD=bookmydoc_dev_password
REDIS_URL=redis://localhost:6379/0
RAILS_ENV=development
PORT=7000
```

## Hotwire Native (Mobile Apps)

The app is designed to work seamlessly with Hotwire Native:

1. All responses use Turbo Streams for live updates
2. Mobile apps can consume the same Rails backend
3. No separate API needed
4. Native iOS/Android wrappers render Rails views

See [Hotwire Native documentation](https://native.hotwired.dev/) for setup.

## Security Features

- ✅ CSRF protection enabled
- ✅ Rate limiting with Rack::Attack
- ✅ BCrypt password hashing
- ✅ Role-based access control
- ✅ Audit logging for sensitive actions
- ✅ Input validation and sanitization
- ✅ Secure session management

## Production Deployment

### Prerequisites
1. SSL certificate for HTTPS
2. Production database (PostgreSQL)
3. Redis instance
4. File storage (S3 or similar)
5. Email service (optional)
6. SMS gateway
7. Payment gateway

### Environment Setup

```bash
# Set production environment variables
export RAILS_ENV=production
export DATABASE_URL=postgres://user:pass@host:5432/bookmydoc_production
export REDIS_URL=redis://host:6379/0
export RAILS_MASTER_KEY=your_master_key
export SECRET_KEY_BASE=$(rails secret)

# Precompile assets
rails assets:precompile

# Run migrations
rails db:migrate

# Start server
rails server -e production -p 7000
```

## Troubleshooting

### Database Connection Issues
```bash
# Check if PostgreSQL is running
pg_isready -h localhost -p 5432

# Recreate database
rails db:drop db:create db:migrate db:seed
```

### Redis Connection Issues
```bash
# Check if Redis is running
redis-cli ping  # Should return PONG

# Restart Redis
docker restart bookmydoc-redis
```

### Port Already in Use
```bash
# Find process using port 7000
lsof -i :7000

# Kill the process
kill -9 <PID>
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Create an issue on GitHub
- Email: support@bookmydoc.in

## Acknowledgments

- Built with Rails 7 + Hotwire
- UI components from Flowbite
- Styled with Tailwind CSS
- Icons from Heroicons

---

**BookMyDoc** - Making healthcare accessible across India 🇮🇳
