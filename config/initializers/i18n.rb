# frozen_string_literal: true

I18n.load_path += Dir["#{File.join(ApplicationLoader.root, 'config/locales')}/**/*.yml"]
I18n.available_locales = %i[en ru]
# I18n.default_locale = :ru # (note that `en` is already the default!)
