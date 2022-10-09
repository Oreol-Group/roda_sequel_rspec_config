# frozen_string_literal: true

require 'json'

class App < Roda
  # https://github.com/jeremyevans/rack-unreloader#classes-split-into-multiple-files-
  Unreloader.require 'app/helpers'
  Unreloader.require 'app/serializers'

  include ::ApiErrors

  attr_reader :dry_validation_response

  def self.root
    ApplicationLoader.root
  end

  # https://roda.jeremyevans.net/documentation.html
  plugin :environments
  plugin :hash_routes
  plugin :typecast_params
  plugin :json

  plugin :default_headers,
         # 'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
         'Content-Type' => 'application/json'

  plugin :not_found do
    {}
  end

  # https://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/ErrorHandler.html
  plugin :error_handler do |e|
    case e
    # https://www.rubydoc.info/gems/sequel/4.8.0/Sequel
    # https://sequel.jeremyevans.net/rdoc/
    when Sequel::NoMatchingRow
      response.status = 404
      error_response e.message, meta: { 'meta' => I18n.t(:not_found, scope: 'api.errors') }
    when Sequel::UniqueConstraintViolation
      response.status = 422
      error_response e.message, meta: { 'meta' => I18n.t(:not_unique, scope: 'api.errors') }
    when Roda::RodaPlugins::TypecastParams::Error
      response.status = 422
      error_response e.message, meta: { 'meta' => I18n.t(:missing_parameters, scope: 'api.errors') }
    when KeyError
      response.status = 422
      error_response e.message, meta: { 'meta' => I18n.t(:missing_parameters, scope: 'api.errors') }
    # when NameError # Dry::Validation::Result  -  #  3-d catch
    #   response.status = 422
    #   key = @dry_validation_response.keys.first
    #   value = I18n.t(:blank, scope: "model.errors.reference_book.#{key}", default: @dry_validation_response[key])
    #   error_response({ key => value })
    else
      response.status = 500
      error_response e.message, meta: { 'meta' => e.class }
    end
  end

  # use Rack::Session::Cookie, secret: 'some_nice_long_random_string_DSKJH4378EYR7EGKUFH', key: '_roda_app_session'
  plugin :sessions,
         key: '_App.session',
         # cookie_options: {secure: ENV['RACK_ENV'] != 'test'}, # Uncomment if only allowing https:// access
         secret: ENV.send((ENV['RACK_ENV'] == 'development' ? :[] : :delete), 'APP_SESSION_SECRET')

  Unreloader.require('app/routes', delete_hook: proc { |f| hash_branch(File.basename(f).delete_suffix('.rb')) }) {}

  route do |r|
    r.root do
      { status: :ok, message: I18n.t('hello'), page_size: Settings.pagination.page_size }
    end
    # r.hash_routes
  end
end
