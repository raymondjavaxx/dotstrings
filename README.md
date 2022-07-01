# DotStrings

A parser for Apple *strings* files (`.strings`) written in Ruby.

## Usage

```ruby
file = DotStrings::File.parse('en-US/Localized.strings')
file.items.each do |item|
  puts item.comment
  puts item.key
  puts item.value
end
```

```ruby
file = DotStrings::File.parse('en-US/Localized.strings')
puts file.keys # => ["key-1", "key-2", ...]
```

```ruby
file = DotStrings::File.parse('en-US/Localized.strings')
puts file["key-1"].value # => "value-1"
```
