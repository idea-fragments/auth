# frozen_string_literal: true

require "auth"
require "mock_redis"
require "timecop"

Auth.redis = MockRedis.new

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # config.before(:each) do
  #   $redis_pool.with { |redis| redis.flushdb } if Rails.env.test?
  # end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Auth.access_token_ttl_minutes = 10
    Auth.email_confirmation_ttl_days = 2
    Auth.invite_ttl_days = 7
    Auth.password_reset_ttl_days = 2
    Auth.passwordless_login_ttl_minutes = 30
    Auth.refresh_token_ttl_days = 7
    Auth.jwt_signing_algorithm = "HS512"
    Auth.jwt_secret = "omg the secret"
  end
end
