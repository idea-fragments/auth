# frozen_string_literal: true

class Auth::PasswordlessLoginTokenCreator
  def self.call(user_id)
    Jwt::Encoder.call({
      action: Auth::TOKEN_ACTION_PASSWORDLESS_LOGIN,
      dat: { id: user_id },
      exp: Auth.passwordless_login_expiration.to_i,
    })
  end
end
