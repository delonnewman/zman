module Zman
  class EntityFacts
    attr_reader :entity, :entity_id

    def initialize(entity, entity_id = entity.id)
      raise 'an entity id is required' unless entity_id

      @entity = entity
      @entity_id = entity_id
    end

    EMPTY_ARRAY = [].freeze
    private_constant :EMPTY_ARRAY

    def collect
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
      end
    end
  end
end
