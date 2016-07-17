require 'spec_helper'
require 'rexml/document'

describe Minimo::Base do
  let(:app) { Minimo::Application }
  context 'const variable define' do
    it 'define NO_CONTENT_METHOD' do
      expect(Minimo::Base.const_defined? :NO_CONTENT_METHOD).to be true
      expect(Minimo::Base.const_get :NO_CONTENT_METHOD).to eq %w(DELETE PATCH PUT)
    end

    it 'define CREATED_METHOD' do
      expect(Minimo::Base.const_defined? :CREATED_METHOD).to be true
      expect(Minimo::Base.const_get :CREATED_METHOD).to eq %w(POST)
    end

    it 'define CONTENT_TYPE' do
      const = Minimo::Base.const_get :CONTENT_TYPE
      expect(Minimo::Base.const_defined? :CONTENT_TYPE).to be true
      expect(const[:json]).to eq 'application/json; charset=utf-8'
      expect(const[:xml]).to eq 'application/xml; charset=utf-8'
      expect(const[:text]).to eq 'application/text; charset=utf-8'
    end
  end

  describe '#set' do
    it 'sets instance variable' do
      app.set :headers, { 'Vary' => 'Accept-Encoding' }
      headers = app.instance_variable_get :@headers
      expect(headers.has_key? 'Vary').to be true
      expect(headers['Vary']).to eq 'Accept-Encoding'
    end
  end

  describe '#status_code' do
    it 'returns 204 no contens http methods' do
      expect(app.send(:status_code, 'PUT')).to eq 204
      expect(app.send(:status_code, 'DELETE')).to eq 204
      expect(app.send(:status_code, 'PATCH')).to eq 204
    end

    it 'returns 201 created http methods' do
      expect(app.send(:status_code, 'POST')).to eq 201
    end

    it 'returns 200 get http methods' do
      expect(app.send(:status_code, 'GET')).to eq 200
      expect(app.send(:status_code, 'HEAD')).to eq 200
    end
  end

  describe '#default_header' do
    it 'returns default headers' do
      headers = app.send(:default_header)
      expect(headers['Server']).to eq "minimo #{app.version}"
      expect(headers['X-UA-Compatible']).to eq 'IE=Edge,chrome=1'
      expect(headers['X-Content-Type-Options']).to eq 'nosniff'
    end
  end

  describe '#header_content_type' do
    it 'returns http header content-type' do
      expect(app.send(:header_content_type, :json)).to eq 'application/json; charset=utf-8'
      expect(app.send(:header_content_type, :xml)).to eq 'application/xml; charset=utf-8'
      expect(app.send(:header_content_type, :text)).to eq 'application/text; charset=utf-8'
      expect(app.send(:header_content_type)).to eq 'application/text; charset=utf-8'
    end
  end

  describe '#fixture_path' do
    it 'returns response file path' do
      stub = Rack::Request.new({"PATH_INFO" => "/mock/",})
      app.instance_variable_set(:@request, stub)
      expect(app.send(:fixture_path, 'GET')).to eq './response/GET/mock'
      expect(app.send(:fixture_path, 'HEAD')).to eq './response/GET/mock'
      expect(app.send(:fixture_path, 'POST')).to eq './response/POST/mock'
    end
  end

  describe '#version' do
    it 'returns app version' do
      expect(app.version).to eq Minimo.const_get 'VERSION'
    end
  end
end

describe 'GET request' do

  let(:app) { Minimo::Application }

  before do
    app.set :fixture_path, File.dirname( __FILE__ ) + '/../fixture'
  end

  after do
    app.set :fixture_path, './fixture'
  end

  context 'when fixture file not exist' do
    it 'returns 404' do
      get '/404'

      expect(last_response.status).to eq 404
      expect(last_response.header['Content-Type']).to eq 'application/text; charset=utf-8'
      expect(last_response.body).to eq 'Oops! No route for GET /404'
    end
  end

  context 'when response json' do
    it 'returns mocking response' do
      expected_response = { "greet" => "Hellp World!" }

      get '/mock/response/json/'

      expect(last_response.status).to eq 200
      expect(last_response.header['Content-Type']).to eq 'application/json; charset=utf-8'
      expect(JSON::parse(last_response.body)).to eq expected_response
    end
  end

  context 'when response xml' do
    it 'returns mocking response' do
      get '/mock/response/xml/'

      response_body = REXML::Document.new(last_response.body)

      expect(last_response.status).to eq 200
      expect(last_response.header['Content-Type']).to eq 'application/xml; charset=utf-8'
      expect(response_body.elements['output_port/Greet'].text).to eq 'Hello World'
    end
  end

  context 'when response text' do
    it 'returns mocking response' do
      get '/mock/response/text/'

      expect(last_response.status).to eq 200
      expect(last_response.header['Content-Type']).to eq 'application/text; charset=utf-8'
      expect(last_response.body).to eq 'Hello World'
    end
  end
