GEM = "ruby-web-search"
GEM_VERSION = "0.0.2"
AUTHOR = "Matt Aimonetti"
EMAIL = "mattaimonetti@gmail.com"
HOMEPAGE = "http://merbist.com"
SUMMARY = "A Ruby gem that provides a way to retrieve search results via the main search engines using Ruby"

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  # s.add_dependency "curb"
  s.add_dependency "json"
  
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README.markdown Rakefile) + ["lib/curbemu.rb", "lib/ruby-web-search.rb", "spec/ruby-web-search-unthreaded.rb", "spec/ruby-web-search_spec.rb", "spec/spec_helper.rb"]
end