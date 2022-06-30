# frozen_string_literal: true

require_relative 'helper'

class TestFile < MiniTest::Test
  def test_to_s
    item = DotStrings::Item.new(comment: 'Comment', key: 'key 1', value: 'value 1')
    assert_equal "/* Comment */\n\"key 1\" = \"value 1\";", item.to_s
  end

  def test_to_s_with_nil_comment
    item = DotStrings::Item.new(comment: nil, key: 'key 1', value: 'value 1')
    assert_equal "\"key 1\" = \"value 1\";", item.to_s
  end
end
