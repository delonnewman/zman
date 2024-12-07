# frozen_string_literal: true

module Zman
  module Types
    Any = lambda { |_| true }
    Nil = lambda { |it| NilClass === it }

    Not = lambda do |type|
      lambda do |it|
        !(type === it)
      end
    end

    Or = lambda do |*types|
      lambda do |it|
        types.any? { |t| t === it }
      end
    end

    Boolean = Or[FalseClass, TrueClass]

    Optional = lambda do |type|
      Or[type, Nil]
    end

    HasKeys = lambda do |*keys|
      lambda do |hash|
        keys.all? { |key| hash.key?(key) }
      end
    end

    And = lambda do |*types|
      lambda do |it|
        types.all? { |t| t === it }
      end
    end

    EntityWithKeys = lambda do |*keys|
      And[Entity, HasKeys[*keys]]
    end

    EnumerableOf = lambda do |type|
      lambda do |it|
        Enumerable === it && it.all? { |it| type === it }
      end
    end

    ArrayOf = lambda do |type|
      lambda do |it|
        Array === it && it.all? { |it| type === it }
      end
    end

    HashOf = lambda do |key_type, value_type|
      lambda do |it|
        Hash === it &&
          it.keys.all? { |it| key_type === it } &&
          it.values.all? { |it| value_type === it }
      end
    end

    RespondsTo = lambda do |*methods|
      lambda do |it|
        methods.all? { |method| it.respond_to?(method) }
      end
    end
    RespondTo = RespondsTo

    Primitive = Or[Integer, Float, String]
    JSON = Or[Primitive, ArrayOf[Primitive], HashOf[Primitive, Primitive], RespondsTo[:to_json]]

    CanCoerce = lambda do |coersion|
      lambda do |it|
        begin
          coersion.call(it)
          true
        rescue
          false
        end
      end
    end

    ToSymbol = lambda do |it|
      it.to_sym
    end

    ToJSON = lambda do |it|
      it.to_json
    end

    ToDecodable = lambda do |type|
      lambda do |it|
        type.decode(it)
      end
    end

    ToPrimative = lambda do |type|
      lambda do |it|
        type.encode(it)
      end
    end

    module Timestamp
      module_function

      def ===(value)
        Time === value
      end

      def decode(value)
        case value
        when String
          Time.new(value)
        when Time, Integer
          Time.at(value)
        else
          raise "#{value.inspect}:#{value.class} cannot be coerced to a #{self.class}"
        end
      end

      def encode(value)
        value.to_s
      end
    end
  end
end
