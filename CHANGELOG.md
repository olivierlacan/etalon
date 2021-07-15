# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## 1.0.0 - July 15, 2021

### Change (backward incompatible)

- Require activesupport 5.2.x because earlier releases are no longer 
maintained for security fixes. This is likely a breaking change if you
depend on an outdated version of Rails or Active Support, but you should
seriously consider upgrading and keep an eye on the [Rails maintenance 
policy][rmp].
- Add compatibility with Ruby 3.0 

[rmp]: https://guides.rubyonrails.org/maintenance_policy.html

## 0.1.0 - February 05, 2019

### Added

- `Etalon.time` method which accepts a string title as its first argument
and a block argument which will store calls matching the same title and
compare their minimum, maximum, and average execution time but also the
standard deviation from that average, the 5 slowest timings, and the
iteration count.
- `Etalon.print_timings` method which returns a Hash of the above metrics
for all blocks of instrumented code and logs one line per unique `Etalon.time`
title in either the `Rails.logger` or a `Syslog::Logger` instance.
- `Etalon.active?` to check whether Etalon is... activated. Meaning whether it
is recording metrics or simply yielding to the block of code supplied to
`Etalon.time` without doing anything.
- `Etalon.activate` to make the `ETALON_ACTIVE` environment variable truthy,
which will cause `Etalon.active?` to return `true`.
- `Etalon.deactivate` to make the `ETALON_ACTIVE` environment variable falsey,
which will cause `Etalon.active?` to return `false`.


[Unreleased]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.1.0...HEAD
