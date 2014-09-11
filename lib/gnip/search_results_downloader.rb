# Downloads a set of search results to a specified directory
class Gnip::SearchResultsDownloader
  DEFAULT_RULES = "(JavaScript OR jQuery OR Node.js OR AngularJS OR CSS3 OR HTML5 OR D3.js OR SVG OR url_contains:CSS3 OR url_contains:SVG OR url_contains:jquery OR url_contains:html5) has:links"

  attr_accessor :today_string, :skip_download, :output_dir_path, :start_date, :end_date, :searcher

  def initialize(opts={})
    @today_string = opts[:today_string]
    @output_dir_path = opts[:output_dir_path]
    @start_date = opts[:start_date] ? opts[:start_date] : (now-1).strftime("%Y%m%d%H%M")
    @end_date = opts[:end_date] ? opts[:end_date] : now.strftime("%Y%m%d%H%M")
  end

  def searcher
    @searcher ||= Gnip::Searcher.new
  end

  def download_latest_results
    setup_download_dir
    puts "Downloading today's activities."
    start_time = Time.now
    counter = 0
    while searcher.more_results?
      counter += 1
      print " Writing #{download_dir_path}/"+counter.to_s + ".json\r"
      $stdout.flush
      if counter == 1
        results = searcher.run_search(query:Gnip::Searcher.default_rules, from:start_date, to:end_date, max:500)
      else
        results = searcher.resume_search
      end
      File.open(download_dir_path+"/#{counter}.json", 'w') do |file|
        results.each {|result| file.write(result.to_json+"\n") }
      end
    end
    puts "... download complete. Created #{counter} files in #{download_dir_path}.  Duration #{Time.now-start_time} seconds."
  end

  def setup_download_dir
    FileUtils::mkdir_p download_dir_path
  end

  def download_dir_path
    "data/#{today_string}"
  end

  # By default, output_dir_path is the same as download_dir_path since nothing has to be unzipped (unlike HPT Downloader)
  def output_dir_path
    @output_dir_path ||= download_dir_path
  end

  def today_string
    @today_string ||= Time.now.strftime("%Y%m%d")
  end
end
