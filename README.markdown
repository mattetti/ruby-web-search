# Ruby Web Search

This gem allows you to query google search engine from Ruby.
So far, only Google is supported.


Simple example on how to query Google:

    >> require 'ruby-web-search'
    => true
    >> response = RubyWebSearch::Google.search(:query => "Natalie Portman")
    >> response.results
    => [{:content=>"<b>Natalie Portman</b>, Star Wars, Phantom Menace, Attack of the Clones, Amidala, Leon,   Professional, Where The Heart Is, Anywhere But Here, Seagull, Heat, <b>...</b>", :title=>"Natalie Portman . Com - News", :url=>"http://www.natalieportman.com/", :domain=>"www.natalieportman.com", :cache_url=>"http://www.google.com/search?q=cache:9hGoJVGBJ2sJ:www.natalieportman.com"}, {:content=>"<b>Natalie Portman</b> was born on June 9th, 1981 in Jerusalem, Israel, as the... Visit   IMDb for Photos, Filmography, Discussions, Bio, News, Awards, Agent, <b>...</b>", :title=>"Natalie Portman", :url=>"http://www.imdb.com/name/nm0000204/", :domain=>"www.imdb.com", :cache_url=>"http://www.google.com/search?q=cache:JLzGjsYYdlkJ:www.imdb.com"}, {:content=>"<b>Natalie Portman</b> (Hebrew: \327\240\327\230\327\234\327\231 \327\244\327\225\327\250\327\230\327\236\327\237\342\200\216; born <b>Natalie</b> Hershlag June 9, 1981) is an   Israeli-American actress. <b>Portman</b> began her career in the early 1990s, <b>...</b>", :title=>"Natalie Portman - Wikipedia, the free encyclopedia", :url=>"http://en.wikipedia.org/wiki/Natalie_Portman", :domain=>"en.wikipedia.org", :cache_url=>"http://www.google.com/search?q=cache:32A4VEkC23gJ:en.wikipedia.org"}, {:content=>"Aug 30, 2008 <b>...</b> media on Miss <b>Portman</b>. You may recognize <b>Natalie</b> for her roles in <b>....</b> is in in   no way affiliated with <b>Natalie Portman</b> or her management. <b>...</b>", :title=>"Natalie Portman ORG ++{natalie-p.org} | your premiere NATALIE ...", :url=>"http://www.natalie-p.org/", :domain=>"www.natalie-p.org", :cache_url=>"http://www.google.com/search?q=cache:wv-CVcMW2SEJ:www.natalie-p.org"}] 
    
A google search returns a Response instance. Call `results` on the response to get the array on result. 
A Result is a simple hash object with few keys available:

* title       Title of the result
* url         Url of the result
* domain      Root url of the result
* content     Snippet of the result content
* cache\_url  Google cache url


By default, only the 4 top results get retrieved, you can specify the exact amount of results you want by passing the size argument.
    RubyWebSearch::Google.search(:query => "Natalie Portman", :size => 10)

## TODO

* Full support of the google api
* Start mulitple threads and join them to make large set queries more efficient
* support more search engines (Yahoo, live etc...)