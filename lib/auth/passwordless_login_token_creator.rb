# frozen_string_literal: true

class Auth::PasswordlessLoginTokenCreator < Auth::Service
  def self.call(user_id:)
    Auth::SecurityTokenCreator.call(
      action: Auth::TOKEN_ACTION_PASSWORDLESS_LOGIN,
      claims: { user_id: },
      expires_at: Auth.passwordless_login_expiration
    )
  end
end
