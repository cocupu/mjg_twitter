require 'fileutils'
require 'zlib'
class GnipDownloader
  
  attr_writer :today_string, :skip_download, :output_dir_path
  
  def initialize(opts={})
    @today_string = opts[:today_string]
    @skip_download = opts[:skip_download]
    @output_dir_path = opts[:output_dir_path]
  end
  
  def download_and_unpack
    download_latest_results unless skip_download?
    unzip_downloaded_results
  end
  
  def download_latest_results
    original_directory = Dir.pwd
    setup_download_dir
    puts "Downloading today's files."
    start_time = Time.now
    output = %x(cd #{download_dir_path} && curl -sS -u marc@mjg.in:Df9cbNwW[2xik^QQjG2M https://historical.gnip.com/accounts/MJGInternational/publishers/twitter/historical/track/jobs/f3a6rxbkax/results.csv | xargs -P 8 -t -n2 curl -o)
    puts "... download complete.  Duration #{Time.now-start_time} seconds."
    Dir.chdir original_directory 
    return output
  end
  
  def unzip_downloaded_results
    print "Unzipping results"
    $stdout.flush
    setup_destinaton_dir
    to_extract = Dir["#{download_dir_path}/*.gz"]
    start_time = Time.now
    to_extract.each_with_index do |gz_filename, index|
      Zlib::GzipReader.open(gz_filename) do |gz|
        destination_file_path = File.join(output_dir_path, File.basename(gz_filename).gsub(".gz",""))
        File.open(destination_file_path, "w") do |g|
          IO.copy_stream(gz, g)
        end
        if (index % 20) == 0
          print "."
          $stdout.flush
        end
      end
    end
    puts "finished unzipping #{to_extract.count} results into #{output_dir_path} in #{Time.now-start_time} seconds."
  end
  
  def setup_download_dir
    FileUtils::mkdir_p download_dir_path
  end
  
  def setup_destinaton_dir
    FileUtils::mkdir_p output_dir_path
  end
  
  def download_dir_path
    "data/#{today_string}"
  end
    
  def output_dir_path
    @output_dir_path ||= download_dir_path+"/json"
  end
  
  def today_string
    @today_string ||= Time.now.strftime("%Y%m%d")
  end
  
  private 
  
  def skip_download?
    if @skip_download.nil?
      true
    else
      @skip_download
    end
  end
  
end
