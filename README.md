# Auth
![example workflow](https://github.com/idea-fragments/auth/actions/workflows/main.yml/badge.svg)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/auth`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem "auth", "~> 0.1", git: "https://github.com/idea-fragments/auth"
```

And then execute:

    $ bundle install

## Setup and Configuration

The gem will need to be required in your code. Since the gem is loaded from a git repo, you'll need to require bundler/setup before requiring the gem.

```ruby
require "bundler/setup"
require "auth"
```

Create a file in `config/initializers` called `auth.rb` and add the following. Be sure to set the variables to the values you need for your project.
```ruby
Auth.access_token_ttl_minutes = 5
Auth.email_confirmation_ttl_days = 5
Auth.invite_ttl_days = 5
Auth.refresh_token_ttl_days = 5
Auth.jwt_signing_algorithm = "<your hashing algorithm>"
Auth.jwt_secret = "<your secret key>"
```

This gem relies on Redis. You'll need to provide a copy of a redis instance from the `redis` gem, found here: https://github.com/redis/redis-rb
```ruby
Auth.redis = your redis instance
```

## Usage
#### Create access and refresh tokens
```ruby
user_info = { id: 323, name: "John Doe", email: "example@example.com" }
tokens = Auth::Authorizer.call(user)
access_token = tokens[:access_token]
refresh_token = tokens[:refresh_token]

# Decoded access token
# {
#   action: "authentication",
#   dat: { id: 323, name: "John Doe", email: "example@example.com"},
#   exp: 452546536562
# }
# 
# Decoded refresh token
# {
#   action: "authentication_refresh",
#   dat: { id: 323, name: "John Doe", email: "example@example.com"},
#   exp: 6587954543654
# }
```

#### Get claims from an access token
This service will check if the token is not expired, valid via signature verification, as well as checking if the token has been blacklisted.
```ruby
claims = Auth::ClaimsReader.call(access_token)

# add leeway to the expiry time to account for clock skew
Auth::ClaimsReader.call(access_token, expiration_leeway: 60.seconds)

# skip signature verification
Auth::ClaimsReader.call(access_token, verify_sig: false)
```

#### Blacklist a token
Token will be stored in redis until it is expired. 
This is useful for preventing reuse of old tokens.
```ruby
Auth::TokenBlacklistWriter.call(access_token)
```

#### Check if a token is blacklisted
```ruby
Auth::TokenBlacklist.contains?(access_token)
```

#### Create various other tokens
```ruby
invite_id = "some string or number"
Auth::InviteTokenCreator.call(invite_id, other: "options")
Auth::EmailTokenCreator.call(user_id, "email@address.com")
Auth::PasswordResetTokenCreator.call(user_id)
Auth::PasswordlessLoginTokenCreator.call(user_id)
```
Invite tokens will have an `action` claim of "invite".
Email confirmation tokens will have an `action` claim of "email_confirmation".
Password reset tokens will have an `action` claim of "password_reset".
Passwordless login tokens will have an `action` claim of "passwordless_login".

#### Verify if an invite, email confirmation, password reset, or passwordless login token is valid

```ruby
Auth::EmailConfirmer.call(
  token,
  user_finder: ->(id, claims) { find_user },
  callback: ->(user) { do_something_with(user) }
)

Auth::TokenConfirmer.call(
  token,
  action: Auth::TOKEN_ACTION_INVITE, # or some other action constant
  record_finder: ->(id, claims) { find_record },
  callback: lambda { |record| do_something_with(record) }
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/auth/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Auth project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/auth/blob/main/CODE_OF_CONDUCT.md).
