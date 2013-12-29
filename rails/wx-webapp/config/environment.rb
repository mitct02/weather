# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way


ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.9' unless defined? RAILS_GEM_VERSION
#RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION
#RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION
#RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

class Rails::Configuration
  attr_accessor :action_web_service
end

Rails::Initializer.run do |config|
  
  config.frameworks += [ :action_web_service]
  config.action_web_service = Rails::OrderedOptions.new
  config.autoload_paths += %W( #{RAILS_ROOT}/app/apis )
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.autoload_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_weather_session',
    :secret      => '6803c41ac5ec374527616ae238c1cbf0467aa1159d34ca6002ff84361334ee32fdf565c7b90485c9f57b10e766a9b9a07dee7ede3f389e892cafd4a1e1c425d8'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Set our local timezone
  # use rake time:zones:all|local|us to see list of options
  # use rake time:zones:all|local|us to see list of options
  config.time_zone = 'Eastern Time (US & Canada)'

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc

  ENV['TZ'] = 'US/Eastern'

  config.autoload_paths += %W( #{RAILS_ROOT}/app/apis )
  config.autoload_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir|
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end

# TODO - fix this kludge and get rid of the components directory
  config.autoload_paths += %W( #{RAILS_ROOT}/components )

  config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"
  
# config rack as a frozen gem
#  require 'rack'

end

#require 'actionwebservice'

# Rotate the log at 10 megabyte, keeping the last 10
#RAILS_DEFAULT_LOGGER = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log", 10, 10000000)

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below
