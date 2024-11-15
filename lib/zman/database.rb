# frozen_string_literal: true

module Zman
  class Database
    Fact = Data.define(:ref, :attribute, :value)

    def initialize
      @eav_index = {}
      @current_entity_id = 0
    end

    def new_entity_id
      @current_entity_id += 1
    end

    def dig(*keys)
      @eav_index.dig(*keys)
    end

    def add_entity(entity)
      facts = EntityFacts.new(entity, new_entity_id).collect
      facts.each { |fact| add_fact(fact) }
      attributes = facts.each_with_object({}) do |fact, hash|
        name = fact.attribute.split('#').last.to_sym
        hash[name] = fact.value
      end
      entity.class.new(attributes)
    end

    def add_fact(fact)
      @eav_index[fact.ref] ||= {}
      @eav_index[fact.ref][fact.attribute] ||= []
      @eav_index[fact.ref][fact.attribute] << fact.value
      self
    end

    def remove_fact(fact)
      values = @eav_index.dig(fact.ref, fact.attribute)
      return false unless values

      values.delete(fact.value)
      fact
    end
  end
end
