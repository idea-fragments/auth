# frozen_string_literal: true

class Auth::Authorizer
  def self.call(user_info = {})
    access_token = Jwt::Encoder.call({
      exp: Auth.access_token_expiration.to_i,
      dat: user_info
    })

    refresh_token = Jwt::Encoder.call({ exp: Auth.refresh_token_expiration.to_i })

    { access_token: access_token, refresh_token: refresh_token }
  end
end
