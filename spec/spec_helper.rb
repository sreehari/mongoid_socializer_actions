require 'rubygems'
require 'bundler'
Bundler.setup

require 'mongoid'
require 'database_cleaner'

models_folder = File.join(File.dirname(__FILE__), 'mongoid/models')

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))

Mongoid.load! '/Users/sreehari/MyProjects/mongoid_likes/spec/config/mongoid.yml', :test

require 'mongoid_socializer_actions'
require 'rspec'
require 'rspec/autorun'
require 'pry-rails'

Dir[ File.join(models_folder, '*.rb') ].each { |file|
  require file
  file_name = File.basename(file).sub('.rb', '')
  klass = file_name.classify.constantize
  klass.collection.drop
}

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
