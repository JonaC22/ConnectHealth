source 'https://rubygems.org'

ruby '2.2.2'

# For autoreload server when a file changes, use 'rerun foreman start' instead of 'foreman start'
gem 'rerun'

# For Neo4j connection
gem 'neography'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1.8'

gem 'rails-api'

gem 'rails_12factor', group: :production
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby
gem 'mysql2', '0.3.20'

gem 'tzinfo-data'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'puma'

gem 'bcrypt', '~> 3.1.7' # Se encarga de la password

gem 'active_model_serializers'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  gem 'annotate' # pone anotations del modelo como comentarios en la parte de arriba
  gem 'rspec-rails' # testing
  gem 'guard-rspec' # permite testear permanentemente en desarrollo
  gem 'rubocop'	# controla que se programe con estandares de ruby
end
