# frozen_string_literal: true

module Zman
  # Dates in a historical context
  class Date
    Error = Class.new(StandardError)

    MONTHS = [
      nil,
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ].freeze

    def self.today
      new(Date.today)
    end

    def self.decode(value)
      case value
      in self
        value
      in value: nil, precision: nil
        nil
      in value:, precision:
        from_parts(value:, precision:)
      else
        raise "invalid value: #{value.inspect}:#{value.class}"
      end
    end

    def self.from_parts(value:, precision:)
      fractional = value.to_f / 12
      year = fractional.floor
      month = ((fractional - year) * 12).floor

      new(year, month, precision:)
    end

    attr_reader :year, :month, :value, :precision

    def initialize(year, month, era: nil, precision: :exact)
      raise Error, 'invalid date' if year.zero? || month.zero? || month > 12

      @month = month
      @year = era == :bce && year.positive? || era == :ce && year.negative? ? year * -1 : year

      @value = (@year * 12) + @month
      @precision = Precision.new(precision)

      freeze
    end

    def to_s
      buffer = []

      buffer << precision unless exact?
      buffer << MONTHS[month] if exact?
      buffer << year.abs
      buffer << 'CE' if ce?
      buffer << 'BCE' if bce?

      buffer.join(' ')
    end
    alias inspect to_s

    def ==(other)
      return false unless other.is_a?(self.class)

      value == other.value
    end
    alias eql? ==

    def hash
      value.hash
    end

    def ce?
      @value.positive?
    end
    alias ad? ce?

    def bce?
      @value.negative?
    end
    alias bc? bce?

    def precision?(name)
      @precision.name == name
    end

    def exact?
      precision?(:exact)
    end

    def after?
      precision?(:after)
    end

    def before?
      precision?(:before)
    end

    def circa?
      precision?(:circa)
    end
    alias about? circa?
  end
end
