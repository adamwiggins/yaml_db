source 'https://rubygems.org'

gemspec

gem 'rails', ENV['RAILS_VERSION']

# Hold i18n back for older Rubies
if RUBY_VERSION =~ /^1\.8\.7/ || RUBY_VERSION =~ /^1\.9\.2/
  gem 'i18n', '~> 0.6.4'
end
