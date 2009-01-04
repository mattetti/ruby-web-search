require File.dirname(__FILE__) + '/spec_helper'
#$RUBY_WEB_SEARCH_DEBUG = true

describe "ruby-web-search" do
  
  describe "Google search" do
    
    describe "simple format" do
      before(:all) do
        @response = RubyWebSearch::Google.search(:query => "Natalie Portman")
      end
    
      it "should return an Array " do
        @response.should be_an_instance_of(Array)
      end
    
      it "should have results" do
        @response.should be_an_instance_of(Array)
        @response.first.should be_an_instance_of(Hash)
      end
    
      it "should have 4 results (small request set size)" do
        @response.size.should == 4
      end
    
      describe "results" do
        before(:all) do
          @results = @response
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
          @results.first[:url].should include(@results.first[:domain])
        end
      end
    end

    describe "large result set" do
      before(:all) do
        @response = RubyWebSearch::Google.search(:query => "Natalie Portman", :result_size => "large")
      end
      
      it "should have 8 results" do
        @response.size.should == 8
      end
    end
    
    describe "custom size result set" do
      before(:all) do
        @response = RubyWebSearch::Google.search(:query => "Natalie Portman", :size => 24)
      end
      
      it "should have exactly 24 results" do
        @response.size.should == 24
      end
    end
    
    
  end
  
end