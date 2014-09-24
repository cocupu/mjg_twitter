# Downloads a set of search results to a specified directory
class Gnip::SearchResultsDownloader

  attr_accessor :data_directory, :skip_download, :output_dir_path, :start_date, :end_date, :searcher

  def initialize(opts={})
    @data_directory = opts[:data_directory]
    @output_dir_path = opts[:output_dir_path]
    if opts[:start_date]
      @start_date = opts[:start_date].kind_of?(Date) ? opts[:start_date] : Date.strptime(opts[:start_date], "%Y%m%d")
    else
      @start_date = (Date.today-1)
    end
    if opts[:end_date]
      @end_date = opts[:end_date].kind_of?(Date) ? opts[:end_date] : Date.strptime(opts[:end_date], "%Y%m%d")
    else
      @end_date = (Date.today)
    end
  end

  def searcher
    @searcher ||= Gnip::Searcher.new
  end

  def download_latest_results
    setup_download_dir
    puts "Downloading today's activities."
    start_time = Time.now
    dates_to_download.each do |date|
      search_start_time = date.strftime("%Y%m%d%H%M")
      search_end_time = (date+1).strftime("%Y%m%d%H%M")
      searcher.finished = false
      searcher.download_into(download_dir_path(date), query:Gnip::Searcher.default_rules, from:search_start_time, to:search_end_time, max:500)
    end
    puts "... download complete. Created files in #{download_dir_path}.  Duration #{Time.now-start_time} seconds."
  end
  
  def dates_to_download
    start_date.upto(end_date)
  end

  def setup_download_dir
    FileUtils::mkdir_p download_dir_path
  end

  def download_dir_path(date=nil)
    base_path = "data/#{data_directory}"
    if date
      return base_path+"/#{date.strftime("%Y_%m_%d")}" 
    else
      return base_path
    end
  end

  # By default, output_dir_path is the same as download_dir_path since nothing has to be unzipped (unlike HPT Downloader)
  def output_dir_path
    @output_dir_path ||= download_dir_path
  end

  def data_directory
    @data_directory ||= Time.now.strftime("%Y%m%d%H%M")
  end
end
