# frozen_string_literal: true

module Zman
  class Entity
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

      def parse(entity_data)
        schema.parse(self, entity_data)
      end

      def has?(name)
        schema.has?(self, name)
      end

      private

      def inherited(subclass)
        super
        subclass.schema.define_attribute(subclass, :id, type: :integer, namespace: :db, optional: true)
      end

      def attribute(name, type, **options)
        schema.define_attribute(self, name, **options.merge(type:))
      end
      alias has attribute

      def references(referent, **options)
        attribute(:"#{referent}_id", :integer, **options)
      end

      def timestamp
        attribute(:created_at, :time, default: -> { Time.now }, namespace: :db)
        attribute(:updated_at, :time, default: -> { Time.now }, namespace: :db)
      end

      def composite(name, of:, **options)
        attribute_names = of
        attribute_names.each do |attribute_name, type|
          attribute(:"#{name}_#{attribute_name}", type, composite_source_method: attribute_name, composite_attribute: name)
        end
        attribute(name, name, **options.merge(composite: attribute_names.keys))
      end
    end

    attr_reader :attributes

    def initialize(attributes)
      @attributes = self.class.parse(attributes)
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
