# frozen_string_literal: true

module Zman
  class Event < Entity
    has :title, String
    composite :start_on, Zman::Date, of: { value: Integer, precision: Integer }
    composite :end_on, Zman::Date, of: { value: Integer, precision: Integer }, optional: true
    references :layer
    timestamp

    def date
      return if range?

      start_on
    end

    def date_range
      return if single?

      start_on..end_on
    end

    def single?
      !range?
    end

    def range?
      start_on && end_on
    end
  end
end
