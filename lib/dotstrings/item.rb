# frozen_string_literal: true

module DotStrings
  class Item
    attr_reader :comment, :key, :value

    def initialize(key:, value:, comment: nil)
      @comment = comment
      @key = key
      @value = value
    end

    def to_s(escape_single_quotes: false)
      result = []

      result << "/* #{comment} */" unless comment.nil?
      result << format('"%<key>s" = "%<value>s";', {
        key: serialize_string(key, escape_single_quotes: escape_single_quotes),
        value: serialize_string(value, escape_single_quotes: escape_single_quotes)
      })

      result.join("\n")
    end

    private

    def serialize_string(string, escape_single_quotes:)
      replacements = [
        ['"', '\\"'],
        ["\t", '\t'],
        ["\n", '\n'],
        ["\r", '\r'],
        ["\0", '\\0']
      ]

      replacements << ["'", "\\'"] if escape_single_quotes

      replacements.each do |replacement|
        string = string.gsub(replacement[0]) { replacement[1] }
      end

      string
    end
  end
end
