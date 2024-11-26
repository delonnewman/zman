# frozen_string_literal: true

require_relative 'core_ext'
require_relative 'zman/transactor'
require_relative 'zman/database'
require_relative 'zman/schema'
require_relative 'zman/attribute'
require_relative 'zman/entity'
require_relative 'zman/entity_facts'
require_relative 'zman/string_conversion'

require_relative 'zman/date'
require_relative 'zman/event'
require_relative 'zman/note'

module Zman
  def self.db
    Database.new(Entity.schema)
  end
end
