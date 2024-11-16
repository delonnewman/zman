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

    PRECISION_NAMES = %i[exact after before circa].freeze
    PRECISION_VALUES = {
      exact: 0,
      after: 1,
      before: 2,
      circa: 3,
    }.freeze

    def self.precision(value)
      PRECISION_VALUES.fetch(value) do
        raise "unknown date precision #{value.inspect}" unless PRECISION_NAMES[value]

        value
      end
    end

    def self.today
      new(Date.today)
    end

    def self.composite(date_value:, date_precision_value:)
      fractional = date_value.to_f / 12
      year = fractional.floor
      month = ((fractional - year) * 12).floor
      new(year, month, precision: date_precision_value)
    end

    attr_reader :year, :month, :value

    def initialize(year, month, era: nil, precision: :exact)
      raise Error, 'invalid date' if year.zero? || month.zero? || month > 12

      @month = month
      @year = era == :bce && year.positive? || era == :ce && year.negative? ? year * -1 : year

      @value = (@year * 12) + @month
      @precision = self.class.precision(precision)

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

    def precision
      PRECISION_NAMES[@precision]
    end

    def precision_value
      @precision
    end

    def precision?(name)
      @precision == PRECISION_VALUES[name]
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
