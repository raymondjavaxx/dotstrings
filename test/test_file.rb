# frozen_string_literal: true

require_relative 'test_helper'

class TestFile < Minitest::Test
  def test_sort
    file = DotStrings::File.new([
      DotStrings::Item.new(key: 'key 3', value: 'value 3'),
      DotStrings::Item.new(key: 'key 2', value: 'value 2'),
      DotStrings::Item.new(key: 'key 1', value: 'value 1')
    ])

    sorted = file.sort

    assert_equal ['key 1', 'key 2', 'key 3'], sorted.keys
  end

  def test_delete
    items = [
      DotStrings::Item.new(key: 'key 1', value: 'value 1'),
      DotStrings::Item.new(key: 'key 2', value: 'value 2'),
      DotStrings::Item.new(key: 'key 3', value: 'value 3')
    ]

    file = DotStrings::File.new(items)

    file.delete('key 2')

    assert_equal 2, file.items.size
    assert_equal ['key 1', 'key 3'], file.keys
  end

  def test_delete_if
    file = DotStrings::File.new([
      DotStrings::Item.new(key: 'key 1', value: 'value 1'),
      DotStrings::Item.new(key: 'key 2', value: 'value 2'),
      DotStrings::Item.new(key: 'key 3', value: 'value 3')
    ])

    file.delete_if { |item| item.key == 'key 2' }

    assert_equal ['key 1', 'key 3'], file.keys
  end

  def test_access_by_key
    items = [
      DotStrings::Item.new(key: 'key 1', value: 'value 1'),
      DotStrings::Item.new(key: 'key 2', value: 'value 2'),
      DotStrings::Item.new(key: 'key 3', value: 'value 3')
    ]

    file = DotStrings::File.new(items)

    assert_equal 'value 1', file['key 1'].value
    assert_equal 'value 2', file['key 2'].value
    assert_equal 'value 3', file['key 3'].value
  end

  def test_append
    file = DotStrings::File.new
    file.append(DotStrings::Item.new(key: 'key 1', value: 'value 1'))

    assert_equal 1, file.items.size
  end

  def test_length
    file = DotStrings::File.new([
      DotStrings::Item.new(comment: 'Comment 1', key: 'key 1', value: 'value 1'),
      DotStrings::Item.new(comment: 'Comment 2', key: 'key 2', value: 'value 2'),
      DotStrings::Item.new(comment: 'Comment 3', key: 'key 3', value: 'value 3')
    ])

    assert_equal 3, file.length
  end

  def test_each
    items = [
      DotStrings::Item.new(comment: 'Comment 1', key: 'key 1', value: 'value 1'),
      DotStrings::Item.new(comment: 'Comment 2', key: 'key 2', value: 'value 2'),
      DotStrings::Item.new(comment: 'Comment 3', key: 'key 3', value: 'value 3')
    ]

    seen = []

    file = DotStrings::File.new(items)
    file.each do |item|
      seen << item
    end

    assert_equal(items, seen)
  end

  def test_count_without_arguments
    file = DotStrings::File.new([
      DotStrings::Item.new(key: 'button.continue', value: 'Continue'),
      DotStrings::Item.new(key: 'button.cancel', value: 'Cancel'),
      DotStrings::Item.new(key: 'button.back', value: 'Back'),
      DotStrings::Item.new(key: 'title.book', value: 'Book Appointment')
    ])

    assert_equal(4, file.count)
  end

  def test_count_with_block
    file = DotStrings::File.new([
      DotStrings::Item.new(key: 'button.continue', value: 'Continue'),
      DotStrings::Item.new(key: 'button.cancel', value: 'Cancel'),
      DotStrings::Item.new(key: 'button.back', value: 'Back'),
      DotStrings::Item.new(key: 'title.book', value: 'Book Appointment')
    ])

    assert_equal(3, file.count { |item| item.key.start_with?('button.') })
  end

  def test_empty
    file = DotStrings::File.new

    assert_empty file

    file << DotStrings::Item.new(key: 'button.continue', value: 'Continue')

    refute_empty file
  end

  def test_equality
    file1 = DotStrings::File.new([
      DotStrings::Item.new(key: 'button.continue', value: 'Continue'),
      DotStrings::Item.new(key: 'button.cancel', value: 'Cancel')
    ])

    file2 = DotStrings::File.new([
      DotStrings::Item.new(key: 'button.continue', value: 'Continue'),
      DotStrings::Item.new(key: 'button.cancel', value: 'Cancel')
    ])

    file3 = DotStrings::File.new([
      DotStrings::Item.new(key: 'button.back', value: 'Back'),
      DotStrings::Item.new(key: 'title.book', value: 'Book Appointment')
    ])

    assert_equal file1, file2
    refute_equal file1, file3
  end

  def test_to_string
    file = DotStrings::File.new([
      DotStrings::Item.new(comment: 'Comment 1', key: 'key 1', value: 'value 1'),
      DotStrings::Item.new(comment: 'Comment 2', key: 'key 2', value: 'value 2'),
      DotStrings::Item.new(comment: 'Comment 3', key: 'key 3', value: '👻'),
      DotStrings::Item.new(comment: 'Comment 4', key: "\"'\t\n\r\0", value: "\"'\t\n\r\0")
    ])

    expected = <<~'END_OF_DOCUMENT'
      /* Comment 1 */
      "key 1" = "value 1";

      /* Comment 2 */
      "key 2" = "value 2";

      /* Comment 3 */
      "key 3" = "👻";

      /* Comment 4 */
      "\"'\t\n\r\0" = "\"'\t\n\r\0";
    END_OF_DOCUMENT

    assert_equal expected, file.to_s
  end

  def test_to_string_no_comments
    file = DotStrings::File.new([
      DotStrings::Item.new(comment: 'Comment 1', key: 'key 1', value: 'value 1'),
      DotStrings::Item.new(comment: 'Comment 2', key: 'key 2', value: 'value 2')
    ])

    expected = <<~END_OF_DOCUMENT
      "key 1" = "value 1";

      "key 2" = "value 2";
    END_OF_DOCUMENT

    assert_equal expected, file.to_s(comments: false)
  end

  def test_to_string_can_escape_single_quotes
    items = [
      DotStrings::Item.new(comment: 'Comment', key: "key'", value: "value'")
    ]

    file = DotStrings::File.new(items)

    expected = <<~'END_OF_DOCUMENT'
      /* Comment */
      "key\'" = "value\'";
    END_OF_DOCUMENT

    assert_equal expected, file.to_s(escape_single_quotes: true)
  end
end
