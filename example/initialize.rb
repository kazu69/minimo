require 'minimo'

set :fixture_path, File.dirname( __FILE__ ) + '/response'
set :log_dir, File.dirname( __FILE__ ) + '/log'
set :headers, { 'Vary' => 'Accept-Encoding' }

Rack::Handler::WEBrick.run Minimo::Application, { Host: '0.0.0.0', Port: 8080 }
