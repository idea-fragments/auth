# frozen_string_literal: true

if defined?(Rails::Railtie)
  class Auth::Railtie < Rails::Railtie
    initializer "rca_auth.validate_configuration" do
      Auth.validate_configuration!
    end
  end
end
