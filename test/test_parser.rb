# frozen_string_literal: true

require_relative 'test_helper'

class TestParser < MiniTest::Test
  def test_handles_extraneous_characters_at_start_of_file
    error = assert_raises DotStrings::ParsingError do
      parser = DotStrings::Parser.new
      parser << '$'
    end

    assert_equal "Unexpected character '$' at line 1, column 1 (offset: 0)", error.message
  end

  def test_handles_malformed_comments
    error = assert_raises DotStrings::ParsingError do
      parser = DotStrings::Parser.new
      parser << '/@ test'
    end

    assert_equal "Unexpected character '@' at line 1, column 2 (offset: 1)", error.message
  end

  def test_raises_error_when_escaping_invalid_character
    error = assert_raises DotStrings::ParsingError do
      parser = DotStrings::Parser.new
      parser << '"\\z" = "value";'
    end

    assert_equal "Unexpected character 'z' at line 1, column 3 (offset: 2)", error.message
  end

  def test_raises_error_when_items_are_not_separated_by_semicolon
    error = assert_raises DotStrings::ParsingError do
      parser = DotStrings::Parser.new
      parser << '"key_1" = "value_1" "key_2" = "value_2"'
    end

    assert_equal "Unexpected character '\"', expecting ';' at line 1, column 21 (offset: 20)", error.message
  end

  def test_raises_error_if_low_surrogate_is_not_formatted_correctly
    error = assert_raises DotStrings::ParsingError do
      parser = DotStrings::Parser.new
      parser << '"key" = "\UD83D\$DC7B";'
    end

    assert_equal "Unexpected character '$', expecting 'U' at line 1, column 17 (offset: 16)", error.message
  end
end
