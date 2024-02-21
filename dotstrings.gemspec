# frozen_string_literal: true

require './lib/dotstrings/version'

Gem::Specification.new do |s|
  s.name = 'dotstrings'
  s.version = DotStrings::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Ramon Torres']
  s.email = ['raymondjavaxx@gmail.com']
  s.homepage = 'https://github.com/raymondjavaxx/dotstrings'
  s.description = s.summary = 'Parse and create .strings files used in localization of iOS and macOS apps.'
  s.files = Dir['README.md', 'CHANGELOG.md', 'LICENSE', 'lib/**/*.rb']
  s.require_paths = ['lib']
  s.license = 'MIT'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest', '~> 5.14'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-minitest'
  s.add_development_dependency 'rubocop-rake'
  s.add_development_dependency 'simplecov'

  s.required_ruby_version = '>= 2.6.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
