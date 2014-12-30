source 'https://rubygems.org'

ruby '2.1.2'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.6'
gem 'rails_12factor', group: :production
# Error reporting
gem 'rollbar', group: :production
gem 'dalli'

gem 'TimezoneParser'

# # Use sqlite3 as the database for Active Record
# gem 'sqlite3'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
gem 'underscore-rails'
gem 'underscore-string-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# For awesome fonts
gem "font-awesome-rails"

# Application ENV configurator
gem 'figaro'

# User roles and authorizations
gem 'cancan'
gem 'devise'

# Bitmasks for arbritrary activerecord fields
gem 'bitmask_attributes'

# API toolkits
gem 'twilio-ruby', '~> 3.12'

# Model auditing and record keeping

# UI/Form handling
gem 'simple_form'
gem 'country_select'
gem 'select2-rails'
gem 'momentjs-rails', '>= 2.8.1'

# Backbone support
gem 'rails-backbone', git: 'git://github.com/codebrew/backbone-rails.git'

# Bootstrap Rails asset support
gem 'therubyracer'
gem 'less-rails' #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem 'haml-rails'
gem 'haml_coffee_assets'
gem 'execjs'

gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'
gem 'bootstrap3-datetimepicker-rails', '~> 3.1.3'
gem 'bootstrap-multiselect-rails'
gem 'devise-bootstrap-views'
gem "bower-rails", "~> 0.9.1"

# Natural language processing
gem 'chronic'

gem 'statesman'
gem 'paper_trail', '~> 3.0.6'

# Add bool conversion
gem 'wannabe_bool'

# Logging tooling
gem 'json-compare'

# Use evented thin server
gem 'thin'
gem 'request_store'

group :development, :test do

  gem 'guard-rspec', require: false
  gem 'guard-zeus'

  # Enable pry and
  # byebug as prys step debugger
  gem 'pry-byebug'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'

  # Model schema documentor
  gem 'annotate'

  # gem 'better_errors'
  # gem 'binding_of_caller'
  gem 'erb2haml'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'zeus'
end

gem 'pry'
gem 'faker'


group :test do
  gem 'twilio-test-toolkit'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.0'

  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end
