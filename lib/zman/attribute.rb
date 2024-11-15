# frozen_string_literal: true

module Zman
  class Attribute
    attr_reader :entity_class, :name

    def initialize(entity_class, name, **options)
      @entity_class = entity_class
      @name = name
      @options = options
      freeze
    end

    def namespace
      option(:namespace) || entity_class.name
    end

    def composite_name
      "#{namespace}##{name}"
    end

    def cardinality_many?
      cardinality == :many
    end

    def class_name
      return unless composite?

      option(:class_name) || name.to_s.camelcase
    end

    def composite_class
      return unless composite?

      class_name.constantize
    end

    def constructor
      option(:constructor)
    end

    def composite_source_attributes
      option(:composite)
    end

    def composite?
      !!option(:composite)
    end

    def composite_source?
      !!composite_source_method
    end

    def composite_attribute
      option(:composite_attribute)
    end

    def composite_source_method
      option(:composite_source_method)
    end

    def cardinality
      option(:cardinality)
    end

    def optional?
      !!option(:optional)
    end

    def required?
      !optional?
    end

    def default
      value = option(:default)
      return value unless value.respond_to?(:call)

      value.call
    end

    def option(name)
      @options[name]
    end
  end
end
