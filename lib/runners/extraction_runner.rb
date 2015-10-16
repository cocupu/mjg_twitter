require 'fileutils'
require 'date'
class ExtractionRunner < BaseRunner
  
  attr_writer :source_dir_path
  attr_accessor :message, :process_log, :invert_filters
  
  def initialize(opts={})
    @start_date = opts[:start_date].kind_of?(DateTime) ? opts[:start_date] : DateTime.strptime(opts[:start_date], "%Y%m%d")
    @end_date = opts[:end_date].kind_of?(DateTime) ? opts[:end_date] : DateTime.strptime(opts[:end_date], "%Y%m%d")
    @source_dir_path = opts[:source_dir_path]
    @process_log = {success:[], failure:[]}
    @invert_filters = opts[:invert_filters].nil? ? false : opts[:invert_filters]
  end
  
  def process()
    puts "Running extractor against the data in #{source_dir_path}"
    extractor_path = File.join(File.dirname(__FILE__),"..", "dataflows", "map_and_reduce_tweets_to_urls.rb")
    original_working_dir = Dir.pwd
    FileUtils::mkdir_p output_directory
    dates_to_process.each do |date|
      destination_path = destination_file_path_for(date)
      puts "processing #{date.strftime("%Y_%m_%d")}"
      puts "cat #{expression_for_files_to_process(date)} | bundle exec wu-local #{extractor_path} #{extractor_flags} | wu-local sort --on=weighted_count --numeric --reverse > #{destination_path}"
      %x(cat #{expression_for_files_to_process(date)} | bundle exec wu-local #{extractor_path} #{extractor_flags} | wu-local sort --on=weighted_count --numeric --reverse > #{destination_path})
      #puts "[SKIPPED] processing #{expression_for_files_to_process(date)} to #{destination_path}"
      process_log[:success] << {destination_file_path:destination_path}
    end
    if invert_filters?
      message = "Finished compiling #{dates_to_process.count} reports of rejected urls as #{processed_reports} with #{process_log[:failure].count} failures"
    else
      message = "Finished compiling #{dates_to_process.count} link reports to #{processed_reports} with #{process_log[:failure].count} failures"
    end
    puts message
  end

  # IMPORTANT: uses sort_command `wu-local sort --on="url"`.  This ensures that the output from the mapper gets sorted properly.
  def extractor_flags
    additional_options = invert_filters? ? "--invert_filters --include_debug_info" : "--include_debug_info"
    additional_options
  end
  
  def expression_for_files_to_process(date)
    #source_dir_path+"/20131215-20140115_f3a6rxbkax_#{date.strftime("%Y_%m_%d")}*.json"
    # source_dir_path+"/*.json"
    source_dir_path+"/#{date.strftime("%Y_%m_%d")}/*.json"
  end
  
  def destination_file_path_for(date)
    if invert_filters?
      output_directory+"/#{date.strftime("%Y_%m_%d")}-rejectedUrls.json"
    else
      output_directory+"/#{date.strftime("%Y_%m_%d")}-linkReport.json"
    end
  end

  def processed_reports
    if process_log[:success].empty?
      dates_to_process.map {|d| destination_file_path_for(d)}
    else
      process_log[:success].map{|l| l[:destination_file_path] }
    end
  end

  def source_dir_path
    @source_dir_path ||= "data/#{today_string}"
  end

  def invert_filters?
    @invert_filters
  end
end