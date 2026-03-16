# frozen_string_literal: true

class Auth::EmailTokenCreator < Auth::Service
  def self.call(email:, user_id:)
    new(email:, user_id:).call
  end

  def call
    Auth::SecurityTokenCreator.call(
      action: Auth::TOKEN_ACTION_EMAIL_CONFIRMATION,
      claims: { email:, user_id: },
      expires_at: Auth.email_confirmation_expiration
    )
  end

  private

  attr_accessor :email, :user_id

  def initialize(email:, user_id:)
    super()
    self.email = email
    self.user_id = user_id
  end
end
