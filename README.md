# Rack::DisableCssAnimations

Rack middleware to disable CSS animations sitewide. Useful for making acceptance tests quicker and more deterministic.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-disable_css_animations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-disable_css_animations

## Usage

If using Rails, add the middleware to your test environment in `config/environments/test.rb`:

```ruby
  config.middleware.use Rack::DisableCSSAnimations
```

## Contributing

1. Fork it ( https://github.com/botandrose/rack-disable_css_animations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
