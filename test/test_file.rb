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
end
