# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Configuration and Utilities
gem 'figaro', '~> 1.2'
gem 'rake'

# Web Application
gem 'puma', '~> 5'
gem 'roda', '~> 3'
gem 'slim', '~> 4'

# Database
gem 'hirb', '~> 0.7'
gem 'hirb-unicode', '~> 0.0.5'
gem 'sequel', '5.62.0'

group :development, :test do
  gem 'sqlite3', '~> 1.5.3'
end

group :production do
  gem 'pg'
end

# Validation
gem 'dry-struct', '~> 1'
gem 'dry-types', '~> 1'

# Networking
gem 'http', '~> 5.1'

# Testing
gem 'minitest', '~> 5'
gem 'minitest-rg', '~> 5'
gem 'rerun', '~> 0'
gem 'simplecov', '~> 0.21.2'
gem 'vcr', '~> 6.0'
gem 'webmock', '~> 3.0'

# Utility Tools

# Debugging
gem 'pry'

# Code Quality
group :development do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end
