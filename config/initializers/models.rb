# frozen_string_literal: true

# CODE EXECUTION ORDER IS IMPORTANT DURING SEQUEL INITIALIZATION PROCESS.
# See http://sequel.jeremyevans.net/rdoc/files/doc/code_order_rdoc.html

require 'sequel/model'

Sequel::Model.cache_associations = false if ENV['RACK_ENV'] == 'development'

# https://sequel.jeremyevans.net/plugins.html
Sequel::Model.plugin :prepared_statements
Sequel::Model.plugin :require_valid_schema
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :subclasses unless ENV['RACK_ENV'] == 'development'

unless defined?(Unreloader)
  require 'rack/unreloader'
  Unreloader = Rack::Unreloader.new(reload: false)
end

Unreloader.require('app/models') { |f| Sequel::Model.send(:camelize, File.basename(f).delete_suffix('.rb')) }

if %w[development test].include?(ENV['RACK_ENV'])
  require 'logger'
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::FATAL if ENV['RACK_ENV'] == 'test'
  DB.loggers << LOGGER
end

Sequel::Model.freeze_descendents unless ENV['RACK_ENV'] == 'development'
