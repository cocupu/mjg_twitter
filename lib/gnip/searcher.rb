module Gnip
  class Searcher
    DEFAULT_RULES = "(JavaScript OR jQuery OR Node.js OR AngularJS OR CSS3 OR HTML5 OR D3.js OR SVG OR url_contains:CSS3 OR url_contains:SVG OR url_contains:jquery OR url_contains:html5) has:links lang:en"

    def self.default_rules
      DEFAULT_RULES
    end

    attr_accessor :search_type, :results, :next_token, :query_params, :finished

    def initialize(args={})
      if args[:search_type]
        @search_type = :counts
      else
        @search_type = :activities
      end
      @finished = false
      @query_params = args[:query_params] ? args[:query_params] : Gnip::Searcher.default_rules
    end

    def run_search(query_params=query_params)
      if search_type == :counts
        retrieve_and_parse(Gnip::SearchService::count_endpoint, query_params)
      else
        retrieve_and_parse(Gnip::SearchService::search_endpoint, query_params)
      end
    end

    def resume_search(query_params=query_params)
      run_search(query_params) unless !more_results?
    end

    def more_results?
      !@finished
    end
    
    def download_into(download_dir_path, query_opts)
      initialize_directory(download_dir_path)
      counter = 0
      while more_results?
        counter += 1
        print " Writing #{download_dir_path}/"+counter.to_s + ".json\r"
        $stdout.flush
        if counter == 1
          results = run_search(query_opts)
        else
          results = resume_search
        end
        File.open(download_dir_path+"/#{counter}.json", 'w') do |file|
          results.each_with_index do |result, index| 
            line_end = (index < results.length-1) ? "\n" : ""
            file.write(result.to_json+line_end) 
          end
        end
      end
    end
    
    def initialize_directory(dir_path)
      FileUtils::mkdir_p dir_path
    end

    # GNIP limits pagination to 500 activities per page
    def retrieve_and_parse(endpoint, query_params)
      @query_params = query_params
      if search_type == :counts
        json = Gnip::SearchService.counts_search(query_params)
        @results = Gnip::SearchService.parse_counts json
      else
        json = Gnip::SearchService.activities_search(query_params)
        @results = Gnip::SearchService.parse_activities json
      end

      if json[:next]
        @next_token = json[:next]
        @query_params[:next] = @next_token
        @finished = false
      else
        @next_token = nil
        @query_params.delete(:next)
        @finished = true
      end
      @results
    end

  end
end
