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

## Strict Mode
By default the parser runs in *strict mode*. This means that it will raise a `DotStrings::ParsingError` if it encouters coments that are not tied to a key-value pair. For example, the following file will raise an error the first comment is not followed by a key-value pair:

```
/* Spanish localizations */

/* Title for a button for accepting something */
"Accept" = "Aceptar";
```

In strict mode, the parser will also raise an error if it encounters escaped characters that don't need to be escaped. For example, the following file will raise an error because the `?` character doesn't need to be escaped:

```
/* Confirmation message */
"Are you sure\?" = "¿Estás seguro\?";
```

If you want to disable strict mode, you can pass `strict: false` to the `DotStrings.parse_file()` method. This will match the behavior of Apple's own parser which is more lenient.

```ruby
file = DotStrings.parse_file('es-ES/Localizable.strings', strict: false)
```

## Examples

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

For more examples, consult the [documentation](https://www.rubydoc.info/gems/dotstrings/DotStrings) or the [test suite](test).
