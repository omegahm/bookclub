require 'dotenv'
Dotenv.load

require './bookclub.rb'
require 'rack/mobile-detect'
require 'elastic-apm'

use Rack::MobileDetect
use ElasticAPM::Middleware

ElasticAPM.start(app: Sinatra::Application, service_name: 'bookclub')
run Sinatra::Application

at_exit { ElasticAPM.stop }
