# DotStrings

A parser for Apple *strings* files (`.strings`) written in Ruby. Some of the features of DotStrings include:

* A fast and memory-efficient streaming parser.
* Support for multiline (`/* ... */`) comments as well as single-line comments (`// ...`).
* An API for creating strings files programmatically.
* Handles Unicode and escaped characters.
* Helpful error messages: know which line and column fail to parse and why.
* Well [tested](test) and [documented](https://www.rubydoc.info/gems/dotstrings/DotStrings).

## Installing

You can install DotStrings manually by running:

```shell
$ gem install dotstrings
```

Or by adding the following entry to your [Gemfile](https://guides.cocoapods.org/using/a-gemfile.html), then running `$ bundle install`.

```ruby
gem 'dotstrings'
```

## Usage

You can load `.strings` files using the `DotString.parse()` utility method. This method returns a `DotStrings::File` object or raises an exception if the file cannot be parsed.

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
  key: 'button.cancel.title',
  value: 'Cancel'
)
```

### Saving a file

```ruby
File.write('en-US/Localizable.strings', file.to_s)
```
