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
      about: 3
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

    attr_reader :year, :month, :value

    def initialize(year, month, precision: :exact)
      raise Error, 'invalid date' if year.zero? || month.zero? || month > 12

      @year = year
      @month = month
      @value = year * month
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
