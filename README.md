# Rspec::Authorization

[![Gem Version](https://badge.fury.io/rb/rspec-authorization.svg)](http://badge.fury.io/rb/rspec-authorization)

RSpec matcher for declarative_authorization. A neat way of asserting declarative_authorization's rules inside controller using RSpec matcher.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-authorization'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-authorization

## Usage

In your controller spec:

    describe PostsController do
      it { is_expected.to have_permission_for(:role_name).to(:restful_action_name) }
    end

## Contributing

1. Fork it ( https://github.com/hendrauzia/rspec-authorization/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Setup rails test app (`bundle exec rake setup`)
3. Test your changes (`bundle exec rake spec`)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request
