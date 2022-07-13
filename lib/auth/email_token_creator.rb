# frozen_string_literal: true

class Auth::EmailTokenCreator
  def self.call(user_id, email)
    Jwt::Encoder.call({
      action: Auth::TOKEN_ACTION_EMAIL_CONFIRMATION,
      dat: { id: user_id, email: email, },
      exp: Auth.email_confirmation_expiration.to_i,
    })
  end
end
