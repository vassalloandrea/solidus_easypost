# solidus_easypost



This is an extension to integrate EasyPost with Solidus.

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

This will create an initializer at `config/initializers/solidus_easypost.rb`. Read through the
available configuration options and make sure to adjust the extension for your requirements.

Finally, you will need to configure Solidus to use the EasyPost stock estimator:

```ruby
# config/initializers/spree.rb
Spree.config do |config|
  config.stock.estimator_class = 'SolidusEasypost::Estimator'
end
```

## Usage

Once you switch to the EasyPost rate calculator, the extension will start calculating shipping rates
for all shipments. The cheapest rate will be selected by default, but your users will be able to
change the selected rate in the `delivery` step of the checkout process, if they wish.

Admins will also be able to download the postage label associated to each EasyPost shipment after
a shipment has been bought.

### Buying labels upon shipping

By default, the extension also adds a callback to the `ship` event on the `Spree::Shipment` model,
automatically buying the selected rate from EasyPost.

If you want to disable this logic, you can set `purchase_labels` to `false`.

### Customizing shipping rate calculation

By default, the extension will pass the entire cost of shipping to the user (i.e., the shipping cost
presented to the user will be equal to the rate received from the EasyPost API).

If you want to override this logic (e.g., you want to offer your users free shipping, but still buy
the rates from EasyPost), you can provide your own `shipping_rate_calculator_class`.

### Customizing shipping method selection

By default, the extension will create shipping methods for each type of carrier/service for which it
receives a rate from the EasyPost API. These are not available to users by default, and must be
enabled before they are visible and selectable in the storefront during the checkout process.

If you want to override this logic, you can provide your own `shipping_method_selector_class`.

### Customizing parcel dimension calculator

By default, the extension will use the default weight dimension calculator to calculate the parcel dimension that is passed to EasyPost. The default calculator uses the variants weight to calculate the parcel weight without taking into consideration the other package properties like `width`, `height`, and `lenght`.

If you want to override this logic, you can provide your own `parcel_dimension_calculator_class`.

### Tracking cartons via EasyPost

You can optionally track packages via EasyPost's [Trackers API](https://www.easypost.com/docs/api#trackers).
In order to do this, you can call the `#easypost_tracker` method on any carton:

```ruby
carton = Spree::Carton.find(2)
carton.easypost_tracker # => #<Easypost::Tracker>
```

This will also save the ID of the tracker on the `easy_post_tracker_id` column, to more easily
retrieve the tracker in the future.

> NOTE: In orders for carton tracking to work, you need to make sure that the `tracking` column
> in `spree_cartons` contains a valid tracking number, and that the `carrier` column in
> `spree_shipping_methods` contains a carrier name [that EasyPost will recognize](https://www.easypost.com/docs/api#carrier-tracking-strings).
> The extension already generates compliant shipping methods by default, but you may need to change
> the data on your custom shipping methods if you want to track them.

You can also enable automatic tracking for all created cartons:

```ruby
SolidusEasypost.configure do |config|
  config.track_all_cartons = true
end
```

### Getting tracking updates via webhooks

Once a tracker has been created for a given carton, you can either use it manually or you can use
EasyPost's [webhooks](https://www.easypost.com/docs/api#webhooks) to have any shipping updates
forwarded to your application.

In order for webhooks to work, you need to install the [solidus_webhooks](https://github.com/solidusio-contrib/solidus_webhooks)
extension. When the extension is available, a webhook will be automatically configured at
`/webhooks/easypost_trackers`. Simply add it to your EasyPost dashboard with the following
configuration:

- *Environment:* `Production` or `Test`
- *Webhook URL:* `https://your-store.com/webhooks/easypost_trackers?token=[YOUR_TOKEN]` (replace`[YOUR_TOKEN]` with the API key of an admin user or, better yet, a[webhook user](https://github.com/solidusio-contrib/solidus_webhooks#restricting-permissions)

Now, when Solidus gets a tracking update from EasyPost, a `solidus_easypost.tracker.updated` event
will be fired. The event's payload will contain the `:carton` and `:payload` keys, with the
`Spree::Carton` object associated to the tracker and the EasyPost payload respectively.

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

### Updating the changelog

Before and after releases the changelog should be updated to reflect the up-to-date status of
the project:

```shell
bin/rake changelog
git add CHANGELOG.md
git commit -m "Update the changelog"
```

### Releasing new versions

Your new extension version can be released using `gem-release` like this:

```shell
bundle exec gem bump -v 1.6.0
bin/rake changelog
git commit -a --amend
git push
bundle exec gem release
```

## License

Copyright (c) 2015 Brendan Deere, released under the New BSD License.
