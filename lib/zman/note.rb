# frozen_string_literal: true

module Zman
  class Note < Entity
    has :content, String
    references :event
    timestamp
  end
end
