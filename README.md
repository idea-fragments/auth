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

## Usage

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


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/auth/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Auth project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/auth/blob/main/CODE_OF_CONDUCT.md).
