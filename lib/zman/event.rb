# frozen_string_literal: true

module Zman
  class Schema
    def initialze
      @attributes = {}
    end

    def define_attribute(name, **options)
      @attributes[name] = options
    end

    def required?(attribute_name)
      !@attributes.dig(attribute_name, :optional)
    end

    def validate(entity_data)
      errors = {}
      @attributes.select { |k| required?(k) }.each_pair do |name, value|
        errors[name] = "#{name} is required" if entity_data[value].nil?
      end
      errors
    end

    def validate!(entity_data)
      errors = validate(entity_data)
      raise errors.values.join(', ')
    end

    def valid?(entity_data)
      validate(entity_data).empty?
    end
  end

  class Entity
    def self.schema
      @schema ||= Schema.new
    end

    def self.attribute(name, type, **options)
      schema.define_attribute(name, **options.merge(type:))
    end

    attr_reader :attributes

    def initialize(data)
      self.class.schema.validate!(data)
      @attributes = data.dup.freeze
    end

    def [](key)
      @attributes[key]
    end

    def has?(attribute)
      @attributes.key?(key)
    end

    private

    def respond_to_missing?(method, include)
      @attributes.key?(method) || super
    end

    def method_missing(method, *_args, **_kwargs)
      @attributes[method] || super
    end
  end

  class Event < Entity
    attribute :id, :integer
    attribute :date, :integer
    attribute :precision, :integer
    attribute :title, :string
    attribute :created_at, :time
    attribute :updated_at, :time

    def date
      Date.from_months(attributes[:date], precision:)
    end
  end
end
