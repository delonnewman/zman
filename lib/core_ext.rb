class Hash
  def pick(*keys)
    keys.each_with_object({}) do |key, hash|
      hash[key] = fetch(key) if key?(key)
    end
  end

  def encode_keys(namespace)
    transform_keys do |key|
      name = "#{namespace}[#{key}]"
      if key.is_a?(Symbol)
        name.to_sym
      else
        name
      end
    end
  end
end

class String
  def camelcase(**options)
    Zman::StringConversion.camelcase(self, **options)
  end

  def constantize
    Zman::StringConversion.constantize(self)
  end
end
