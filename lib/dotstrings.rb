# frozen_string_literal: true

require 'dotstrings/version'
require 'dotstrings/file'
require 'dotstrings/item'
require 'dotstrings/errors'

module DotStrings
  def self.parse(io)
    File.parse(io)
  end

  def self.parse_file(path)
    File.parse_file(path)
  end
end
