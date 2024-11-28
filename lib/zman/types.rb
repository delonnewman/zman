# frozen_string_literal: true

module Zman
  module Types
    Any = lambda { |_| true }
    Nil = lambda { |it| NilClass === it }

    Boolean = lambda do |it|
      FalseClass === it || TrueClass === it
    end

    Optional = lambda do |type|
      lambda do |it|
        type === it || it.nil?
      end
    end

    module Timestamp
      module_function

      def ===(value)
        Time === value
      end

      def parse(value)
        case value
        when String
          Time.new(value)
        when Time, Integer
          Time.at(value)
        else
          raise "#{value.inspect}:#{value.class} cannot be coerced to a #{self.class}"
        end
      end
    end
  end
end
