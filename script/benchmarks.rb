require 'benchmark'
require File.join(File.dirname(__FILE__), '..', 'lib', 'ruby-web-search')

Benchmark.bm(50) do |x|
  x.report("search")                          { RubyWebSearch::Google.search(:query => "Natalie Portman") }
  x.report("unthreaded_search")               { RubyWebSearch::Google.unthreaded_search(:query => 'Natalie Portman') }
  
  x.report("search :size => 60")              { RubyWebSearch::Google.search(:query => "Natalie Portman", :size => 60) }
  x.report("unthreaded_search :size => 60")   { RubyWebSearch::Google.unthreaded_search(:query => 'Natalie Portman', :size => 60) }
end
