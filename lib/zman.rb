# frozen_string_literal: true

require 'logger'
require 'sqlite3'

require 'el/data_utils'

require_relative 'core_ext'
require_relative 'zman/types'
require_relative 'zman/schema'
require_relative 'zman/attribute'
require_relative 'zman/entity'
require_relative 'zman/string_conversion'

require_relative 'zman/date'
require_relative 'zman/date/precision'
require_relative 'zman/event'
require_relative 'zman/note'
require_relative 'zman/events_repository'

module Zman
  DATABASE_FILE = Pathname(__dir__).join('../db/zman.sqlite3')

  def self.db
    SQLite3::Database.new(DATABASE_FILE)
  end
end
