# frozen_string_literal: true

require_relative 'helper'

class TestFile < MiniTest::Test
  def test_parse_can_parse_valid_files
    file = DotStrings::File.parse_file('test/fixtures/valid.strings')

    assert_equal 3, file.items.size

    assert_equal 'Single line comment', file.items[0].comment
    assert_equal 'key 1', file.items[0].key
    assert_equal 'value 1', file.items[0].value

    assert_equal "Multi line\ncomment", file.items[1].comment
    assert_equal 'key 2', file.items[1].key
    assert_equal 'value 2', file.items[1].value
  end

  def test_can_parse_file_with_escaped_quotes
    file = DotStrings::File.parse_file('test/fixtures/escaped_quotes.strings')

    assert_equal 1, file.items.size
    assert_equal 'some "key"', file.items[0].key
    assert_equal 'some "value"', file.items[0].value
  end

  def test_can_parse_file_with_escaped_tabs
    file = DotStrings::File.parse_file('test/fixtures/escaped_tabs.strings')

    assert_equal 1, file.items.size
    assert_equal "some\tkey", file.items[0].key
    assert_equal "some\tvalue", file.items[0].value
  end

  def test_can_parse_files_with_escaped_carriage_returns
    file = DotStrings::File.parse_file('test/fixtures/escaped_carriage_returns.strings')

    assert_equal 1, file.items.size
    assert_equal "some\rkey", file.items[0].key
    assert_equal "some\rvalue", file.items[0].value
  end

  def test_can_parse_files_with_escaped_nil
    file = DotStrings::File.parse_file('test/fixtures/escaped_nil.strings')

    assert_equal 1, file.items.size
    assert_equal "key\0", file.items[0].key
    assert_equal "value\0", file.items[0].value
  end

  def test_can_parse_files_with_escaped_new_lines
    file = DotStrings::File.parse_file('test/fixtures/escaped_new_lines.strings')

    assert_equal 1, file.items.size
    assert_equal "some\nkey", file.items[0].key
    assert_equal "some\nvalue", file.items[0].value
  end

  def test_can_parse_files_with_escaped_backslashes
    file = DotStrings::File.parse_file('test/fixtures/escaped_backslashes.strings')

    assert_equal 1, file.items.size
    assert_equal 'some\\key', file.items[0].key
    assert_equal 'some\\value', file.items[0].value
  end

  def test_can_parse_files_with_escaped_unicode
    file = DotStrings::File.parse_file('test/fixtures/escaped_unicode.strings')

    assert_equal 1, file.items.size
    assert_equal '$', file.items[0].key
    assert_equal '⚡👻', file.items[0].value
  end
end
