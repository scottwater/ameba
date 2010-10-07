require 'bundler'
Bundler.setup

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..',  'test')

require 'mocha'
require 'mongo_mapper'
require 'test_content_parser'
require "spec"
require 'webrat'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

def load_test_data(filename)
  base = File.expand_path(File.dirname(__FILE__) + '/data')
  File.read(File.join(base, filename))
end

def load_test_data_to_h(filename)
  content = load_test_data filename
  ContentParser.to_frontmatter content
end

def a_user(name='Scott Watermasysk')
  u = User.find_by_name(name)
  u = User.create!(:name => 'Scott Watermasysk', :email => 'scottwater+sampleuser@gmail.com', :password => '1234') unless u
  u
end

module AmebaWebratHelper #requires explicit MongoMapper initialization
  require File.expand_path(File.dirname(__FILE__) +	 '/../ameba')
  def app
    Sinatra::Application
  end
end

module AmebaRackUpHelper
  def app
    eval "Rack::Builder.new {( " + File.read(File.dirname(__FILE__) + '/../config.ru') + "\n )}"
  end  
end


Webrat.configure do |config|
  config.mode= :rack
end

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
  config.include Webrat::Methods
  config.include Webrat::Matchers
  config.include AmebaRackUpHelper
  config.include Sinatra::Routes    
end

