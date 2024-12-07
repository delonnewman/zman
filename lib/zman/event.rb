# frozen_string_literal: true

module Zman
  class Event < Entity
    has :title, String
    composite :start_on, of: { value: Integer, precision: Integer }, to: Zman::Date
    composite :end_on, of: { value: Integer, precision: Integer }, to: Zman::Date, optional: true
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
