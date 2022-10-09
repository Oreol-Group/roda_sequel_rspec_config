# frozen_string_literal: true

# Update schema

dump_schema = lambda do
  # https://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/SchemaDumper.html#method-i-dump_schema_migration
  # schema = DB.dump_schema_migration(same_db: true) # bad result
  schema = `sequel -D #{DB.opts[:uri]}` # great!
  body = "# Version: #{Time.now.strftime("%Y%m%d%H%M%S\n")}#{schema}"
  File.open('db/schema.rb', 'w') { |f| f.write(body) }
end

# Migrate

migrate = lambda do |env, version|
  ENV['RACK_ENV'] = env
  begin
    require_relative '.env'
  rescue LoadError
    # do nothing
  end
  require 'config'
  require_relative 'config/initializers/config'
  require_relative 'config/initializers/db'
  require 'logger'
  Sequel.extension :migration
  DB.loggers << Logger.new($stdout) if DB.loggers.empty?
  Sequel::Migrator.apply(DB, 'db/migrations', version)
end

desc 'Migrate test database to latest version'
task :test_up do
  migrate.call('test', nil)
  dump_schema.call
end

desc 'Migrate test database all the way down'
task :test_down do
  migrate.call('test', 0)
  dump_schema.call
end

desc 'Migrate test database all the way down and then back up'
task :test_bounce do
  migrate.call('test', 0)
  Sequel::Migrator.apply(DB, 'db/migrations')
  dump_schema.call
end

desc 'Migrate development database to latest version'
task :dev_up do
  migrate.call('development', nil)
  dump_schema.call
end

desc 'Migrate development database to all the way down'
task :dev_down do
  migrate.call('development', 0)
  dump_schema.call
end

desc 'Migrate development database all the way down and then back up'
task :dev_bounce do
  migrate.call('development', 0)
  Sequel::Migrator.apply(DB, 'db/migrations')
  dump_schema.call
end

desc 'Migrate production database to latest version'
task :prod_up do
  migrate.call('production', nil)
end

desc 'Migrate production database to all the way down'
task :prod_down do
  migrate.call('production', 0)
  dump_schema.call
end

# Seed

seeds = lambda do |env|
  ENV['RACK_ENV'] = env
  begin
    require_relative '.env'
  rescue LoadError
    # do nothing
  end
  require 'config'
  require_relative 'config/initializers/config'
  require_relative 'config/initializers/db'
  require_relative 'config/initializers/models'
  require 'logger'
  require_relative 'db/seeds'
end

desc 'Seed test database'
task :test_seed do
  seeds.call('test')
end

desc 'Seed development database'
task :dev_seed do
  seeds.call('development')
end

desc 'Seed production database'
task :prod_seed do
  seeds.call('production')
end

Rake.add_rakelib('rakelib/**')

last_line = __LINE__
# Utils

desc 'Give the application an appropriate name'
task :setup, [:name] do |_t, args|
  unless (name = args[:name])
    warn 'ERROR: Must provide a name argument: example: rake "setup[AppName]"'
    exit(1)
  end

  require 'securerandom'
  require 'fileutils'
  name.sub!(name[0], name[0].upcase)
  lower_name = name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
  upper_name = lower_name.upcase
  random_bytes = -> { [SecureRandom.random_bytes(64).gsub("\x00") { ((rand * 255).to_i + 1).chr }].pack('m').inspect }

  File.write('.env.rb', <<~ENV_FILE)
    # frozen_string_literal: true

    case ENV['RACK_ENV'] ||= 'development'
    when 'test'
      ENV['#{upper_name}_SESSION_SECRET'] ||= #{random_bytes.call}.unpack1('m')
      ENV['#{upper_name}_DATABASE_URL'] ||= 'postgres://user:password@127.0.0.1:5432/#{lower_name}_test'
    when 'production'
      ENV['#{upper_name}_SESSION_SECRET'] ||= #{random_bytes.call}.unpack1('m')
      ENV['#{upper_name}_DATABASE_URL'] ||= 'postgres://user:password@127.0.0.1:5432/#{lower_name}_production'
    else
      ENV['#{upper_name}_SESSION_SECRET'] ||= #{random_bytes.call}.unpack1('m')
      ENV['#{upper_name}_DATABASE_URL'] ||= 'postgres://user:password@127.0.0.1:5432/#{lower_name}_development'
    end
  ENV_FILE

  %w[config/application.rb config/initializers/db.rb config.ru config/environment.rb
     spec/application_helper.rb].each do |f|
    File.write(f,
               File.read(f)
               .gsub('App ', "#{name} ")
               .gsub('App.', "#{name}.")
               .gsub("App'", "#{name}'")
               .gsub('App}', "#{name}}")
               .gsub('APP_', "#{upper_name}_"))
  end
  %w[spec/routes/api/v1/app_spec.rb].each do |f|
    File.write(f, File.read(f).gsub('App', name))
  end

  File.write(__FILE__, File.read(__FILE__).split("\n")[0...(last_line - 2)].join("\n") << "\n")
  FileUtils.remove_dir('.git')
end
