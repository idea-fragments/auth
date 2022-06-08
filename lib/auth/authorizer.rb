# frozen_string_literal: true

class Auth::Authorizer
  def self.call(user_info = {})
    access_token = Jwt::Encoder.call({
      dat: user_info,
      exp: Auth.access_token_expiration.to_i,
    })

    refresh_token = Jwt::Encoder.call({
      dat: user_info,
      exp: Auth.refresh_token_expiration.to_i
    })

    { access_token: access_token, refresh_token: refresh_token }
  end
end
