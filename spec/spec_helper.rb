require 'rubygems'
require 'bundler'
Bundler.setup

require 'mongoid'
require 'database_cleaner'

models_folder = File.join(File.dirname(__FILE__), 'mongoid/models')

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'app'))
require 'pry-rails'

Mongoid.load! File.expand_path('../config/mongoid.yml', __FILE__), :test

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
