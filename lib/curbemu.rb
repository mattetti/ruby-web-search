require 'net/http'

module Curl
  module Err
    class CurlError < RuntimeError; end
    class GotNothingError < CurlError; end
    class ConnectionFailedError < CurlError; end
    class TimeoutError < CurlError; end
    class HttpError < CurlError; end
  end
  class Easy
    attr_accessor :timeout, :url, :body_str, :headers, :conn
 
    def initialize(url = nil)
      @url = url
      @headers = {}
      @body_str = nil
    end
 
    #Not yet implemented.. only needed for importing from LibraryThing
    def header_str
      ""
    end
 
    #Curl::Easy.perform("http://old-xisbn.oclc.org/xid/isbn/1234").body_str
    #Curl::Easy.perform("http://old-xisbn.oclc.org/xid/isbn/1234").header_str
    def self.perform(url)
      c = self.new(url)
      yield(c) if block_given?
      c.perform
      c
    end
    
    def self.http_get(url)
      c = self.new(url)
      yield(c) if block_given?
      c.perform
      c
    end
 
    #Curl::Easy.http_post("http://foo.com", {"img_url" => url}) { |r| r.headers = 'Content-Type: text/json' }.body_str)
    def self.http_post(url, options = {})
      c = self.new(url)
      yield(c) if block_given?
      c.http_post(options)
      c 
    end
 
    def perform
      uri = URI.parse(url)
      res = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(Net::HTTP::Get.new(uri.request_uri))
      }
      @body_str = res.body
    rescue => e
      raise ::Curl::Err::HttpError, e.message                  
    end
 
    def http_post(options = {})
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      resp, data = http.post(uri.request_uri, options, headers)
      @body_str = data
    rescue => e
       raise ::Curl::Err::HttpError, e.message                  
    end
  end
end