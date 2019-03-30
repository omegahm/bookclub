require './bookclub.rb'
require 'rack/mobile-detect'

use Rack::MobileDetect
run Sinatra::Application
