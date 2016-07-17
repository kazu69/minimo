libdir = File.dirname(File.dirname(__FILE__)) + '../lib'
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

require 'simplecov'
unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end

require 'rspec'
require 'rack/test'
require 'minimo'
require 'pry'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.mock_with :rspec
  config.default_path = 'spec'
  config.pattern = 'spec/**/*_spec.rb'
  config.formatter = 'progress'
  config.color = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
