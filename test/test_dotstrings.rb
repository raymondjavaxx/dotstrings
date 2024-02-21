# frozen_string_literal: true

require_relative 'test_helper'

class TestDotStrings < MiniTest::Test
  def test_parse_can_parse_valid_files
    file = DotStrings.parse_file('test/fixtures/valid.strings')

    assert_equal 3, file.items.size

    assert_equal 'Single line comment', file.items[0].comment
    assert_equal 'key 1', file.items[0].key
    assert_equal 'value 1', file.items[0].value

    assert_equal "Multi line\ncomment", file.items[1].comment
    assert_equal 'key 2', file.items[1].key
    assert_equal 'value 2', file.items[1].value
  end

  def test_can_parse_file_with_escaped_quotes
    file = DotStrings.parse_file('test/fixtures/escaped_quotes.strings')

    assert_equal 1, file.items.size
    assert_equal 'some "key"', file.items[0].key
    assert_equal 'some "value"', file.items[0].value
  end

  def test_can_parse_file_with_escaped_single_quotes
    file = DotStrings.parse_file('test/fixtures/escaped_single_quotes.strings')

    assert_equal 1, file.items.size
    assert_equal 'some \'key\'', file.items[0].key
    assert_equal 'some \'value\'', file.items[0].value
  end

  def test_can_parse_file_in_lenient_mode
    file = DotStrings.parse_file('test/fixtures/lenient.strings', strict: false)

    assert_equal 1, file.items.size
    assert_equal 'some key', file.items[0].key
    assert_equal 'some value', file.items[0].value
  end

  def test_can_parse_file_with_escaped_tabs
    file = DotStrings.parse_file('test/fixtures/escaped_tabs.strings')

    assert_equal 1, file.items.size
    assert_equal "some\tkey", file.items[0].key
    assert_equal "some\tvalue", file.items[0].value
  end

  def test_can_parse_files_with_escaped_carriage_returns
    file = DotStrings.parse_file('test/fixtures/escaped_carriage_returns.strings')

    assert_equal 1, file.items.size
    assert_equal "some\rkey", file.items[0].key
    assert_equal "some\rvalue", file.items[0].value
  end

  def test_can_parse_files_with_escaped_nil
    file = DotStrings.parse_file('test/fixtures/escaped_nil.strings')

    assert_equal 1, file.items.size
    assert_equal "key\0", file.items[0].key
    assert_equal "value\0", file.items[0].value
  end

  def test_can_parse_files_with_escaped_new_lines
    file = DotStrings.parse_file('test/fixtures/escaped_new_lines.strings')

    assert_equal 1, file.items.size
    assert_equal "some\nkey", file.items[0].key
    assert_equal "some\nvalue", file.items[0].value
  end

  def test_can_parse_files_with_escaped_backslashes
    file = DotStrings.parse_file('test/fixtures/escaped_backslashes.strings')

    assert_equal 1, file.items.size
    assert_equal 'some\\key', file.items[0].key
    assert_equal 'some\\value', file.items[0].value
  end

  def test_can_parse_files_with_escaped_unicode
    file = DotStrings.parse_file('test/fixtures/escaped_unicode.strings')

    assert_equal 1, file.items.size
    assert_equal '$', file.items[0].key
    assert_equal '⚡👻', file.items[0].value
  end

  def test_raises_error_when_bad_surrogate_pair_is_found
    # rubocop:disable Layout/LineLength
    test_cases = {
      'escaped_unicode~bad_surrogate_order.strings' => 'Found a low surrogate code point before a high surrogate at line 1, column 15 (offset: 14)',
      'escaped_unicode~duplicated_high_surrogate.strings' => 'Found a high surrogate code point after another high surrogate at line 1, column 21 (offset: 20)',
      'escaped_unicode~incomplete_surrogate_pair.strings' => 'Unexpected character \'"\', expecting another unicode codepoint at line 1, column 16 (offset: 15)',
      'escaped_unicode~non_surrogate_after_high_surrogate.strings' => 'Invalid unicode codepoint \'\U26A1\' after a high surrogate code point at line 1, column 21 (offset: 20)'
    }
    # rubocop:enable Layout/LineLength

    test_cases.each do |filename, error_message|
      error = assert_raises DotStrings::ParsingError do
        DotStrings.parse_file("test/fixtures/#{filename}")
      end

      assert_equal error_message, error.message
    end
  end

  def test_can_parse_utf16le_files_with_bom
    file = DotStrings.parse_file('test/fixtures/utf16le_bom.strings')

    assert_equal 1, file.items.size
    assert_equal 'key', file.items[0].key
    assert_equal 'value', file.items[0].value
  end

  def test_can_parse_utf16be_files_with_bom
    file = DotStrings.parse_file('test/fixtures/utf16be_bom.strings')

    assert_equal 1, file.items.size
    assert_equal 'key', file.items[0].key
    assert_equal 'value', file.items[0].value
  end

  def test_can_parse_utf8_files_with_bom
    file = DotStrings.parse_file('test/fixtures/utf8_bom.strings')

    assert_equal 1, file.items.size
    assert_equal 'key', file.items[0].key
    assert_equal 'value', file.items[0].value
  end

  def test_parse_from_io
    io = File.open('test/fixtures/valid.strings')
    file = DotStrings.parse(io)

    assert_equal 3, file.items.size
  end

  def test_parse_from_io_in_lenient_mode
    io = File.open('test/fixtures/lenient.strings')
    file = DotStrings.parse(io, strict: false)

    assert_equal 1, file.items.size
  end
end
