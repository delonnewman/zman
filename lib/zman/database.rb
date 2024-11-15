# frozen_string_literal: true

module Zman
  class Database
    DB_ID_ATTR = 'db#id'
    DB_UPDATED_AT = 'timestamp#updated_at'

    Fact = Data.define(:ref, :attribute, :value)

    def initialize
      @eav_index = {}
      @ave_index = {}
    end

    def add(fact)
      @eav_index[fact.ref] ||= {}
      @eav_index[fact.ref][fact.attribute] ||= []
      @eav_index[fact.ref][fact.attribute] << fact.value
      @ave_index[fact.attribute] ||= {}
      @ave_index[fact.attribute][fact.value] ||= []
      @ave_index[fact.attribute][fact.value] << fact.ref
      self
    end

    def remove(fact)
      values = @eav_index.dig(fact.ref, fact.attribute)
      return false unless values

      values.delete(fact.value)
      fact
    end

    def entity_data(ref)
      @eav_index[ref]
    end

    def pull(query)
    end
  end

  class Transactor
    def initialize
      @current_entity_id = 0
    end

    def new_entity_id
      @current_entity_id += 1
    end

    def add(entity)
      db = Database.new
      facts(entity).each do |fact|
        db.add(fact)
      end
      db
    end

    def facts(entity)
      eid = entity.id || new_entity_id
      entity.class.attributes.flat_map do |attribute|
        if attribute.cardinality_many?
          entity[attribute.name].map do |value|
            Database::Fact.new(eid, attribute.composite_name, value)
          end
        elsif attribute.composite?
          []
        elsif attribute.composite_name == Database::DB_ID_ATTR
          Database::Fact.new(eid, attribute.composite_name, eid)
        elsif attribute.composite_name == Database::DB_UPDATED_AT && entity.id
          Database::Fact.new(eid, attribute.composite_name, Time.now)
        else
          Database::Fact.new(eid, attribute.composite_name, entity[attribute.name])
        end
      end
    end
  end
end
