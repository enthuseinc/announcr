# Announcr

A small Ruby DSL for describing system events.

## Installation

Add this line to your application's Gemfile:

    gem 'announcr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install announcr

## Usage

### Overview

### Namespaces

Namespaces are nestable configuration containers. `Announcr` is the default root
namespace, which can have an arbitrary number of children. Namespaces have the
following configuration options:

* **name**: A name used for the namespace. Acts as the default prefix unless
  another prefix is set.

* **prefix**: The prefix for this namespace. When the `#key_for` method is
  called on a namespace, all parent prefixes are collected recursively and
  appended to the key.

* **separator**: The key separator to use. When the `#key_for` method is called,
  all key parts will be joined with this value.

* **default_backend**: If a default backend is set, all `EventScope` objects
  will inherit all of the backends proxy methods as top level DSL methods.

TODO: Finish this section

### Events

Name matching:

```ruby
Announcr.namespace :foo do
  event :foobar do
    ...
  end
end
Announcr.announce(:foobar) # matches
Announcr.announce(:foo) # does not match
```

Pattern matching:

```ruby
Announcr.namespace :foo do
  event :all_user_actions, pattern: /^user_.*/ do
    ...
  end
end
Announcr.announce(:user_registration) # matches
Announcr.announce(:all_user_actions) # does not match
```

Requires matching:

```ruby
Announcr.namespace :foo do
  event :registration, requires: [:user, :created_at] do
    ...
  end
end
Announcr.announce(:registration, user: "mkbernard", created_at: Time.zone.now) # matches
Announcr.announce(:registration) # does not match
```

Filtering:

```ruby
type_filter = lambda do |name, opts|
  opts[:foo].is_a?(Foo) || opts[:bar].is_a?(Bar)
end

Announcr.namespace :foo do
  event :registration, filter: type_filter do
    ...
  end
end

Announcr.announce(:registration, foo: Foo.new) # matches
Announcr.announce(:registration) # does not match
```

TODO: Finish this section...

### Backends

Logger:

```ruby
Announcr.namespace :foo do
  backend :log, Announcr::Backend::Logger

  event :event_logger, pattern: /.*/ do
    log.info "Tracking #{event_name}: #{data.to_json}"
  end
end
```

Statsd:

```ruby
Announcr.namespace :foo do
  backend :stats, Announcr::Backend::Statsd

  event :event_incrementer, pattern: /.*/ do
    stats.increment event_name_key
  end
end
```

TODO: Finish this section...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
