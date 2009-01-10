# For better performance, you have to warm up JRuby
require 'benchmark'
require File.join(File.dirname(__FILE__), '..', 'lib', 'ruby-web-search')

10.times do
  n = 50000
  Benchmark.bm(50) do |x|
    x.report("search")                          { RubyWebSearch::Google.search(:query => "Natalie Portman") }
    x.report("unthreaded_search")               { RubyWebSearch::Google.unthreaded_search(:query => 'Natalie Portman') }

    x.report("search :size => 30")              { RubyWebSearch::Google.search(:query => "Natalie Portman", :size => 30) }
    x.report("unthreaded_search :size => 30")   { RubyWebSearch::Google.unthreaded_search(:query => 'Natalie Portman', :size => 30) }

    x.report("search :size => 80")              { RubyWebSearch::Google.search(:query => "Natalie Portman", :size => 80) }
    x.report("unthreaded_search :size => 80")   { RubyWebSearch::Google.unthreaded_search(:query => 'Natalie Portman', :size => 80) }

    x.report("search :size => 150")             { RubyWebSearch::Google.search(:query => "Natalie Portman", :size => 150) }
    x.report("unthreaded_search :size => 150")  { RubyWebSearch::Google.unthreaded_search(:query => 'Natalie Portman', :size => 150) }

    x.report("search :size => 200")             { RubyWebSearch::Google.search(:query => "Natalie Portman", :size => 200) }
    x.report("unthreaded_search :size => 200")  { RubyWebSearch::Google.unthreaded_search(:query => 'Natalie Portman', :size => 200) }  
  end
end