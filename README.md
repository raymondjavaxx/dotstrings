# DotStrings

A parser for Apple *strings* files (`.strings`) written in Ruby.

## Usage

You can load `.strings` files using using the `DotString.parse()` utility method. This method returns a `DotStrings::File` object or throw an exception if the file is invalid.

```ruby
file = DotStrings.parse_file('en-US/Localizable.strings')
file.items.each do |item|
  puts item.comment
  puts item.key
  puts item.value
end
```

## Examples

### Listing keys

```ruby
puts file.keys
# => ["key 1", "key 2", ...]
```

### Accessing items by key

```ruby
puts file['key 1'].value
# => "value 1"
```

### Deleting items by key

```ruby
file.delete('key 1')
```

### Appending items

```ruby
file << DotStrings::Item(
  comment: 'Title for the cancel button',
  key: 'button.cancel.title'
  value: 'Cancel'
)
```

### Saving a file

```ruby
File.write('en-US/Localizable.strings', file.to_s)
```
