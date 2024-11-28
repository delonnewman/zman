# frozen_string_literal: true

module Zman
  class EventRepository
    TABLE = :events

    def self.attribute_names
      @attribute_names ||= Event.attributes.reject(&:composite?).map(&:name)
    end

    def initialize(db, logger = Logger.new($stderr))
      @db = db
      @logger = logger
    end

    FIND_QUERY = <<~SQL
      select #{attribute_names.join(', ')} from #{TABLE} where id = ? limit 1
    SQL
    private_constant :FIND_QUERY

    def find(id)
      @logger.info("#{self.class}#find - SQL - #{FIND_QUERY} #{id.inspect}")

      attributes = @db.query(FIND_QUERY, id).next_hash.transform_keys!(&:to_sym)
      Event.new(attributes)
    end

    ADD_QUERY = <<~SQL
      insert into #{TABLE} (#{attribute_names.join(', ')}) values (#{attribute_names.count.times.map { '?' }.join(', ')})
    SQL
    private_constant :ADD_QUERY

    def add(event)
      values = values_of(event)
      @logger.info("#{self.class}#add - SQL - #{SQL} #{values.inspect}")

      @db.execute(SQL, values)
      find(@db.last_insert_row_id)
    end

    private

    def values_of(event)
      attribute_names.map do |name|
        case (value = event[name])
        when Time
          value.to_s
        else
          value
        end
      end
    end

    def attribute_names
      self.class.attribute_names
    end
  end
end
