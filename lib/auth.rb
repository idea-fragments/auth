# frozen_string_literal: true

require "active_support"
require 'active_support/core_ext'
require 'active_support/core_ext/enumerable'
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/numeric/time"
require "bundler/setup"
require "idea_fragments_jwt"

module Auth
  class ConfigurationError < StandardError; end
  class InvalidTokenActionError < StandardError; end
  class NoJwtExpirationError < StandardError; end
  class TokenAlreadyUsedError < StandardError; end
  class UserEmailAlreadyConfirmedError < StandardError; end
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
    access_token_ttl_minutes.minutes.from_now
  end

  def self.blacklist_key_for_token(token)
    "TOKEN_BLACKLIST-#{token}"
  end

  def self.email_confirmation_expiration
    email_confirmation_ttl_days.days.from_now
  end

  def self.invite_expiration
    invite_ttl_days.days.from_now
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
    password_reset_ttl_days.days.from_now
  end

  def self.passwordless_login_expiration
    passwordless_login_ttl_minutes.minutes.from_now
  end

  def self.refresh_token_expiration
    refresh_token_ttl_days.days.from_now
  end

  REQUIRED_CONFIGURATION = [
    :access_token_ttl_minutes,
    :jwt_secret,
    :jwt_signing_algorithm,
    :password_reset_ttl_days,
    :passwordless_login_ttl_minutes,
    :redis,
    :refresh_token_ttl_days,
  ].freeze

  def self.validate_configuration!
    missing = REQUIRED_CONFIGURATION.select { |field| public_send(field).nil? }
    return if missing.empty?

    raise ConfigurationError, "Auth is missing required configuration: #{missing.join(', ')}"
  end
end

require_relative "./auth/service"
Dir["#{File.dirname(__FILE__)}/**/*.rb"].sort.each { |f| require f }
