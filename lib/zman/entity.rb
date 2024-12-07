# frozen_string_literal: true

module Zman
  class Entity
    include Types
    extend Types

    @@schema = nil
    def self.schema
      @@schema ||= Schema.new
    end

    class << self
      def attributes
        schema.attributes(self)
      end

      def validate!(entity_data)
        schema.validate!(self, entity_data)
      end

      def validate(entity_data)
        schema.validate(self, entity_data)
      end

      def valid?(entity_data)
        schema.valid?(self, entity_data)
      end

      def decode(entity_data)
        new(init(entity_data))
      end

      def init(entity_data)
        schema.init(self, entity_data)
      end

      def has?(name)
        schema.has?(self, name)
      end

      private

      def inherited(subclass)
        super
        subclass.schema.define_attribute(subclass, :id, type: Integer, namespace: :db, optional: true)
      end

      def attribute(name, type, **options)
        schema.define_attribute(self, name, **options.merge(type:))
      end
      alias has attribute

      def references(referent, **options)
        attribute(:"#{referent}_id", Integer, **options)
      end

      def timestamp
        attribute(:created_at, Timestamp, default: -> { Time.now }, namespace: :db)
        attribute(:updated_at, Timestamp, default: -> { Time.now }, namespace: :db)
      end

      def composite(name, type, of:, **options)
        attribute_names = of
        attribute(name, type, **options.merge(composite: attribute_names.keys))
      end
    end

    attr_reader :attributes

    def initialize(attributes)
      @attributes = self.class.init(attributes)
      self.class.attributes.each do |attribute|
        if @attributes[attribute.name].nil? && attribute.default.respond_to?(:call)
          @attributes[attribute.name] = instance_exec(&attribute.default)
        end
      end
      self.class.validate!(@attributes)
    end

    def persisted?
      has?(:id)
    end

    def new?
      !persisted?
    end

    def [](key)
      @attributes[key]
    end

    def has?(attribute)
      @attributes.key?(attribute)
    end

    private

    def respond_to_missing?(method, include)
      has?(method) || self.class.has?(method) || super
    end

    def method_missing(method, *_args, **_kwargs)
      if has?(method) || self.class.has?(method)
        @attributes[method]
      else
        super
      end
    end
  end
end
