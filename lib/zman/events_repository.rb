# frozen_string_literal: true

module Zman
  class EventsRepository
    TABLE = :events

    def self.attribute_names
      @attribute_names ||= Event.attributes.flat_map do |attribute|
        if attribute.composite?
          attribute.composite_keys.map do |key|
            :"#{attribute.name}[#{key}]"
          end
        else
          [attribute.name]
        end
      end
    end

    def initialize(db, logger = Logger.new($stderr))
      @db = db
      @logger = logger
    end

    def all
      @logger.info("#{self.class}#all - SQL - #{ALL_QUERY}")

      entities = []
      @db.query(ALL_QUERY).each_hash do |row|
        @logger.info("LOAD - #{row.inspect}")
        entities << parse_row(row)
      end
      entities
    end

    def find(id)
      @logger.info("#{self.class}#find - SQL - #{FIND_QUERY} #{id.inspect}")

      row = @db.query(FIND_QUERY, id).next_hash
      parse_row(row)
    end

    def add(event)
      data = insert_data(event)
      @logger.info("#{self.class}#add - SQL - #{ADD_QUERY} - (#{data.values.count} values) #{data.values.map(&:inspect).join(', ')}")

      add_query.execute(*data.values)
      find(@db.last_insert_row_id)
    end

    def insert_data(event)
      Event.attributes.each_with_object({}) do |attribute, data|
        value = event[attribute.name]
        if attribute.composite?
          attribute.composite_keys.map do |method|
            data[:"#{attribute.name}[#{method}]"] =
              if value.nil?
                value
              else
                db_value(value.public_send(method))
              end
          end
        else
          data[attribute.name] = db_value(value)
        end
      end
    end

    private

    ADD_QUERY = <<~SQL
      insert into #{TABLE} ("#{attribute_names.join('", "')}") values (#{attribute_names.count.times.map { '?' }.join(', ')})
    SQL
    private_constant :ADD_QUERY

    def add_query
      @add_query ||= @db.prepare(ADD_QUERY)
    end

    FIND_QUERY = <<~SQL
      select "#{attribute_names.join('", "')}" from #{TABLE} where id = ? limit 1
    SQL
    private_constant :FIND_QUERY

    def find_query
      @find_query ||= @db.prepare(FIND_QUERY)
    end

    ALL_QUERY = <<~SQL
      select "#{attribute_names.join('", "')}" from #{TABLE};
    SQL
    private_constant :ALL_QUERY

    def all_query
      @all_query ||= @db.prepare(ALL_QUERY)
    end

    def parse_row(row)
      nested = El::DataUtils.parse_nested_hash_keys(row, symbolize_keys: true)

      Event.decode(nested)
    end

    def db_value(value)
      if value.respond_to?(:value)
        value.value
      elsif value.is_a?(Time)
        value.to_s
      else
        value
      end
    end
  end
end
