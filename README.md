# Auth
![example workflow](https://github.com/idea-fragments/auth/actions/workflows/main.yml/badge.svg)


A Ruby gem for JWT-based authentication with support for access/refresh token pairs, token blacklisting via Redis, and configurable token creation for password resets, passwordless logins, and more.

## Table of Contents

- [Installation](#installation)
- [Setup and Configuration](#setup-and-configuration)
- [Usage](#usage)
    - [Create access and refresh tokens](#create-access-and-refresh-tokens)
    - [Blacklist a token](#blacklist-a-token)
    - [Check if a token is blacklisted](#check-if-a-token-is-blacklisted)
    - [Create various other tokens](#create-various-other-tokens)
    - [Confirm an email token](#confirm-an-email-token)
    - [Refresh tokens](#refresh-tokens)
    - [Verify a token](#verify-a-token)
    - [Custom token actions](#custom-token-actions)
- [Integration Example](#integration-example)
    - [Login](#login)
    - [Logout](#logout)
    - [Token Refresh](#token-refresh)
    - [Authenticating Requests](#authenticating-requests)
- [Future improvements](#future-improvements)
- [Development](#development)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "auth", "~> 1.0.0", git: "https://github.com/idea-fragments/auth"
```

And then execute:
```bash
bundle install
```

## Setup and Configuration

The gem will need to be required in your code. Since the gem is loaded from a git repo, you'll need to require bundler/setup before requiring the gem.

```ruby
require "bundler/setup"
require "auth"
```

Create a file in `config/initializers` called `auth.rb` and add the following. Be sure to set the variables to the values you need for your project.

```ruby
Auth.access_token_ttl_minutes = 5
Auth.email_confirmation_ttl_days = 2
Auth.invite_ttl_days = 7
Auth.jwt_signing_algorithm = "<your hashing algorithm>"
Auth.jwt_secret = "<your secret key>"
Auth.password_reset_ttl_days = 2
Auth.passwordless_login_ttl_minutes = 30
Auth.redis = Redis.new # from the redis gem: https://github.com/redis/redis-rb
Auth.refresh_token_ttl_days = 5
```

In a Rails app, all configuration fields are validated automatically on boot via a Railtie. If any are missing, the app will raise `Auth::ConfigurationError` with a list of the missing fields. You can also call `Auth.validate_configuration!` manually in non-Rails environments.

## Usage
#### Create access and refresh tokens

```ruby
user_info = { id: 323, name: "John Doe", email: "example@example.com" }
tokens = Auth::Authorizer.call(user_info:)
access_token = tokens[:access_token]
refresh_token = tokens[:refresh_token]

# Decoded access token
# {
#   dat: { id: 323, name: "John Doe", email: "example@example.com", action: "authentication" },
#   exp: 452546536562
# }
#
# Decoded refresh token
# {
#   dat: { id: 323, name: "John Doe", email: "example@example.com", action: "authentication_refresh" },
#   exp: 6587954543654
# }
```

#### Blacklist a token
Token will be stored in redis until it is expired.
This is useful for preventing reuse of old tokens.

```ruby
Auth::TokenBlacklistWriter.call(token: access_token)
```

#### Check if a token is blacklisted

```ruby
Auth::TokenBlacklist.contains?(token: access_token)
```

#### Create various other tokens

```ruby
Auth::EmailTokenCreator.call(email:, user_id:)
Auth::InviteTokenCreator.call(invite_id:, team_id:, email:)
Auth::PasswordResetTokenCreator.call(user_id:)
Auth::PasswordlessLoginTokenCreator.call(user_id:)
```
Email confirmation tokens will have an `action` claim of `"email_confirmation"`.
Invite tokens will have an `action` claim of `"invite"`. `InviteTokenCreator` accepts arbitrary additional keyword arguments that are included in the token claims.
Password reset tokens will have an `action` claim of `"password_reset"`.
Passwordless login tokens will have an `action` claim of `"passwordless_login"`.

#### Confirm an email token

`EmailConfirmer` verifies an email confirmation token and checks that the user's email has not already been confirmed.

```ruby
Auth::EmailConfirmer.call(
  token:,
  user_finder: ->(claims:) { User.find(claims[:user_id]) },
)
```

The `user_finder` callable receives the decoded token `claims:` and must return a hash (or hash-like object) with an `:email_confirmed` key. If `email_confirmed` is truthy, `Auth::UserEmailAlreadyConfirmedError` is raised.

#### Refresh tokens
When an access token expires, use the refresh token to obtain a new token pair. The old access and refresh tokens are blacklisted to prevent reuse.

```ruby
new_tokens = Auth::Refresher.call(
  access_token: expired_access_token,
  refresh_token:,
  user_info: { id: 323, name: "John Doe", email: "example@example.com" },
)

new_access_token = new_tokens[:access_token]
new_refresh_token = new_tokens[:refresh_token]
```

The Refresher will:
1. Verify the access token was issued by our system (signature check) and is not blacklisted, then blacklist it. Expiration is skipped since the access token is expected to be expired.
2. Verify the refresh token is valid, not expired, and not blacklisted, then blacklist it.
3. Issue a new access/refresh token pair via `Authorizer`.

#### Verify a token

```ruby
claims = Auth::TokenConfirmer.call(
  action: Auth::TOKEN_ACTION_PASSWORD_RESET,
  token:,
)
```

The `TokenConfirmer` verifies the token is not blacklisted, decodes it, validates the action matches, blacklists it, and returns the claims.

Options:
- `skip_blacklist: true` — skip blacklisting the token after confirmation
- `skip_expiration_check: true` — allow expired tokens to be decoded (adds a 365-day leeway)
- `expiration_leeway: 60` — allow a specific leeway window (in seconds) for clock skew tolerance

Possible errors:
- `JWT::ExpiredSignature` — token has expired (and no leeway/skip was provided)
- `Auth::TokenAlreadyUsedError` — token was already blacklisted
- `Auth::InvalidTokenActionError` — token action does not match the expected action

#### Custom token actions

Use `SecurityTokenCreator` and `TokenConfirmer` directly to create and validate tokens for actions not included in the gem.

```ruby
# Create a custom token
token = Auth::SecurityTokenCreator.call(
  action: "email_confirmation",
  claims: { user_id: 123, email: "user@example.com" },
  expires_at: 3.days.from_now,
)

# Validate the custom token
claims = Auth::TokenConfirmer.call(
  action: "email_confirmation",
  token:,
)

claims[:user_id] # => 123
claims[:email]   # => "user@example.com"
```

The `action` string can be anything — it acts as a namespace to prevent tokens created for one purpose from being used for another. `TokenConfirmer` will raise `Auth::InvalidTokenActionError` if the action in the token doesn't match the expected action.

## Integration Example

Below is an example of how to integrate this gem into a Rails API application using a `SessionsController` and an `ApplicationController` concern for token validation.

#### Login

When a user logs in, authenticate their credentials and issue a token pair.

```ruby
class SessionsController < ApplicationController
  def create
    user = find_user_and_verify_password

    tokens = Auth::Authorizer.call(
      user_info: { id: user.id, email: user.email, name: user.name },
    )

    render json: tokens, status: :ok
  end
end
```

#### Logout

When a user logs out, blacklist the access and refresh tokens to prevent reuse.

```ruby
class SessionsController < ApplicationController
  def destroy
    Auth::TokenBlacklistWriter.call(token: access_token)
    Auth::TokenBlacklistWriter.call(token: refresh_token)

    head :no_content
  end
end
```

#### Token Refresh

When the access token expires, provide both tokens to obtain a new pair.

```ruby
class SessionsController < ApplicationController
  def refresh
    new_tokens = Auth::Refresher.call(
      access_token:,
      refresh_token:,
      user_info:,
    )

    render json: new_tokens, status: :ok
  rescue JWT::ExpiredSignature
    render json: { error: "Refresh token has expired" }, status: :unauthorized
  rescue Auth::TokenAlreadyUsedError => e
    # Use `e.message` to get the action associated with the token that was already used (e.g. "authentication" or "password_reset")
    render json: { error: "Access or Refresh token has already been blacklisted" }, status: :unauthorized
  rescue Auth::InvalidTokenActionError
    render json: { error: "Invalid token" }, status: :unauthorized
  end
end
```

#### Authenticating Requests

Use a `before_action` to validate the access token on every request. The `TokenConfirmer` decodes the token and returns the claims, which can be used to identify the current user.

Note that `skip_blacklist: true` is required here because `TokenConfirmer` blacklists tokens by default after confirmation. Without this, the access token would be blacklisted on the first request and rejected on every subsequent request.

```ruby
module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    claims = Auth::TokenConfirmer.call(
      action: Auth::TOKEN_ACTION_AUTHENTICATION,
      skip_blacklist: true,
      token: access_token,
    )

    @current_user = User.find(claims[:user_id])
  rescue JWT::ExpiredSignature
  rescue JWT::DecodeError, Auth::InvalidTokenActionError, Auth::TokenAlreadyUsedError
  end
end
```

## Future improvements

- **`jti` (JWT ID) claim**: Add a unique identifier to each token. This would allow blacklisting by ID instead of storing the full token string in Redis, reducing memory usage and simplifying token revocation.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/idea-fragments/auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/idea-fragments/auth/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Auth project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/idea-fragments/auth/blob/main/CODE_OF_CONDUCT.md).