end

describe 'POST request' do

  let(:app) { Minimo::Application }

  before do
    app.set :fixture_path, File.dirname( __FILE__ ) + '/../fixture'
  end

  context 'when fixture file not exist' do
    it 'returns 404' do
      post '/404', { 'greet': 'Hi' }

      expect(last_response.status).to eq 404
      expect(last_response.header['Content-Type']).to eq 'application/text; charset=utf-8'
      expect(last_response.body).to eq 'Oops! No route for POST /404'
    end
  end

  context 'when response json' do
    it 'returns mocking response' do
      expected_response = { "greet" => "Hellp World!" }

      post '/mock/response/json/', { 'greet': 'Hi' }

      expect(last_response.status).to eq 201
      expect(last_response.header['Content-Type']).to eq 'application/json; charset=utf-8'
      expect(JSON::parse(last_response.body)).to eq expected_response
    end
  end

  context 'when response xml' do
    it 'returns mocking response' do
      post '/mock/response/xml/', { 'greet': 'Hi' }

      response_body = REXML::Document.new(last_response.body)

      expect(last_response.status).to eq 201
      expect(last_response.header['Content-Type']).to eq 'application/xml; charset=utf-8'
      expect(response_body.elements['output_port/Greet'].text).to eq 'Hello World'
    end
  end

  context 'when response text' do
    it 'returns mocking response' do
      post '/mock/response/text/', { 'greet': 'Hi' }

      expect(last_response.status).to eq 201
      expect(last_response.header['Content-Type']).to eq 'application/text; charset=utf-8'
      expect(last_response.body).to eq 'Hello World'
    end
  end
end

describe 'PUT request' do

  let(:app) { Minimo::Application }

  before do
    app.set :fixture_path, File.dirname( __FILE__ ) + '/../fixture'
  end

  context 'when fixture file not exist' do
    it 'returns 404' do
      put '/404', { 'greet': 'Hi' }

      expect(last_response.status).to eq 404
      expect(last_response.header['Content-Type']).to eq 'application/text; charset=utf-8'
      expect(last_response.body).to eq 'Oops! No route for PUT /404'
    end
  end

  context 'when fixture file exist' do
    it 'returns mocking response' do
      put '/mock/response/', { 'greet': 'Hi' }
      expect(last_response.status).to eq 204
      expect(last_response.body).to eq ''
    end
  end
end

describe 'DELETE request' do

  let(:app) { Minimo::Application }

  before do
    app.set :fixture_path, File.dirname( __FILE__ ) + '/../fixture'
  end

  context 'when fixture file not exist' do
    it 'returns 404' do
      delete '/404', { 'id': '1' }

      expect(last_response.status).to eq 404
      expect(last_response.header['Content-Type']).to eq 'application/text; charset=utf-8'
      expect(last_response.body).to eq 'Oops! No route for DELETE /404'
    end
  end

  context 'when fixture file exist' do
    it 'returns mocking response' do
      delete '/mock/response/', { 'id': '1' }
      expect(last_response.status).to eq 204
      expect(last_response.body).to eq ''
    end
  end
end

describe 'H request' do

  let(:app) { Minimo::Application }

  before do
    app.set :fixture_path, File.dirname( __FILE__ ) + '/../fixture'
  end

  context 'when fixture file not exist' do
    it 'returns 404' do
      head '/404'

      expect(last_response.status).to eq 404
      expect(last_response.header['Content-Type']).to eq 'application/text; charset=utf-8'
      expect(last_response.body).to eq 'Oops! No route for HEAD /404'
    end
  end

  context 'when fixture file exist' do
    it 'returns mocking response' do
      head '/mock/response/text/'
      expect(last_response.status).to eq 200
      expect(last_response.header['Content-Type']).to eq 'application/text; charset=utf-8'
      expect(last_response.body).to eq 'Hello World'
    end
  end

end
