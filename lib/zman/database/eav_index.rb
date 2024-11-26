# lib/eav_index.rb

module Zman
  class Database::EAVIndex < Database::Index
    def add(fact)
      @index[fact.ref] ||= {}
      @index[fact.ref][fact.attribute] ||= []
      @index[fact.ref][fact.attribute] << fact.value
      self
    end

    def remove(fact)
      values = @index.dig(fact.ref, fact.attribute)
      return false unless values

      values.delete(fact.value)
      fact
    end
  end
end
