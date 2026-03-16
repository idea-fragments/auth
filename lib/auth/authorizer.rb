# frozen_string_literal: true

class Auth::Authorizer < Auth::Service
  def self.call(user_info: {})
    new(user_info:).call
  end

  def call
    { access_token:, refresh_token: }
  end

  private

  attr_accessor :user_info

  def access_token
    Auth::SecurityTokenCreator.call(
      action: Auth::TOKEN_ACTION_AUTHENTICATION,
      claims: user_info,
      expires_at: Auth.access_token_expiration
    )
  end

  def refresh_token
    Auth::SecurityTokenCreator.call(
      action: Auth::TOKEN_ACTION_AUTHENTICATION_REFRESH,
      claims: user_info,
      expires_at: Auth.refresh_token_expiration
    )
  end

  def initialize(user_info:)
    super()
    self.user_info = user_info
  end
end
