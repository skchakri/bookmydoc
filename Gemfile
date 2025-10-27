source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Rails framework
gem "rails", "~> 7.1.0"

# Database
gem "pg", "~> 1.5"

# Asset pipeline & frontend
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"

# Hotwire
gem "hotwire-rails"

# Authentication
gem "bcrypt", "~> 3.1.7"

# Cache & background jobs
gem "redis", "~> 5.0"

# File uploads
gem "image_processing", "~> 1.2"
gem "active_storage_validations"

# QR code generation
gem "rqrcode", "~> 2.2"
gem "mini_magick", "~> 4.12"
gem "chunky_png", "~> 1.4"

# Pagination
gem "kaminari"

# Rate limiting
gem "rack-attack"

# Web server
gem "puma", "~> 6.0"

# Timezone data
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
