# frozen_string_literal: true

module Zman
  class Note < Entity
    has :content, :string
    references :event
    timestamp
  end
end
