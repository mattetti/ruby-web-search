require 'rubygems'
require 'CGI'
require 'JSON'

begin
  gem 'curb'
  require 'curb'
rescue LoadError
  require File.join(File.dirname(__FILE__), 'curbemu')
end


$RUBY_WEB_SEARCH_DEBUG = false

class RubyWebSearch
  
  # http://code.google.com/apis/ajaxsearch/documentation/reference.html
  class Google
    
    def self.search(options={})
      query = ::RubyWebSearch::Google::Query.new(options)
      query.execute
    end
    
    def self.unthreaded_search(options={})
      query = ::RubyWebSearch::Google::Query.new(options)
      query.execute_unthreaded
    end
    
    class Query
      attr_accessor :query, :start_index, :result_size, :filter, :country_code, :language_code
      attr_accessor :safe_search, :type, :custom_search_engine_id, :version, :referer, :request_url
      attr_accessor :size, :cursor, :custom_request_url, :response
      
      class Error < StandardError;  end
      
      SEARCH_BASE_URLS = {  :web    => "http://ajax.googleapis.com/ajax/services/search/web",
                            :local  => "http://ajax.googleapis.com/ajax/services/search/local",
                            :video  => "http://ajax.googleapis.com/ajax/services/search/video",
                            :blog   => "http://ajax.googleapis.com/ajax/services/search/blogs",
                            :news   =>  "http://ajax.googleapis.com/ajax/services/search/news",
                            :book   => "http://ajax.googleapis.com/ajax/services/search/books",
                            :image  => "http://ajax.googleapis.com/ajax/services/search/images",
                            :patent => "http://ajax.googleapis.com/ajax/services/search/patent"
                          }
      
      #
      # You can overwrite the query building process by passing the request url to use.
      #
      # ==== Params
      #   query<String>
      #   start_index<Integer>
      #   result_size<String> small or large (4 or 8 results) default: small
      #   filter
      #   country_code<String> 2 letters language code for the country you want
      #       to limit to
      #   language_code<String>  (Web only)
      #   safe_search<String>    active, moderate or off. Default: active (web only)
      #   custom_search_engine_id<String> optional argument supplying the unique id for
      #         the Custom Search Engine that should be used for the request (e.g., 000455696194071821846:reviews).
      #         (web only)
      #
      def initialize(options={})
        if options[:custom_request_url]
          @custom_request_url = options[:request_url]
        else
          @query = options[:query]
          raise Google::Query::Error, "You need to pass a query" unless @query
          @cursor                   = options[:start_index] || 0
          @result_size              = options[:result_size]
          @filter                   = options[:filter]
          @type                     = options[:type]        || :web
          @country_code             = options[:country_code] ? "country#{options[:country_code].upcase}" : nil
          @language_code            = options[:language_code] ? "lang_#{options[:language_code].upcase}" : nil
          @safe_search              = options[:safe_search]
          @custom_search_engine_id  = options[:custom_search_engine_id]
          @version                  = options[:version] || "1.0"
          @referer                  = options[:referer] ||  "http://github.com/mattetti/"
          @size                     = options[:size] || 4
          @result_size              = "large" if size > 8  # increase the result set size to avoid making to many requests
          @size                     = 8 if (@result_size == "large" && size < 8)
        end
        @response ||= Response.new(:query => (query || custom_request_url), :size => size)
      end
      
      def build_request
        if custom_request_url 
          custom_request_url
        else
          @request_url = "#{SEARCH_BASE_URLS[type]}?v=#{version}&q=#{CGI.escape(query)}"
          @request_url << "&rsz=#{result_size}" if result_size
          @request_url << "&start=#{cursor}" if cursor > 0
          @request_url << "&hl=#{language_code}" if language_code
          
          puts request_url if $RUBY_WEB_SEARCH_DEBUG
          request_url
        end
      end
      
      def build_requests
        if custom_request_url 
          requests = [custom_request_url]
        else
          requests = []
          # create an array of requests based on the fact that google limits
          # us to 8 responses per request but let us use a cursor
          (size / 8.to_f).ceil.times do |n|
            url = "#{SEARCH_BASE_URLS[type]}?v=#{version}&q=#{CGI.escape(query)}"
            url << "&rsz=#{result_size}" if result_size
            url << "&hl=#{language_code}" if language_code
            url << "&start=#{cursor}"
            @cursor += 8
            requests << url
          end
          
          puts requests.inspect if $RUBY_WEB_SEARCH_DEBUG
          requests
        end
      end
      
      # Makes the request to Google
      # if a larger set was requested than what is returned,
      # more requests are made until the correct amount is available
      def execute_unthreaded
        curl_request = ::Curl::Easy.new(build_request){ |curl| curl.headers["Referer"] = referer }
        curl_request.perform
        results = JSON.load(curl_request.body_str) 
        
        response.process(results)
        @cursor = response.results.size - 1
        if ((cursor + 1) < size && custom_request_url.nil?)
          puts "cursor: #{cursor} requested results size: #{size}" if $RUBY_WEB_SEARCH_DEBUG
          execute_unthreaded
        else
          response.limit(size)
        end
      end
      
      # Makes the request to Google
      # if a larger set was requested than what is returned,
      # more requests are made until the correct amount is available
      def execute
        threads = build_requests.map do |req|
          Thread.new do
             curl_request = ::Curl::Easy.new(req){ |curl| curl.headers["Referer"] = referer }
             curl_request.perform
             JSON.load(curl_request.body_str)
          end
        end
        threads.each do |t|
          response.process(t.value)
        end
        response.limit(size)
      end
      
    end #of Query
    
    
    class Response
      attr_reader :results, :status, :query, :size, :estimated_result_count
      def initialize(google_raw_response={})
        process(google_raw_response) unless google_raw_response.empty?
      end
        
      def process(google_raw_response={})
        @query    ||= google_raw_response[:query]
        @size     ||= google_raw_response[:size]
        @results  ||= []
        @status     = google_raw_response["responseStatus"]
        if google_raw_response["responseData"] && status && status == 200
          estimated_result_count ||= google_raw_response["cursor"]["estimatedResultCount"] if google_raw_response["cursor"]
          @results  +=  google_raw_response["responseData"]["results"].map do |r| 
                        { 
                          :title      => r["titleNoFormatting"], 
                          :url        => r["unescapedUrl"],
                          :cache_url  => r["cacheUrl"],
                          :content    => r["content"],
                          :domain     => r["visibleUrl"]
                        }
                      end
        end
        
        def limit(req_size)
          @results = @results[0...req_size]
          self
        end
        
      end
    end #of Response
    
  end #of Google
  
end