# frozen_string_literal: true

module Zman
  class Event < Entity
    has :title, String
    composite :date, of: { value: Integer, precision_value: Integer }, class_name: 'Zman::Date', constructor: :composite
    timestamp
  end
end
