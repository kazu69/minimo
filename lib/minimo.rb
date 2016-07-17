require 'minimo/version'
require 'minimo/logger'
require 'rack'

module Minimo
  class Base

    NO_CONTENT_METHOD = %w(DELETE PATCH PUT)
    CREATED_METHOD =%w(POST)
    CONTENT_TYPE = {
      json: 'application/json; charset=utf-8',
      xml: 'application/xml; charset=utf-8',
      text: 'application/text; charset=utf-8'
    }

    def initialize
      @headers = default_header
      @fixture_path = './response'.freeze
    end

    attr_accessor :headers, :fixture_path, :log_path

    def set(key, value)
      instance_variable_set "@#{key.to_s}", value
    end

    def call(env)
      response_body = []
      $stdout.sync = true

      @request = Rack::Request.new(env)
      verb = @request.request_method
      file_path = fixture_path(verb)

      response = Rack::Response.new do |r|
        r.status = status_code(verb)
      end

      CONTENT_TYPE.keys.push(nil).each do |ext|
        break if file_path.nil?
        separator = ext.nil? ? '' : '.'
        file = [file_path, ext].join(separator)
        if File.exist? file
          response_body << File.read(file)
          @headers['Content-Type'] = header_content_type(ext)
          break
        end
      end

      if response_body.empty?
        response.status = 404
        @headers['Content-Type'] = header_content_type(:text)
        response_body << "Oops! No route for #{verb} #{@request.path_info}"
      end

      @headers.map { |k,v| response.set_header(k,v) }
      response.write response_body.join("\n")

      if @log_dir
        logger = Minimo::Logger.new @log_dir
        msg = "#{verb} #{@request.path_info} #{env['SERVER_PROTOCOL']} #{response.status}"
        logger.write msg
      end

      response.finish
    end

    def version
      VERSION
    end

    private

    def status_code(verb)
      if NO_CONTENT_METHOD.include? verb
        204
      elsif CREATED_METHOD.include? verb
        201
      else
        200
      end
    end

    def default_header
      headers = {}
      headers['Server']                 = "minimo #{version}"
      headers['X-UA-Compatible']        = 'IE=Edge,chrome=1'
      headers['X-Content-Type-Options'] = 'nosniff'

      headers
    end

    def header_content_type(type = nil)
      type = :text if type.nil?
      CONTENT_TYPE[type]
    end

    def fixture_path(verb)
      method = verb
      method = 'GET' if verb == 'HEAD'
      requested_path = @request.path_info
      "#{@fixture_path}/#{method}/#{requested_path[1..-1].chomp('/').gsub(/\//, '_')}"
    end
  end

  Application = Base.new

  module Delegator
    def self.delegate(*methods)
      Array(methods).each do |method_name|
        define_method(method_name) do |*args, &block|
          Delegator.target.send(method_name, *args, &block)
        end
        private method_name
      end
    end

    delegate :set

    class << self
      attr_accessor :target
    end

    self.target = Application
  end
end

include Minimo::Delegator
