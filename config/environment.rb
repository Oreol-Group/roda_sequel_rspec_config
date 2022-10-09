# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

begin
  require_relative '../.env'
rescue LoadError
  # do nothing
end

require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])

dev = ENV['RACK_ENV'] == 'development'

if dev
  require 'logger'
  logger = Logger.new($stdout)
end

Unreloader = Rack::Unreloader.new(subclasses: %w[Roda Sequel::Model], logger: logger, reload: dev) { App }

require_relative 'application_loader'
ApplicationLoader.load_app!

Unreloader.require('config/application.rb') { 'App' }
