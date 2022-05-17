# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in auth.gemspec
gemspec

gem "activesupport", "~> 7.0"
gem "idea-fragments-jwt", "~> 0.1", git: "https://github.com/idea-fragments/idea-fragments-jwt"
gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
gem "rubocop", "~> 1.21"

group :test do
  gem "mock_redis"
  gem "rubocop-rspec", require: false
  gem "timecop", "~> 0.9"
end
