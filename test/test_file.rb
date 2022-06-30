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

    assert_nil file.items[2].comment
    assert_equal 'key 3', file.items[2].key
    assert_equal 'value 3', file.items[2].value
  end
end
