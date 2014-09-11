module Gnip
  autoload :SearchService, File.dirname(__FILE__)+'/gnip/search_service'
  autoload :Searcher, File.dirname(__FILE__)+'/gnip/searcher'
  autoload :SearchResultsDownloader, File.dirname(__FILE__)+'/gnip/search_results_downloader'
end