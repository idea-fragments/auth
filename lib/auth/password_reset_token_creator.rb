# frozen_string_literal: true

class Auth::PasswordResetTokenCreator < Auth::Service
  def self.call(user_id:)
    Auth::SecurityTokenCreator.call(
      action: Auth::TOKEN_ACTION_PASSWORD_RESET,
      claims: { user_id: },
      expires_at: Auth.password_reset_expiration
    )
  end
end
