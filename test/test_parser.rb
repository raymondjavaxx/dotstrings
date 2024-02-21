# frozen_string_literal: true

require_relative 'test_helper'

class TestParser < Minitest::Test
  def test_handles_extraneous_characters_at_start_of_file
    parser = DotStrings::Parser.new
    error = assert_raises DotStrings::ParsingError do
      parser << '$'
    end

    assert_equal "Unexpected character '$' at line 1, column 1 (offset: 0)", error.message
  end

  def test_handles_malformed_comments
    parser = DotStrings::Parser.new
    error = assert_raises DotStrings::ParsingError do
      parser << '/@ test'
    end

    assert_equal "Unexpected character '@' at line 1, column 2 (offset: 1)", error.message
  end

  def test_raises_error_when_escaping_invalid_character
    parser = DotStrings::Parser.new
    error = assert_raises DotStrings::ParsingError do
      parser << '"\\z" = "value";'
    end

    assert_equal "Unexpected character 'z' at line 1, column 3 (offset: 2)", error.message
  end

  def test_raises_error_when_items_are_not_separated_by_semicolon
    parser = DotStrings::Parser.new
    error = assert_raises DotStrings::ParsingError do
      parser << '"key_1" = "value_1" "key_2" = "value_2"'
    end

    assert_equal "Unexpected character '\"', expecting ';' at line 1, column 21 (offset: 20)", error.message
  end

  def test_raises_error_if_low_surrogate_is_not_formatted_correctly
    parser = DotStrings::Parser.new
    error = assert_raises DotStrings::ParsingError do
      parser << '"key" = "\UD83D\$DC7B";'
    end

    assert_equal "Unexpected character '$', expecting 'U' at line 1, column 17 (offset: 16)", error.message
  end

  def test_raises_error_if_unicode_sequence_contains_invalid_characters
    parser = DotStrings::Parser.new
    error = assert_raises DotStrings::ParsingError do
      parser << '"key" = "\UD83Z";'
    end

    assert_equal "Unexpected character 'Z', expecting a hex digit at line 1, column 15 (offset: 14)", error.message
  end
end
