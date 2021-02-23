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

> Truncate strings with fullwidth characters and ANSI codes.

## Features

* No monkey-patching String class
* Omit text from the start, middle, end or both ends
* Account for fullwidth characters in encodings such as UTF-8, EUC-JP
* Shorten text without whitespaces between words (Chinese, Japanese, Korean etc)
* Preserve ANSI escape codes

## Contents

* [1. Usage](#1-usage)
* [2. API](#2-api)
  * [2.1 configure](#21-configure)
  * [2.2 truncate](#22-truncate)
* [3. Extending String class](#3-extending-string-class)

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

As a convenience, you can call `truncate` method directly on a class:

```ruby
Strings::Truncation.truncate("I try all things, I achieve what I can.")
# => "I try all things, I achieve w…"
```

To change the default truncation length, pass an integer as a second argument:

```ruby
strings.truncate("I try all things, I achieve what I can.", 15)
# => "I try all thin…"
```

Or if you want to be more explicit and flexible use `:length` keyword:

```ruby
strings.truncate("I try all things, I achieve what I can.", length: 15)
# => "I try all thin…"
```

You can specify custom omission string in place of default `…`:

```ruby
strings.truncate("I try all things, I achieve what I can.", omission: "...")
# => "I try all things, I achieve..."
```

If you wish to truncate preserving words use a string or regexp as a separator:

```ruby
strings.truncate("I try all things, I achieve what I can.", separator: /\s/)
# => "I try all things, I achieve…"
```

You can omit text from the `start`, `middle`, `end` or both `ends`:

```ruby
strings.truncate("I try all things, I achieve what I can", position: :middle)
# => "I try all thing…ve what I can."
```

You can truncate text with fullwidth characters (Chinese, Japanese, Korean etc):

```ruby
strings.truncate("おはようございます", 8)
# => "おはよ…"
```

As well as truncate text that contains ANSI escape codes:

```ruby
strings.truncate("\e[34mI try all things, I achieve what I can\e[0m", 18)
# => "\e[34mI try all things,\e[0m…"
```

## 2. API

### 2.1 configure

To change default configuration settings at initialization use keyword arguments.

For example, to omit text from the start and separate on a whitespace character do:

```ruby
strings = Strings::Truncation.new(position: :start, separator: /\s/)
```

After initialization, you can use `configure` to change settings inside a block:

```ruby
strings.configure do |config|
  config.length 25
  config.omission "[...]"
  config.position :start
  config.separator /\s/
end
```

Alternatively, you can also use `configure` with keyword arguments:

```ruby
strings.configure(position: :start, separator: /\s/)
```

### 2.2 truncate

By default a string is truncated from the end to maximum length of `30` display columns.

```ruby
strings.truncate("I try all things, I achieve what I can.")
# => "I try all things, I achieve w…"
```

To change the default truncation length, pass an integer as a second argument:

```ruby
strings.truncate("I try all things, I achieve what I can.", 15)
# => "I try all thin…"
```

Or use `:length` keyword to be more explicit:

```ruby
strings.truncate("I try all things, I achieve what I can.", length: 15)
# => "I try all thin…"
```

The default `…` omission character can be replaced using `:omission`:

```ruby
strings.truncate("I try all things, I achieve what I can.", omission: "...")
# => "I try all things, I achieve..."
```

You can omit text from the `start`, `middle`, `end` or both `ends` by specifying `:position`:

```ruby
strings.truncate("I try all things, I achieve what I can", position: :start)
# => "…things, I achieve what I can."

strings.truncate("I try all things, I achieve what I can", position: :middle)
# => "I try all thing…ve what I can."

strings.truncate("I try all things, I achieve what I can", position: :ends)
# => "… all things, I achieve what …"
```

To truncate based on custom character(s) use `:separator` that accepts a string or regular expression:

```ruby
strings.truncate("I try all things, I achieve what I can.", separator: /\s/)
=> "I try all things, I achieve…"
```

You can combine all settings to achieve desired result:

```ruby
strings.truncate("I try all things, I achieve what I can.", length: 20,
                 omission: "...", position: :ends, separator: /\s/)
# => "...I achieve what..."
```

## 3. Extending String class

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
