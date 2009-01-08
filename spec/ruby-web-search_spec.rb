require File.dirname(__FILE__) + '/spec_helper'
$RUBY_WEB_SEARCH_DEBUG = true

describe "ruby-web-search" do
  
  describe "Google search" do
    
    describe "simple format" do
      before(:all) do
        @response = RubyWebSearch::Google.search(:query => "Natalie Portman")
      end
    
      it "should return a RubyWebSeach::Google::Response " do
        @response.should be_an_instance_of(RubyWebSearch::Google::Response)
      end
    
      it "should have results" do
        @response.results.should be_an_instance_of(Array)
        @response.results.first.should be_an_instance_of(Hash)
      end
    
      it "should have 4 results (small request set size)" do
        @response.results.size.should == 4
      end
    
      describe "results" do
        before(:all) do
          @results = @response.results
        end
      
        it "should have a title" do
          @results.first[:title].should be_an_instance_of(String)
          @results.first[:title].size.should > 3
        end
      
        it "should have an url" do
          @results.first[:url].should be_an_instance_of(String)
          @results.first[:url].size.should > 3
        end
      
        it "should have a cache url" do
          @results.first[:cache_url].should be_an_instance_of(String)
          @results.first[:cache_url].size.should > 3
        end
      
        it "should have content" do
          @results.first[:content].should be_an_instance_of(String)
          @results.first[:content].size.should > 15
        end
      
        it "should have a domain" do
          @results.first[:domain].should be_an_instance_of(String)
          @results.first[:domain].size.should > 7
          @results.first[:url].should include(@response.results.first[:domain])
        end
      end
    end
  
    describe "large result set" do
      before(:all) do
        @response = RubyWebSearch::Google.search(:query => "Natalie Portman", :result_size => "large")
      end
      
      it "should have 8 results" do
        @response.results.size.should == 8
      end
    end
    
    describe "custom size result set" do
      before(:all) do
        @response = RubyWebSearch::Google.search(:query => "Natalie Portman", :size => 24)
        @results  = @response.results 
      end
      
      it "should have exactly 24 results" do
        @results.size.should == 24
      end
      
      it "should have 24 unique results" do
        first = @results.shift
        @results.each do |result|
          first[:url].should_not == result[:url]
        end
      end
    end
  end
  
end