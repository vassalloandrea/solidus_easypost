# Solidus + EasyPost

[![CircleCI](https://circleci.com/gh/solidusio-contrib/solidus_easypost.svg?style=svg)](https://circleci.com/gh/solidusio-contrib/solidus_easypost)

This is an extension to integrate EasyPost into Spree.

Due to how it works, you will not be able to use any other extension for shipping methods. Your own
shipping methods will not work, either. But the good thing is that you won't have to worry about
that, because EasyPost handles it all for you.

You will need to [sign up for an account](https://www.easypost.com/) to use this extension.

## Installation

Add solidus_easypost to your Gemfile:

```ruby
gem 'solidus_easypost'
```

Bundle your dependencies and run the installation generator:

```shell
bin/rails generate solidus_easypost:install
```

Create an initializer at `config/initializers/solidus_easypost.rb`:

```ruby
EasyPost.api_key = 'YOUR_API_KEY_HERE'
```

## Usage

This extension hijacks `Spree::Stock::Estimator#shipping_rates` to calculate shipping rates for your
orders. This call happens during the checkout process, once the order's address information has been
provided.

The extension also adds a callback to the `ship` event on the `Spree::Shipment` model, telling
EasyPost which rate was selected and "buying" that rate. This can be disabled by setting:

```ruby
# config/initializers/solidus_easypost.rb
SolidusEasypost.configure do |config|
  config.purchase_labels = false
end
```

This gem will create shipping methods for each type of carrier/service for which it receives a rate
from the EasyPost API. These are set to  `display_on: back_end` by default and must be set to
`front_end` or `both` before the rate will be visible on the delivery page of the checkout.

## Development

### Testing the extension

First bundle your dependencies, then run `bin/rake`. `bin/rake` will default to building the dummy
app if it does not exist, then it will run specs. The dummy app can be regenerated by using
`bin/rake extension:test_app`.

```shell
bin/rake
```

To run [Rubocop](https://github.com/bbatsov/rubocop) static code analysis run

```shell
bundle exec rubocop
```

When testing your application's integration with this extension you may use its factories.
Simply add this require statement to your spec_helper:

```ruby
require 'solidus_easypost/factories'
```

### Running the sandbox

To run this extension in a sandboxed Solidus application, you can run `bin/sandbox`. The path for
the sandbox app is `./sandbox` and `bin/rails` will forward any Rails commands to
`sandbox/bin/rails`.

Here's an example:

```
$ bin/rails server
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
* Listening on tcp://127.0.0.1:3000
Use Ctrl-C to stop
```

### Releasing new versions

Your new extension version can be released using `gem-release` like this:

```shell
bundle exec gem bump -v VERSION --tag --push --remote upstream && gem release
```

## License

Copyright (c) 2020 Brendan Deere, released under the New BSD License.
