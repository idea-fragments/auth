# frozen_string_literal: true

class Auth::PasswordResetTokenCreator
  def self.call(user_id)
    Jwt::Encoder.call({
      exp: Auth::Auth.password_reset_expiration.to_i,
      dat: { user_id: user_id }
    })
  end
end
