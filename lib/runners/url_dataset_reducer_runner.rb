require 'fileutils'
require 'date'
class UrlDatasetReducerRunner < BaseRunner
  
  attr_accessor :message, :dataset_path

  def initialize(opts={})
    @start_date = opts[:start_date].kind_of?(DateTime) ? opts[:start_date] : DateTime.strptime(opts[:start_date], "%Y%m%d")
    @end_date = opts[:end_date].kind_of?(DateTime) ? opts[:end_date] : DateTime.strptime(opts[:end_date], "%Y%m%d")
    @original_dataset_path = opts[:dataset_path] if opts[:dataset_path]
  end
  
  # * concatenate new linkreport(s) with trending_urls.json dataset
  # * reduce the concatenate datasets using url_dataset_reducer
  # * write the result to trending_urls-{date_string}.json
  def process
    FileUtils::mkdir_p output_directory
    dates_to_process.sort.each do |date|
      destination_path = destination_file_path_for(date)
      puts "Combining data from #{expression_for_files_to_process(date)} with the dataset #{path_to_dataset} "
      %x(cat #{path_to_dataset} #{expression_for_files_to_process(date)} | bundle exec wu-local #{reducer_path} > #{destination_path})
      # for each consecutive pass, the output from the previous run is used as the starting dataset
      @dataset_path = destination_path
    end
    @message = "Finished merging data from #{dates_to_process.count} days with the data from #{original_dataset_path}.  The cumulative result is in #{dataset_path}"
  end
  
  def processed_reports
    puts "start_date: #{start_date}"
    puts "start_date: #{end_date}"
    puts "last: #{dates_to_process.to_a.last}"
    destination_file_path_for(dates_to_process.to_a.last)
  end
  
  private
  
  def path_to_dataset
    @dataset_path ||= original_dataset_path
  end
  
  def original_dataset_path
    @original_dataset_path ||= data_directory+"/trending_urls.json"
  end
  
  def expression_for_files_to_process(date)
    data_directory+"/#{date.strftime("%Y_%m_%d")}-linkReport.json"
  end
  
  def destination_file_path_for(date)
    data_directory+"/trending_urls-#{date.strftime("%Y_%m_%d")}.json"
  end
  
  def reducer_path
    extractor_path = File.join(File.dirname(__FILE__),"..", "dataflows", "reduce_to_cumulative_url_history.rb")
  end
  
  # In this processor, data_directory and output_directory are the same
  def data_directory
    output_directory 
  end
  
  def default_output_directory
    Dir.pwd+"/output"
  end

  
end
