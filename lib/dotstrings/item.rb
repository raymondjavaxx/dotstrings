# frozen_string_literal: true

module DotStrings
  ##
  # Represents a localized string item.
  class Item
    attr_reader :comment, :key, :value

    def initialize(key:, value:, comment: nil)
      @comment = comment
      @key = key
      @value = value
    end

    ##
    # Serializes the item to string.
    #
    # @param escape_single_quotes [Boolean] Whether to escape single quotes.
    # @param include_comment [Boolean] Whether to include the comment.
    def to_s(escape_single_quotes: false, include_comment: true)
      result = []

      result << "/* #{comment} */" unless comment.nil? || !include_comment
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
