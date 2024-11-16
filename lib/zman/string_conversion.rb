# frozen_string_literal: true

module Zman
  module StringConversion
    module_function

    def camelcase(string, uppercase_first: true)
      string = string.to_s
      string = if uppercase_first
                 string.sub(/^[a-z\d]*/, &:capitalize)
               else
                 string.sub(/^[A-Z\d]*/) do |match|
                   match[0].downcase!
                   match
                 end
               end
      string.gsub!(%r{(?:_|(/))([a-z\d]*)}i) { Regexp.last_match(2).capitalize.to_s }
      string.gsub!('/', '::')
      string
    end

    def constantize(string)
      string.split('::').reduce(Object) do |mod, const|
        mod.const_get(const)
      end
    end
  end
end
