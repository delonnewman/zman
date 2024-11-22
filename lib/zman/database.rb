# frozen_string_literal: true

module Zman
  class Database
    require_relative 'database/index'
    require_relative 'database/eav_index'

    Fact = Data.define(:ref, :attribute, :value)

    def initialize(eav_index:)
      @eav_index = eav_index
      @current_entity_id = 0
    end

    def new_entity_id
      @current_entity_id += 1
    end

    def dig(*keys)
      @eav_index.dig(*keys)
    end

    def add_entity(entity)
      changes = EntityChanges.new(entity, new_entity_id)
      changes.each { |fact| add_fact(fact) }
      changes.new_entity
    end

    def add_fact(fact)
      @eav_index.add(fact)
      self
    end

    def remove_fact(fact)
      @eav_index.remove(fact)
    end
  end
end
