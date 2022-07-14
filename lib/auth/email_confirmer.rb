# frozen_string_literal: true

class Auth::EmailConfirmer
  def self.call(token, user_finder:, callback:)
    Auth::TokenConfirmer.call(
      token,
      action: Auth::TOKEN_ACTION_EMAIL_CONFIRMATION,
      record_finder: user_finder,
      callback: lambda do |user|
        raise Auth::TokenAlreadyUsedError if user.email_confirmed?
        callback.call(user)
      end
    )
  end
end
