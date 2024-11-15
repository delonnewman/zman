# frozen_string_literal: true

module Zman
  class Event < Entity
    has :title, :string
    composite :date, of: { value: :integer, precision_value: :integer }, class_name: 'Zman::Date', constructor: :composite
    timestamp
  end
end
