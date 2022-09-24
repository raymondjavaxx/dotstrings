# Changelog

## [v0.5.0] - 2022-09-24
* Added `strict` parameter to the parser to allow for more lenient parsing. This is useful in cases where we don't want the parser to raise an error when encountering multiple comments or escaped characters that don't need to be escaped.

## [v0.4.0] - 2022-09-18
### Added
* Added `DotStrings::File#each`, `DotStrings::File#length`, `DotStrings::File#count`, and `DotStrings::File#empty?` methods.
* Allow comparing `DotStrings::File` objects.

## [v0.3.0] - 2022-08-07
### Changed
* Improved unicode code point parsing and validation.
* Added `DotStrings::File#sort`, `DotStrings::File#sort!`, and `DotStrings::File#delete_if` methods.
* Improved documentation.

## [v0.2.0] - 2022-07-17
### Changed
* Made some state transitions more strict.
* Added option to ignore comments when serializing.

## [v0.1.1] - 2022-07-12
### Changed
* Escaping single quotes is now optional.

## [v0.1.0] - 2022-07-06
### Added
* Initial release.

[v0.5.0]: https://github.com/raymondjavaxx/dotstrings/releases/tag/v0.5.0
[v0.4.0]: https://github.com/raymondjavaxx/dotstrings/releases/tag/v0.4.0
[v0.3.0]: https://github.com/raymondjavaxx/dotstrings/releases/tag/v0.3.0
[v0.2.0]: https://github.com/raymondjavaxx/dotstrings/releases/tag/v0.2.0
[v0.1.1]: https://github.com/raymondjavaxx/dotstrings/releases/tag/v0.1.1
[v0.1.0]: https://github.com/raymondjavaxx/dotstrings/releases/tag/v0.1.0
