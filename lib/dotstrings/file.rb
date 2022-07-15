# frozen_string_literal: true

require 'dotstrings/parser'
require 'dotstrings/errors'
require 'dotstrings/item'

module DotStrings
  class File
    attr_reader :items

    def initialize(items = [])
      @items = items
    end

    def self.parse(io)
      items = []

      parser = Parser.new
      parser.on_item { |item| items << item }
      parser << normalize_encoding(io.read)

      File.new(items)
    end

    def self.parse_file(path)
      ::File.open(path, 'r') do |file|
        parse(file)
      end
    end

    def keys
      @items.map(&:key)
    end

    def [](key)
      @items.find { |item| item.key == key }
    end

    def <<(item)
      @items << item
    end

    def append(item)
      self << item
    end

    def delete(key)
      @items.delete_if { |item| item.key == key }
    end

    def to_s(escape_single_quotes: false, comments: true)
      result = []

      @items.each do |item|
        result << item.to_s(
          escape_single_quotes: escape_single_quotes,
          include_comment: comments
        )

        result << ''
      end

      result.join("\n")
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def self.normalize_encoding(str)
      if str.bytesize >= 3 && str.getbyte(0) == 0xEF && str.getbyte(1) == 0xBB && str.getbyte(2) == 0xBF
        # UTF-8 BOM
        str.byteslice(3, str.bytesize - 3)
      elsif str.bytesize >= 2 && str.getbyte(0) == 0xFE && str.getbyte(1) == 0xFF
        # UTF-16 (BE) BOM
        converter = Encoding::Converter.new('UTF-16BE', 'UTF-8')
        str = converter.convert(str)
        str.byteslice(3, str.bytesize - 3)
      elsif str.bytesize >= 2 && str.getbyte(0) == 0xFF && str.getbyte(1) == 0xFE
        # UTF-16 (LE) BOM
        converter = Encoding::Converter.new('UTF-16LE', 'UTF-8')
        str = converter.convert(str)
        str.byteslice(3, str.bytesize - 3)
      else
        str.force_encoding('UTF-8')
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private_class_method :normalize_encoding
  end
end
