module Zman
  class Database::Index
    def initialize(index = nil)
      @index = index || {}
    end

    def to_json
      @index.to_json
    end

    def dig(*keys)
      @index.dig(*keys)
    end

    def add(_fact)
      raise NoMethodError
    end

    def remove(_fact)
      raise NoMethodError
    end
  end
end
