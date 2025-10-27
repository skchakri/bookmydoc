require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BookMyDoc
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    config.time_zone = 'Asia/Kolkata'
    config.active_record.default_timezone = :local

    # Autoload lib directory
    config.autoload_paths << Rails.root.join('lib')

    # Enable Rack::Attack
    config.middleware.use Rack::Attack

    # Session store
    config.session_store :cookie_store, key: '_bookmydoc_session'

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
