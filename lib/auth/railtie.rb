# frozen_string_literal: true

if defined?(Rails::Railtie)
  class Auth::Railtie < Rails::Railtie
    config.after_initialize do
      Auth.validate_configuration!
    end
  end
end
