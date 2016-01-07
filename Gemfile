source 'https://rubygems.org'

gemspec

gem 'rails', ENV['RAILS_VERSION']

# Use older gems for older Rubies
if RUBY_VERSION.start_with?('1.8.7', '1.9.2')
  gem 'i18n', '~> 0.6.4'
  gem 'rack-cache', '1.2'
end
