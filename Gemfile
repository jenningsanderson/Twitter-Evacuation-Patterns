source 'http://rubygems.org'

#These are the latest stable versions of these gems to work with MongoMapper
gem 'mongo',          '1.8.6'
gem 'bson_ext',       '1.8.6'
gem 'mongo_mapper',   '0.13.1'
gem 'json',           '1.8.3'

group :server do
  gem 'activesupport'
  # gem 'rails'
end

group :geo do
  gem 'georuby',       '2.5.2'
  gem 'rgeo',          '0.3.20'
  gem 'rgeo-geojson'
end

group :web do
  gem 'jekyll',        '2.5.3'
end

group :publish do
  gem 'aws-sdk'
  # gem 'google_drive', '1.0.0.pre1' // Will have to fix this eventually
  gem 'retryable'
  gem 'Static-Bliss', github: 'jenningsanderson/Static-bliss'
end

gem 'mini_portile', '0.6.0'

#If we use the Gemfile, then we can always build the latest version of epic-geo
gem 'epic_geo', 	github: 'jenningsanderson/epic-geo'
