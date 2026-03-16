# frozen_string_literal: true

class Auth::Refresher < Auth::Service
  def self.call(access_token:, refresh_token:, user_info:)
    new(access_token:, refresh_token:, user_info:).call
  end

  def call
    confirm_access_token
    confirm_refresh_token
    Auth::Authorizer.call(user_info:)
  end

  private

  attr_accessor :access_token, :refresh_token, :user_info

  def confirm_access_token
    Auth::TokenConfirmer.call(
      action: Auth::TOKEN_ACTION_AUTHENTICATION,
      skip_expiration_check: true,
      token: access_token,
    )
  end

  def confirm_refresh_token
    Auth::TokenConfirmer.call(
      action: Auth::TOKEN_ACTION_AUTHENTICATION_REFRESH,
      token: refresh_token,
    )
  end

  def initialize(access_token:, refresh_token:, user_info:)
    super()
    self.access_token = access_token
    self.refresh_token = refresh_token
    self.user_info = user_info
  end
end
