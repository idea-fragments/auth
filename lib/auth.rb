# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"
require "bundler/setup"
require "idea_fragments_jwt"

module Auth
  class InvalidClaimsError < StandardError; end
  class InvalidTokenActionError < StandardError; end
  class TokenAlreadyUsedError < StandardError; end
  class UserEmailAlreadyConfirmedError < StandardError; end

  class TokenExpiredError < StandardError
    attr_accessor :other_claims, :record_id

    def initialize(record_id, other_claims)
      self.other_claims = other_claims
      self.record_id = record_id
      super("Token expired for user #{record_id}")
    end
  end

  TOKEN_ACTION_AUTHENTICATION = "authentication"
  TOKEN_ACTION_AUTHENTICATION_REFRESH = "authentication_refresh"
  TOKEN_ACTION_EMAIL_CONFIRMATION = "email_confirmation"
  TOKEN_ACTION_INVITE = "invite"
  TOKEN_ACTION_PASSWORD_RESET = "password_reset"
  TOKEN_ACTION_PASSWORDLESS_LOGIN = "passwordless_login"

  class << self
    attr_accessor :access_token_ttl_minutes,
                  :email_confirmation_ttl_days,
                  :invite_ttl_days,
                  :password_reset_ttl_days,
                  :passwordless_login_ttl_minutes,
                  :redis,
                  :refresh_token_ttl_days
  end

  def self.access_token_expiration
    TimeHelper.add_minutes(access_token_ttl_minutes)
  end

  def self.blacklist_key_for_token(token)
    "TOKEN_BLACKLIST-#{token}"
  end

  def self.email_confirmation_expiration
    TimeHelper.add_days(email_confirmation_ttl_days)
  end

  def self.invite_expiration
    TimeHelper.add_days(invite_ttl_days)
  end

  def self.jwt_secret
    Jwt.secret
  end

  def self.jwt_secret=(secret)
    Jwt.secret = secret
  end

  def self.jwt_signing_algorithm
    Jwt.algorithm
  end

  def self.jwt_signing_algorithm=(algorithm)
    Jwt.algorithm = algorithm
  end

  def self.password_reset_expiration
    TimeHelper.add_days(password_reset_ttl_days)
  end

  def self.passwordless_login_expiration
    TimeHelper.add_minutes(passwordless_login_ttl_minutes)
  end

  def self.refresh_token_expiration
    TimeHelper.add_days(refresh_token_ttl_days)
  end
end

require_relative "./auth/service"
Dir["#{File.dirname(__FILE__)}/**/*.rb"].sort.each { |f| require f }
