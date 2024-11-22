require 'forwardable'

module Zman
  class EntityChanges
    extend Forwardable

    attr_reader :entity, :entity_id

    delegate %i[each] => :facts

    def initialize(entity, entity_id = entity.id)
      raise 'an entity id is required' unless entity_id

      @entity = entity
      @entity_id = entity_id
      @facts = nil
    end

    def facts
      @facts ||= collect_facts
    end

    def new_entity
      attributes = facts.each_with_object({}) do |fact, hash|
        name = fact.attribute.split('#').last.to_sym
        hash[name] = fact.value
      end
      entity.class.new(attributes)
    end

    private

    EMPTY_ARRAY = [].freeze
    private_constant :EMPTY_ARRAY

    def collect_facts
      entity.class.attributes.flat_map do |attribute|
        if attribute.cardinality_many?
          entity[attribute.name].map do |value|
            Database::Fact.new(eid, attribute.composite_name, value)
          end
        elsif attribute.composite?
          EMPTY_ARRAY
        elsif attribute.db_id?
          Database::Fact.new(entity_id, attribute.composite_name, entity_id)
        elsif attribute.db_update_timestamp? && entity.persisted?
          Database::Fact.new(entity_id, attribute.composite_name, Time.now)
        else
          Database::Fact.new(entity_id, attribute.composite_name, entity[attribute.name])
        end
      end.freeze
    end
  end
end
