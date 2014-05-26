require 'fileutils'
require 'date'
class ExtractionRunner
  
  attr_writer :source_dir_path
  attr_accessor :message, :process_log
  
  def initialize(opts={})
    @start_date = opts[:start_date]
    @end_date = opts[:end_date]
    @source_dir_path = opts[:source_dir_path]
    @process_log = {success:[], failure:[]}
  end
  
  def process

    puts "Running extractor against the data in #{source_dir_path}"
    extractor_path = File.join(File.dirname(__FILE__),"twitter_url_extractor.rb")
    original_working_dir = Dir.pwd
    FileUtils::mkdir_p output_directory
    dates_to_process.each do |date|
      destination_path = destination_file_path_for(date)
      puts "processing #{date.strftime("%Y_%m_%d")}"
      %x(cat #{expression_for_files_to_process(date)} | bundle exec wu-hadoop --from=json #{extractor_path} --mode=local | wu-local sort --on=total_tweets --numeric --reverse > #{destination_path})
      #puts "[SKIPPED] processing #{expression_for_files_to_process(date)} to #{destination_path}"
      process_log[:success] << {destination_file_path:destination_path}
    end
    message = "Finished compiling #{dates_to_process.count} link reports to #{process_log[:success].map{|l| l[:destination_file_path] }} with #{process_log[:failure].count} failures"
    puts message
  end
  
  def expression_for_files_to_process(date)
    source_dir_path+"/20131215-20140115_f3a6rxbkax_#{date.strftime("%Y_%m_%d")}*.json"
  end
  
  def dates_to_process
    start_date.upto(end_date)
  end
  
  def start_date
    @start_date ||= DateTime.strptime(today_string, "%Y%m%d")
  end
  
  def end_date
    @end_date ||= DateTime.strptime(today_string, "%Y%m%d") 
  end
  
  def destination_file_path_for(date)
    output_directory+"/#{date.strftime("%Y_%m_%d")}-linkReport.json"
  end

  def output_directory
    @output_directory ||= Dir.pwd+"/output"
  end
  
  
  def source_dir_path
    @source_dir_path ||= "data/#{today_string}"
  end
    
  def today_string
    @today_string ||= Time.now.strftime("%Y%m%d")
  end
end