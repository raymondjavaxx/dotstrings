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
      result << "\"#{serialize_string(key)}\" = \"#{serialize_string(value)}\";"

      result.join("\n")
    end

    private

    def serialize_string(string)
      replacements = [
        ['"', '\\"'],
        ["\t", '\t'],
        ["\n", '\n'],
        ["\r", '\r'],
        ["\0", '\\\0']
      ]

      replacements.each do |replacement|
        string = string.gsub(replacement[0], replacement[1])
      end

      string
    end
  end
end
