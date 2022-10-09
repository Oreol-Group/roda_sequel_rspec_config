# frozen_string_literal: true

# CODE EXECUTION ORDER IS IMPORTANT DURING SEQUEL INITIALIZATION PROCESS.
# See http://sequel.jeremyevans.net/rdoc/files/doc/code_order_rdoc.html

require 'sequel/core'

# Include the Postgres JSON Operations extension
# https://sequel.jeremyevans.net/rdoc/files/doc/postgresql_rdoc.html
Sequel.extension(:pg_json_ops)

# Delete APP_DATABASE_URL from the environment, so it isn't accidently
# passed to subprocesses.  APP_DATABASE_URL may contain passwords.
DB = Sequel.connect(ENV.delete('APP_DATABASE_URL'), Settings.db&.to_hash&.compact! || {})

# Load Sequel Database/Global extensions here
DB.extension :pagination

# https://github.com/jeremyevans/sequel/blob/master/lib/sequel/extensions/schema_dumper.rb
DB.extension :schema_dumper

# Ask Sequel to use the Postgres JSON extension with your database
DB.extension :pg_array, :pg_json

# https://github.com/jeremyevans/sequel/blob/7a70ac6d719c21bcb404adf6159cbd2769d9246f/lib/sequel/extensions/pg_timestamptz.rb
DB.extension :pg_timestamptz

# https://github.com/jeremyevans/sequel/blob/7a70ac6d719c21bcb404adf6159cbd2769d9246f/lib/sequel/extensions/pg_json.rb
DB.wrap_json_primitives = true

Sequel.default_timezone = :utc
