# frozen_string_literal: true

require 'dotstrings/version'
require 'dotstrings/file'
require 'dotstrings/item'
require 'dotstrings/errors'

module DotStrings
  ##
  # Parses a file from the given IO object.
  #
  # This is a convenience method for {DotStrings::File.parse}.
  #
  # @param io [IO] The IO object to parse.
  # @param strict [Boolean] Whether to parse in strict mode.
  # @return [DotStrings::File] The parsed file.
  def self.parse(io, strict: true)
    File.parse(io, strict: strict)
  end

  ##
  # Parses a .strings file at the given path.
  #
  # This is a convenience method for {DotStrings::File.parse_file}.
  #
  # @param path [String] The path to the .strings file to parse.
  # @param strict [Boolean] Whether to parse in strict mode.
  # @return [DotStrings::File] The parsed file.
  def self.parse_file(path, strict: true)
    File.parse_file(path, strict: strict)
  end
end
