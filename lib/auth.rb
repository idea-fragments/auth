# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"
require "bundler/setup"
require "idea_fragments_jwt"

module Auth
  class Auth::InvalidClaimsError < StandardError; end
  class Auth::TokenAlreadyUsedError < StandardError; end
  class Auth::TokenExpiredError < StandardError; end

  class << self
    attr_accessor :access_token_ttl_minutes,
                  :email_confirmation_ttl_days,
                  :invite_ttl_days,
                  :password_reset_ttl_days,
                  :redis,
                  :refresh_token_ttl_days
  end

  def self.access_token_expiration
    Time.now + access_token_ttl_minutes * 60
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

  def self.refresh_token_expiration
    TimeHelper.add_days(refresh_token_ttl_days)
  end
end

require_relative "./service"
Dir["#{File.dirname(__FILE__)}/**/*.rb"].sort.each { |f| require f }