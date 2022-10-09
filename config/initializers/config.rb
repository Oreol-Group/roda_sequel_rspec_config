# frozen_string_literal: true

# https://github.com/rubyconfig/config
Config.setup do |config|
  config.use_env = true
  config.env_prefix = 'ENV'
  config.env_separator = '__'
end

Config.load_and_set_settings(
  Config.setting_files(File.expand_path('..', __dir__), ENV['RACK_ENV'])
)
