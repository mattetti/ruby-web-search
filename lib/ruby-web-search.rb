require 'CGI'
require 'JSON'
require 'curb'

$RUBY_WEB_SEARCH_DEBUG = false

class RubyWebSearch
  
  # http://code.google.com/apis/ajaxsearch/documentation/reference.html
  class Google
    
    def self.search(options={})
      query = ::RubyWebSearch::Google::Query.new(options)
      query.execute
    end
    
    class Query
      attr_accessor :query, :start_index, :result_size, :filter, :country_code, :language_code
      attr_accessor :safe_search, :type, :custom_search_engine_id, :version, :referer, :request_url
      attr_accessor :size, :cursor, :custom_request_url
      
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
          @start_index              = options[:start_index] || 0
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
          @size                     = 8 if @result_size == "large"
          @cursor                   = 0
        end
      end
      
      
      # Buils the request URL to be sent to Google
      def build_request
        if custom_request_url 
          custom_request_url
        else
          @request_url = "#{SEARCH_BASE_URLS[type]}?v=#{version}&q=#{CGI.escape(query)}"
          @request_url << "&rsz=#{result_size}" if result_size
          
          puts request_url if $RUBY_WEB_SEARCH_DEBUG
          
          request_url
        end
      end
      
      # Makes the request to Google
      # if a larger set was requested than what is returned,
      # more requests are made until the correct amount is available
      def execute(previous_responses=[])
        response = previous_responses
        curl_request = ::Curl::Easy.new(build_request){ |curl| curl.headers["Referer"] = referer }
        curl_request.perform
        results = JSON.load(curl_request.body_str) 
        raw_response = Result.new(results)
        response << raw_response.results
        @cursor = response.size - 1
        if (cursor < size && custom_request_url.nil?)
          execute(response.flatten)
        else
          response.flatten[0...size]
        end
      end
      
      def execute2(previous_responses=[])
        response = previous_responses
        curl_request = ::Curl::Easy.new(build_request){ |curl| curl.headers["Referer"] = referer }
        curl_request.perform
        results = JSON.load(curl_request.body_str) 
        raw_response = Result.new(results)
        response << raw_response.results
        @cursor = response.size
        puts "cursor: #{cursor} : size #{size}"
        if (cursor < size && custom_request_url.nil?)
          puts "looping cursor: #{cursor} : #{size}"
          response.flatten
        else
          response.flatten
        end
      end
      
    end #of Query
    
    
    class Result

      attr_reader :urls, :results, :status, :raw
      def initialize(google_query_results={})
        @raw        = google_query_results
        raw_results = raw["responseData"]["results"]
        @status     = raw["responseStatus"]
        @urls       = raw_results.map{|r| r["unescapedUrl"]}
        @results    =  raw_results.map do |r| 
                      { 
                        :title      => r["titleNoFormatting"], 
                        :url        => r["unescapedUrl"],
                        :cache_url  => r["cacheUrl"],
                        :content    => r["content"],
                        :domain     => r["visibleUrl"]
                      }
                    end
      end

    end #of Results
    
  end #of Google
  
end