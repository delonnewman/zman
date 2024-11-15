class Hash
  def with_keys(*keys)
    keys.each_with_object({}) do |key, hash|
      hash[key] = fetch(key) if key?(key)
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
