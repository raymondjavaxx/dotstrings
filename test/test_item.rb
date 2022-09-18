# frozen_string_literal: true

require_relative 'test_helper'

class TestFile < MiniTest::Test
  def test_equals
    item1 = DotStrings::Item.new(comment: 'Comment', key: 'key 1', value: 'value 1')
    item2 = DotStrings::Item.new(comment: 'Comment', key: 'key 1', value: 'value 1')
    assert_equal item1, item2
  end

  def test_equals_with_different_comment
    item1 = DotStrings::Item.new(comment: 'Comment', key: 'key 1', value: 'value 1')
    item2 = DotStrings::Item.new(comment: 'Comment 2', key: 'key 1', value: 'value 1')
    refute_equal item1, item2
  end

  def test_equals_with_different_key
    item1 = DotStrings::Item.new(comment: 'Comment', key: 'key 1', value: 'value 1')
    item2 = DotStrings::Item.new(comment: 'Comment', key: 'key 2', value: 'value 1')
    refute_equal item1, item2
  end

  def test_equals_with_different_value
    item1 = DotStrings::Item.new(comment: 'Comment', key: 'key 1', value: 'value 1')
    item2 = DotStrings::Item.new(comment: 'Comment', key: 'key 1', value: 'value 2')
    refute_equal item1, item2
  end

  def test_to_s
    item = DotStrings::Item.new(comment: 'Comment', key: 'key 1', value: 'value 1')
    assert_equal "/* Comment */\n\"key 1\" = \"value 1\";", item.to_s
  end

  def test_to_s_with_nil_comment
    item = DotStrings::Item.new(comment: nil, key: 'key 1', value: 'value 1')
    assert_equal '"key 1" = "value 1";', item.to_s
  end
end
