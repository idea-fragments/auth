# frozen_string_literal: true

class Auth::PasswordResetTokenCreator
  def self.call(user_id)
    Jwt::Encoder.call({
      action: Auth::TOKEN_ACTION_PASSWORD_RESET,
      dat: { id: user_id },
      exp: Auth.password_reset_expiration.to_i,
    })
  end
end
