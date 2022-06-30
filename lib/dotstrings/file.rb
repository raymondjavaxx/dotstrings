# frozen_string_literal: true

require 'dotstrings/parser'
require 'dotstrings/errors'
require 'dotstrings/item'

module DotStrings
  class File
    attr_reader :items

    def initialize(items)
      @items = items
    end

    def self.parse(io)
      parser = Parser.new
      parser << io.read

      File.new(parser.items)
    end

    def self.parse_file(path)
      ::File.open(path, 'r') do |file|
        parse(file)
      end
    end

    def keys
      @items.map(&:key)
    end

    def <<(item)
      @items << item
    end

    def append(item)
      self << item
    end

    def to_s
      result = []

      @items.each do |item|
        result << item.to_s
        result << ''
      end

      result.join("\n")
    end
  end
end
