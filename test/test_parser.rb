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

  def test_finish_raises_on_escape_at_eof
    parser = DotStrings::Parser.new
    parser << '"key" = "value\\'

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal 'Unexpected end of input after escape character at line 1, column 16 (offset: 15)', error.message
  end

  def test_finish_raises_on_incomplete_multiline_comment
    parser = DotStrings::Parser.new
    parser << '/* comment'

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal 'Unexpected end of input inside multiline comment at line 1, column 11 (offset: 10)', error.message
  end

  def test_finish_raises_on_incomplete_key
    parser = DotStrings::Parser.new
    parser << '"incomplete_key'

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal 'Unexpected end of input inside key at line 1, column 16 (offset: 15)', error.message
  end

  def test_finish_raises_on_missing_equals
    parser = DotStrings::Parser.new
    parser << '"key"'

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal "Unexpected end of input, expecting '=' at line 1, column 6 (offset: 5)", error.message
  end

  def test_finish_raises_on_missing_value
    parser = DotStrings::Parser.new
    parser << '"key" = '

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal 'Unexpected end of input before value at line 1, column 9 (offset: 8)', error.message
  end

  def test_finish_raises_on_incomplete_value
    parser = DotStrings::Parser.new
    parser << '"key" = "value'

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal 'Unexpected end of input inside value at line 1, column 15 (offset: 14)', error.message
  end

  def test_finish_raises_on_missing_semicolon
    parser = DotStrings::Parser.new
    parser << '"key" = "value"'

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal "Unexpected end of input, expecting ';' at line 1, column 16 (offset: 15)", error.message
  end

  def test_finish_raises_on_incomplete_unicode_escape
    parser = DotStrings::Parser.new
    parser << '"key" = "\\U12'

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal 'Unexpected end of input inside unicode escape at line 1, column 14 (offset: 13)', error.message
  end

  def test_finish_raises_on_incomplete_surrogate_pair
    parser = DotStrings::Parser.new
    parser << '"key" = "\\UD83D'

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal 'Unexpected end of input after high surrogate code point at line 1, column 16 (offset: 15)',
                 error.message
  end

  def test_finish_raises_when_surrogate_u_prefix_is_incomplete
    parser = DotStrings::Parser.new
    parser << '"key" = "\\UD83D\\'

    error = assert_raises DotStrings::ParsingError do
      parser.finish!
    end

    assert_equal "Unexpected end of input, expecting 'U' at line 1, column 17 (offset: 16)", error.message
  end
end
