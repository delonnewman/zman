# frozen_string_literal: true

module Zman
  class Schema
    ValidationError = Class.new(StandardError)

    def initialize
      @attributes = {}
    end

    def entity_classes
      @attributes.keys
    end

    def has?(entity_class, name)
      !!@attributes.dig(entity_class, name)
    end

    def define_attribute(entity_class, name, **options)
      @attributes[entity_class] ||= {}
      @attributes[entity_class][name] = Attribute.new(entity_class, name, **options)
    end

    def required_attributes(entity_class)
      attributes(entity_class).select(&:required?)
    end

    def attributes(entity_class = nil)
      return @attributes.values.flat_map(&:values).freeze unless entity_class

      @attributes.fetch(entity_class).values.dup.freeze
    end

    def validate(entity_class, entity_data)
      required_attributes(entity_class).each_with_object({}) do |attribute, errors|
        errors[attribute.name] = "#{attribute.name} is required" if entity_data[attribute.name].nil?
      end.freeze
    end

    def validate!(entity_class, entity_data)
      errors = validate(entity_class, entity_data)
      raise ValidationError, errors.values.join(', ') unless errors.empty?
    end

    def valid?(entity_class, entity_data)
      validate(entity_class, entity_data).empty?
    end

    def init(entity_class, entity_data)
      attributes(entity_class).each_with_object({}) do |attribute, init_data|
        value = entity_data.fetch(attribute.name) do
          attribute.default unless attribute.default.respond_to?(:call)
        end

        if attribute.composite? && value
          value = attribute.type.public_send(
            attribute.constructor,
            value
          )
        end

        init_data[attribute.name] = attribute.decode(value) unless value.nil?
      end
    end
  end
end
