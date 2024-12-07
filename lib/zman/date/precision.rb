# lib/precision.rb

module Zman
  class Date::Precision
    NAMES = {
      exact: 0,
      after: 1,
      before: 2,
      circa: 3,
    }.freeze

    VALUES = NAMES.keys.freeze

    attr_reader :value
    alias to_i value

    def self.parse(value)
      new(value)
    end

    def self.type
      Integer
    end

    def initialize(value)
      @value = NAMES.fetch(value) do
        raise "unknown date precision #{value.inspect}" unless VALUES[value]

        value
      end
      freeze
    end

    def name
      VALUES[value]
    end

    def inspect
      name.inspect
    end

    def to_s
      name.to_s
    end
  end
end
