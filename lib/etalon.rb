require "etalon/version"
require "active_support/inflector"

# Etalon is a simple tool to instrument Ruby code and output basic
# metrics to a logger or store them in a hash.
module Etalon
  class << self
    #
    # @return [Boolean] whether Etalon is active and recording metrics.
    def active?
      # rubocop:disable Style/DoubleNegation
      !!ENV["ETALON_ACTIVE"]
      # rubocop:enable Style/DoubleNegation
    end

    # Runs timing metrics on the supplied block of code and stores those metrics
    # for later logging or analysis using the supplied @identifier.
    #
    #
    # @param identifier [String] A unique identifier used to store calls to
    #  the supplied block and report them later.
    # @return the supplied block's return value
    def time(identifier)
      if active?
        unless block_given?
          raise "Please supply a block of code for Etalon to instrument"
        end

        start = Time.now

        return_value = yield

        duration = elapsed(start)

        key = key_from(identifier: identifier)
        store = instrument_store_for(key: key)

        store[:count] += 1
        store[:min] = duration if duration < store[:min]
        store[:max] = duration if duration > store[:max]
        store[:all] << duration

        return_value
      else
        yield
      end
    end

    #
    # Uses either Rails.logger or a Syslog::Logger instance to print out
    # iteration count, minimum, maximum, average and standard deviation
    # timings for each individual call instrumented by #time.
    #
    # @return [Hash] all stored metrics indexed by identifier
    def print_timings
      if active?
        instrument_store.each_with_object({}) do |(key, metrics), memo|
          count, min, max, all = metrics.values_at(:count, :min, :max, :all)
          top = all.sort.reverse.take(5)
          mean = mean(all).floor(2)
          deviation = standard_deviation(all).floor(2)

          title = key.to_s.titleize

          output = [
            "count: #{count}",
            "min: #{min}",
            "max: #{max}",
            "mean: #{mean}",
            "deviation: ±#{deviation}%",
            "top 5: #{top}",
          ]

          logger.debug("#{title} - #{output.join(" | ")}")

          memo[key] = output
        end
      end
    end

    #
    # Resets Etalon's internal storage to remove all stored timings.
    #
    # @return [type] [description]
    def reset_timings
      @instrument_store = nil
    end

    #
    # Activates Etalon.
    #
    # @return [Boolean] Etalon's current activation status
    def activate
      !!ENV["ETALON_ACTIVE"] = "true"
    end

    #
    # Deactivates Etalon.
    #
    # @return [Boolean] Etalon's current activation status
    def deactivate
      !!ENV["ETALON_ACTIVE"] = nil
    end

    private

    def instrument_store
      @instrument_store ||= {}
    end

    def instrument_store_for(key:)
      instrument_store[key] ||= {
        count: 0,
        min: Float::INFINITY,
        max: 0,
        all: [],
      }
    end

    def key_from(identifier:)
      parameterize(identifier, separator: "_").to_sym
    end

    def elapsed(start)
      ((Time.now - start) * 1000).floor
    end

    def mean(samples)
      (samples.sum / samples.length.to_f)
    end

    def square(number)
      number ** 2
    end

    def variance(samples)
      return 0 if samples.length < 2

      sum = samples.inject(0) do |store, value|
        store + square(value - mean(samples))
      end

      sum.fdiv((samples.length - 1).to_f)
    end

    def standard_deviation(samples)
      return 0 if samples.length < 2

      Math.sqrt(variance(samples))
    end

    def logger
      @logger ||= begin
        if defined?(Rails.logger)
          Rails.logger
        else
          require("syslog/logger")
          Syslog::Logger.new
        end
      end
    end

    def parameterize(*args, **kwargs, &block)
      ActiveSupport::Inflector.parameterize(*args, **kwargs, &block)
    end
  end
end
