module Zman
  class Layer < Zman::Entity
    has :name, String
    has :slug, String, default: -> { name.gsub(/\W/, '-').downcase }
    has :description, String, optional: true
    timestamp
  end
end
