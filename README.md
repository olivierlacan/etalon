# Etalon [![Build Status][ci-badge]][ci-url] [![Gem Version][gem-badge]][gem-url]

A simple tool to instrument Ruby code and output basic metrics to a
logger or store them in a hash.

From the French noun `étalon` meaning:
> standard: something used as a measure for comparative evaluations

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'etalon'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install etalon

In that last case, you'll need to manually `require "etalon"`.

## Usage

Assuming the following instrumented code:

```ruby
  class Cooking
    def self.potato
      Etalon.time("Making taters") do
        peel_potato
        cook_potato
      end
    end
  end
```

You can do the following:

```
$ irb
require "cooking"
=> true

Etalon.activate
=> true

Etalon.print_timings
=> {:making_taters=>["count: 1", "min: 0", "max: 400", "mean: 400.0", "deviation: 0.0", "top 5: [400]"]}
```

If `Rails.logger` is available, Etalon will also output the following with
a call to `Rails.logger.debug` in the relevant log file:

```
Making Taters - count: 1 | min: 0 | max: 400 | mean: 400.0 | deviation: ±0.0% | top 5: [400]
```

If `Rails.logger` isn't available, Etalon attempts to require
[`syslog/logger`][syslog-logger] from the Ruby standard library as a fallback
logging mechanism.

[syslog-logger]: https://www.rubydoc.info/stdlib/syslog/2.3.1/Syslog/Logger

## Contributing

[Bug reports][bugs] and [pull requests][pulls] are welcome.

See [contribution guidelines][contributions].

[bugs]: https://github.com/olivierlacan/etalon/issues
[pulls]: https://github.com/olivierlacan/etalon/pulls
[contributions]: https://github.com/olivierlacan/etalon/blob/master/CONTRIBUTING.md
[ci-badge]: https://travis-ci.org/olivierlacan/etalon.svg?branch=master
[ci-url]: https://travis-ci.org/olivierlacan/etalon
[gem-badge]: https://img.shields.io/gem/v/etalon.svg?style=flat
[gem-url]: https://rubygems.org/gems/etalon
