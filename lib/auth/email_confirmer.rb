# frozen_string_literal: true

class Auth::EmailConfirmer
  def self.call(token:, user_finder:)
    claims = Auth::TokenConfirmer.call(
      action: Auth::TOKEN_ACTION_EMAIL_CONFIRMATION,
      token:,
    )
    user_data = user_finder.call(claims:)
    raise Auth::UserEmailAlreadyConfirmedError if user_data[:email_confirmed]
  end
end
