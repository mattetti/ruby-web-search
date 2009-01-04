require File.dirname(__FILE__) + '/spec_helper'
$RUBY_WEB_SEARCH_DEBUG = true

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
          @response = @response
        end
      
        it "should have a title" do
          @response.first[:title].should be_an_instance_of(String)
          @response.first[:title].size.should > 3
        end
      
        it "should have an url" do
          @response.first[:url].should be_an_instance_of(String)
          @response.first[:url].size.should > 3
        end
      
        it "should have a cache url" do
          @response.first[:cache_url].should be_an_instance_of(String)
          @response.first[:cache_url].size.should > 3
        end
      
        it "should have content" do
          @response.first[:content].should be_an_instance_of(String)
          @response.first[:content].size.should > 15
        end
      
        it "should have a domain" do
          @response.first[:domain].should be_an_instance_of(String)
          @response.first[:domain].size.should > 7
          @response.first[:url].should include(@response.first[:domain])
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
      
      it "should have 24 unique results" do
        first = @response.shift
        @response.each do |response|
          first[:url].should_not == response[:url]
        end
      end
    end
    
    
  end
  
end