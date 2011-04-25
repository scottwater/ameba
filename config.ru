require 'bundler'
Bundler.setup
require 'rack-flash'
require 'rack-rewrite'

$: << '.'

require 'ameba'

configure :production do
  require 'newrelic_rpm'
end

DEFAULT_SECRET_KEY = 'not_yet_set' unless defined?(DEFAULT_SECRET_KEY)

secret_session_key = ENV['AMEBA_SECRET_KEY'] ||= DEFAULT_SECRET_KEY
raise 'secret key is not yet set' if production? && secret_session_key == DEFAULT_SECRET_KEY

use Rack::Session::Cookie, 
  :key => 'ameba.session', 
  :expire_after => 604800, # 1 week
  :secret =>  secret_session_key
use Rack::Flash

use Rack::Rewrite do

    r301 %r{.*}, "http://#{ENV['AMEBA_SITE_URL']}$&", :if => Proc.new {|rack_env|
        ENV['RACK_ENV'] == 'production' && rack_env['SERVER_NAME'] != ENV['AMEBA_SITE_URL']
      } if ENV['AMEBA_SITE_URL']

    r301 %r{^(.+)/$}, '$1'
    r301 %r{^/tags}, '/'
  end



run Sinatra::Application
