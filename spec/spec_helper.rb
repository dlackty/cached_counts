require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'active_record'
require 'rails'
require 'active_support/cache/dalli_store'
require 'cached_counts'

ActiveRecord::Base.configurations = YAML::load_file('spec/database.yml')
ActiveRecord::Base.establish_connection(:cached_counts_test)

if ActiveRecord::Base.respond_to?(:raise_in_transactional_callbacks)
  ActiveRecord::Base.raise_in_transactional_callbacks = true
end

Rails.cache = ActiveSupport::Cache::DalliStore.new("localhost")

RSpec.configure do |config|
  config.before(:each) do
    Rails.cache.clear
  end
end

# After the DB connection is setup
require_relative './fixtures.rb'
require 'database_cleaner'

if Rails.version.to_f < 5.0
  require 'test_after_commit'
end
if Rails.version.to_f < 4.2
  require 'after_commit_exception_notification'
end

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

ActiveSupport.run_load_hooks :cached_counts
