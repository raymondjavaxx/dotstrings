# frozen_string_literal: true

require 'dotstrings/parser'
require 'dotstrings/errors'
require 'dotstrings/item'

module DotStrings
  ##
  # Represents a .strings file.
  #
  # It provides methods to parse .strings, as well as methods for accessing and
  # manipulating localized string items.
  class File
    ##
    # All items in the file.
    attr_reader :items

    def initialize(items = [])
      @items = items
    end

    ##
    # Returns a new File with the items sorted using the given comparator block.
    #
    # If no block is given, the items will be sorted by key.
    def sort(&block)
      new_file = dup
      new_file.sort!(&block)
    end

    ##
    # Sort the items using the given block.
    #
    # If no block is given, the items will be sorted by key.
    def sort!(&block)
      @items.sort!(&block || ->(a, b) { a.key <=> b.key })
      self
    end

    ##
    # Parses a file from the given IO object.
    #
    # @example
    #   io = Zlib::GzipReader.open('path/to/en.lproj/Localizable.strings.gz')
    #   file = DotStrings::File.parse(io)
    #
    # @param io [IO] The IO object to parse.
    # @return [DotStrings::File] The parsed file.
    # @raise [DotStrings::ParsingError] if the file could not be parsed.
    def self.parse(io)
      items = []

      parser = Parser.new
      parser.on_item { |item| items << item }
      parser << normalize_encoding(io.read)

      File.new(items)
    end

    ##
    # Parses the file at the given path.
    #
    # @example
    #   file = DotStrings::File.parse_file('path/to/en.lproj/Localizable.strings')
    #
    # @param path [String] The path to the file to parse.
    # @return [DotStrings::File] The parsed file.
    # @raise [DotStrings::ParsingError] if the file could not be parsed.
    def self.parse_file(path)
      ::File.open(path, 'r') do |file|
        parse(file)
      end
    end

    ##
    # Returns all keys in the file.
    def keys
      @items.map(&:key)
    end

    ##
    # Returns an item by key, if it exists, otherwise nil.
    #
    # @example
    #   item = file['button.title']
    #   unless item.nil?
    #     puts item.value # => 'Submit'
    #   end
    #
    # @param key [String] The key of the item to return.
    # @return [DotStrings::Item] The item, if it exists.
    def [](key)
      @items.find { |item| item.key == key }
    end

    ##
    # Appends an item to the file.
    #
    # @example
    #   file << DotStrings::Item.new(key: 'button.title', value: 'Submit')
    #
    # @param item [DotStrings::Item] The item to append.
    # @return [DotStrings::Item] The item that was appended.
    def <<(item)
      @items << item
      self
    end

    ##
    # Appends an item to the file.
    #
    # @example
    #   file.append(DotStrings::Item.new(key: 'button.title', value: 'Submit'))
    def append(item)
      self << item
    end

    ##
    # Deletes an item by key.
    def delete(key)
      @items.delete_if { |item| item.key == key }
    end

    ##
    # Deletes all items for which the block returns true.
    #
    # @example
    #   file.delete_if { |item| item.key.start_with?('button.') }
    def delete_if(&block)
      @items.delete_if(&block)
      self
    end

    ##
    # Calls the given block once for each item in the file.
    #
    # @param block [Proc] The block to call.
    # @example
    #   file.each do |item|
    #     puts "#{item.key} > #{item.value}"
    #   end
    def each(&block)
      @items.each(&block)
      self
    end

    ##
    # Returns the number of items in the file.
    def length
      @items.length
    end

    ##
    # Returns the number of items in the file.
    #
    # If a block is given, it will count the number of items for which the block returns true.
    #
    # @example
    #   file.count # => 10
    #   file.count { |item| item.key.start_with?('button.') } # => 3
    def count(&block)
      @items.count(&block)
    end

    ##
    # Returns `true` if the file doen't contain any items.
    def empty?
      @items.empty?
    end

    ##
    # Serializes the file to a string.
    #
    # @param escape_single_quotes [Boolean] whether to escape single quotes.
    # @param comments [Boolean] whether to include comments.
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
