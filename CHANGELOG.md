## [Unreleased]

## [1.0.1] - 2026-03-16

### Fixed
- Railtie now runs `validate_configuration!` in `after_initialize` instead of an initializer, ensuring it executes after `config/initializers/auth.rb`

## [1.0.0] - 2026-03-16

### Added
- `Auth::SecurityTokenCreator` for creating tokens with custom actions and claims
- `Auth::Refresher` for refreshing expired access tokens using a valid refresh token
- `Auth::Railtie` for automatic configuration validation on Rails boot
- `Auth.validate_configuration!` for manual configuration validation in non-Rails environments
- `Auth::EmailConfirmer` now accepts a `user_finder` callable that receives decoded `claims:`
- `email_confirmation_ttl_days` and `invite_ttl_days` configuration options

### Changed
- **Breaking:** All service classes now use keyword arguments instead of positional arguments
- **Breaking:** Upgraded `idea-fragments-jwt` dependency to `~> 1.0`
- **Breaking:** Token `dat` payload now includes the `action` field (e.g. `dat: { user_id: 1, action: "password_reset" }`)
- `Auth::TokenConfirmer` now supports `skip_blacklist`, `skip_expiration_check`, and `expiration_leeway` options
- `Auth::Authorizer` now accepts `user_info:` keyword argument

### Removed
- `Auth::ClaimsReader` (replaced by `Auth::TokenConfirmer` with `skip_blacklist: true`)
- `TimeHelper` (replaced by ActiveSupport duration methods)

## [0.2.0]

### Changed
- Service base class to avoid name collisions
- Token blacklist writer calculates JWT TTL internally
- Refresh token now contains user info

## [0.1.0] - 2022-05-12

- Initial release
