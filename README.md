<div align="center">
  <img width="225" src="https://github.com/piotrmurach/strings/blob/master/assets/strings_logo.png" alt="strings logo" />
</div>

# Strings::Truncation

[![Gem Version](https://badge.fury.io/rb/strings-truncation.svg)][gem]
[![Actions CI](https://github.com/piotrmurach/strings-truncation/workflows/CI/badge.svg?branch=master)][gh_actions_ci]
[![Build status](https://ci.appveyor.com/api/projects/status/s8y94c4tvi8mgrh2?svg=true)][appveyor]
[![Maintainability](https://api.codeclimate.com/v1/badges/f7ecb5bf87696e522ccb/maintainability)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/strings-truncation/badge.svg?branch=master)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/strings-truncation.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/strings-truncation
[gh_actions_ci]: https://github.com/piotrmurach/strings-truncation/actions?query=workflow%3ACI
[appveyor]: https://ci.appveyor.com/project/piotrmurach/strings-truncation
[codeclimate]: https://codeclimate.com/github/piotrmurach/strings-truncation/maintainability
[coverage]: https://coveralls.io/github/piotrmurach/strings-truncation?branch=master
[inchpages]: http://inch-ci.org/github/piotrmurach/strings-truncation

> Truncate strings with fullwidth characters and ANSI codes

## Features

* No monkey-patching String class
* Supports multibyte character encodings such as UTF-8, EUC-JP
* Handles languages without white-spaces between words (Chinese, Japanese, Korean etc)
* Supports ANSI escape codes

## Installation

Add this line to your application's Gemfile:

```ruby
gem "strings-truncation"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install strings-truncation

## 1. Usage

Use `truncate` to shorten string to 30 characters by default:

```ruby
strings = Strings::Truncation.new
strings.truncate("I try all things, I achieve what I can.")
# => "I try all things, I achieve w…"
```

As a convenience, you can call methods directly on a class:

```ruby
Strings::Truncation.truncate("I try all things, I achieve what I can.")
# => "I try all things, I achieve w…"
```

To change the default truncation length, pass an integer as a second argument:

```ruby
strings.truncate("I try all things, I achieve what I can.", 15)
# => "I try all thin…"
```

Or if you want to be more flexible use `:length` keyword:

```ruby
strings.truncate("I try all things, I achieve what I can.", length: 15)
# => "I try all thin…"
```

You can specify custom omission string:

```ruby
strings.truncate("I try all things, I achieve what I can.", 30, omission: "[...]")
# => "I try all things, I achie[...]"
```

If you wish to truncate preserving words use a string or regexp as a separator:

```ruby
strings.truncate("I try all things, I achieve what I can.", separator: " ")
# => "I try all things, I achieve…"
```

You can omit text from the `start`, `middle` or `end`:

```ruby
strings.truncate("I try all things, I achieve what I can", 20, position: :middle)
# => "I try all …at I can."
```

It supports truncation of fullwidth characters (Chinese, Japanese, Korean etc):

```ruby
strings.truncate("太丸ゴシック体", 8)
# => "太丸ゴ…"
```

It supports truncation of ANSI escape codes as well:

```ruby
strings.truncate("\e[34mI try all things, I achieve what I can\e[0m", 18)
# => "\e[34mI try all things,\e[0m…"
```

## 2. Extending String class

Though it is highly discouraged to pollute core Ruby classes, you can add the required methods to String class by using refinements.

To include all the **Strings::Truncation** methods, you can load extensions like so:

```ruby
require "strings/truncation/extensions"

using Strings::Truncation::Extensions
```

And then call `truncate` directly on any string:

```ruby
"I try all things, I achieve what I can.".truncate(20, separator: " ")
# => "I try all things, I…"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/strings-truncation. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Strings::Truncation project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/strings-truncation/blob/master/CODE_OF_CONDUCT.md).


## Copyright

Copyright (c) 2019 Piotr Murach. See LICENSE for further details.
