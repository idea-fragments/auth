# frozen_string_literal: true

class Auth::EmailTokenCreator
  def self.call(user)
    Jwt::Encoder.call({
      exp: Auth.email_confirmation_expiration.to_i,
      dat: {
        id: user.id,
        email: user.email,
      }
    })
  end
end
