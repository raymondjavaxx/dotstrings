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
      items = []

      parser = Parser.new
      parser.on_item { |item| items << item }
      parser << io.read

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

    def <<(item)
      @items << item
    end

    def append(item)
      self << item
    end

    def delete(key)
      @items.delete_if { |item| item.key == key }
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
