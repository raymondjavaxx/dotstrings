# frozen_string_literal: true

module DotStrings
  class Item
    attr_reader :comment, :key, :value

    def initialize(key:, value:, comment: nil)
      @comment = comment
      @key = key
      @value = value
    end

    def to_s
      result = []

      result << "/* #{comment} */" unless comment.nil?
      result << "\"#{key}\" = \"#{value}\";"

      result.join("\n")
    end
  end
end
